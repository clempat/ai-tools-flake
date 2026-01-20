# Unified AI tools configuration module
# Orchestrates opencode, claude-code, and claude-desktop configurations
{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.programs.ai-tools;

in {
  imports = [
    ./opencode.nix
    ./claude-code.nix
    ./claude-desktop.nix
  ];

  options.programs.ai-tools = {
    enable = mkEnableOption "unified AI tools configuration";
    
    beads = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = "Enable beads issue tracker integration";
      };
      
      ui = mkOption {
        type = types.bool;
        default = true;
        description = "Enable bdui TUI for beads issue tracker";
      };
      
      hooks = {
        enable = mkOption {
          type = types.bool;
          default = true;
          description = "Enable beads hooks for Claude Code (SessionStart, PreCompact)";
        };
        
        stealth = mkOption {
          type = types.bool;
          default = false;
          description = "Use stealth mode for beads hooks (no git operations)";
        };
      };
    };
  };

  config = mkIf cfg.enable {
    # Install beads (bd) - git-backed issue tracker for AI agents
    # Install uv - Python package manager needed for beads-mcp
    # Install bdui - TUI for beads issue tracker
    home.packages = with pkgs; mkMerge [
      (mkIf cfg.beads.enable [ beads uv ])
      (mkIf (cfg.beads.enable && cfg.beads.ui) [ bdui ])
    ];
  };
}
