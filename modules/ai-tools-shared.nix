# Shared functions and utilities for AI tools configuration
{ lib, pkgs, ... }:

with lib;

rec {
  # Transform MCP server for mcphub.nvim
  transformMcpForMcphub = name: server:
    let
      # mcphub uses "disabled" instead of "enable"
      baseServer = builtins.removeAttrs server [ "enable" "type" ];
      withDisabled = if server ? enable then
        baseServer // { disabled = !server.enable; }
      else
        baseServer;
    in if server.type == "http" then
    # http servers: keep url and headers, remove type
      withDisabled
    else if server.type == "stdio" then
    # stdio servers: keep command, args, env as-is
      withDisabled
    else
      withDisabled;

  # Convert commands directory to attribute set for home-manager
  commandsAttrSet = let
    commandsDir = ../config/commands;
    commandFiles = builtins.readDir commandsDir;
  in lib.mapAttrs' (name: type:
    let
      # Remove .md extension for command name
      commandName = lib.removeSuffix ".md" name;
    in lib.nameValuePair commandName (commandsDir + "/${name}"))
  (lib.filterAttrs (name: type: type == "regular" && lib.hasSuffix ".md" name)
    commandFiles);

  # Generate mcphub.nvim servers.json
  generateMcphubConfig = personalMcpServers:
    let mcphubServers = lib.mapAttrs transformMcpForMcphub personalMcpServers;
    in builtins.toJSON { mcpServers = mcphubServers; };
}
