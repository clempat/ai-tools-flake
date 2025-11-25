# OpenCode configuration module
{ flakePackages }: { config, lib, pkgs, ... }:

with lib;

let
  cfg = config.programs.ai-tools;
  shared = import ./ai-tools-shared.nix { inherit lib pkgs; };

  # Hardcoded personal configuration
  personalMcpServers = import ../config/mcps.nix;
  personalAgents = import ../config/agents.nix;
  personalMemory = ../config/memory.md;

  # Convert agents for OpenCode
  opencodeAgents =
    lib.mapAttrs (name: agent: shared.generateAgentFile "opencode" name agent)
    (lib.filterAttrs (name: agent: !(agent.disable or false)) personalAgents);

in {
  config = mkIf cfg.enable (mkMerge [
    {
      programs.opencode = {
        enable = true;
        package = mkDefault flakePackages.opencode;
        settings = {
          theme = "dark";
          mcp = lib.mapAttrs shared.transformMcpForOpencode personalMcpServers;
          tools =
            # Disable per-agent MCP tools globally (those with enable = false)
            lib.mapAttrs' (name: server: lib.nameValuePair "${name}*" false)
            (lib.filterAttrs (name: server: !(server.enable or false))
              personalMcpServers);
        };
      };
    }
    (mkIf (opencodeAgents != { }) {
      programs.opencode.agents = opencodeAgents;
    })
    {
      programs.opencode.rules = personalMemory;
      programs.opencode.commands = shared.commandsAttrSet;
    }
  ]);
}
