# Claude Code configuration module
{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

let
  cfg = config.programs.ai-tools;

  # Hardcoded personal configuration
  baseMcpServers = import ../config/mcps.nix;
  personalMemory = ../config/memory.md;

  # Override beads MCP server enable state based on ai-tools.beads.enable
  personalMcpServers =
    baseMcpServers
    // (optionalAttrs (baseMcpServers ? beads) {
      beads = baseMcpServers.beads // {
        enable = cfg.beads.enable;
      };
    });

in
{
  config = mkIf cfg.enable (mkMerge [
    {
      programs.claude-code = {
        enable = true;
        package = mkDefault pkgs.claude-code;
        mcpServers = personalMcpServers;
      };
    }
    {
      programs.claude-code.memory.source = personalMemory;
    }
    {
      programs.zsh.shellAliases.cc = "claude --dangerously-skip-permissions";
    }
  ]);
}
