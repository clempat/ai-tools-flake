# Claude Code configuration module
# Settings (hooks, statusLine, mcpServers, permissions) are managed by
# ai-config/settings.local.json — nix only handles package + plugins.
{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

let
  cfg = config.programs.ai-tools;
in
{
  config = mkIf cfg.enable (mkMerge [
    {
      programs.claude-code = {
        enable = true;
        package = mkDefault pkgs.claude-code;
      };
    }
    {
      programs.zsh.shellAliases.cc = "claude --dangerously-skip-permissions";
    }
  ]);
}
