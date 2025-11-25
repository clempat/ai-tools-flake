# Claude Code configuration module
{ flakePackages }: { config, lib, pkgs, ... }:

with lib;

let
  cfg = config.programs.ai-tools;
  shared = import ./ai-tools-shared.nix { inherit lib pkgs; };

  # Hardcoded personal configuration
  personalMcpServers = import ../config/mcps.nix;
  personalAgents = import ../config/agents.nix;
  personalMemory = ../config/memory.md;

  # Generate list of disabled MCP servers for claude-code settings
  disabledMcpServers = lib.attrNames
    (lib.filterAttrs (name: server: !(server.enable or false))
      personalMcpServers);

  # Convert agents to directories for Claude Code
  claudeAgentsDir = if personalAgents != { } then
    pkgs.linkFarm "claude-agents" (lib.mapAttrsToList (name: agent: {
      name = "${name}.md";
      path = shared.generateAgentFile "claude" name agent;
    })
      (lib.filterAttrs (name: agent: !(agent.disable or false)) personalAgents))
  else
    null;

in {
  config = mkIf cfg.enable (mkMerge [
    {
      programs.claude-code = {
        enable = true;
        package = mkDefault flakePackages.claude-code;
        mcpServers = personalMcpServers;
        settings = {
          theme = "dark";
          preferredNotifChannel = "native";
          disabledMcpjsonServers = disabledMcpServers;
        };
      };
    }
    (mkIf (claudeAgentsDir != null) {
      programs.claude-code.agentsDir = claudeAgentsDir;
    })
    {
      programs.claude-code.memory.source = personalMemory;
      programs.claude-code.commands = shared.commandsAttrSet;
    }
  ]);
}
