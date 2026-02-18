# Unified AI tools configuration module
# Orchestrates opencode, claude-code, and claude-desktop configurations
{ config, lib, pkgs, ... }:

with lib;

let cfg = config.programs.ai-tools;

in {
  imports = [ ./opencode.nix ./claude-code.nix ./claude-desktop.nix ];

  options.programs.ai-tools = {
    enable = mkEnableOption "unified AI tools configuration";
    opencode = {
      model = mkOption {
        type = types.str;
        default = "openai/gpt-5.3-codex";
        description = "Default OpenCode model (provider/model key).";
      };
      useRecommendedRouting = mkOption {
        type = types.bool;
        default = true;
        description =
          "Whether to apply recommended oh-my-opencode agent/category model routing defaults.";
      };
      modelByAgent = mkOption {
        type = types.attrsOf types.str;
        default = { };
        description =
          "Per oh-my-opencode built-in agent model overrides (agent-name -> provider/model key). Takes precedence over recommended routing.";
      };
      modelByCategory = mkOption {
        type = types.attrsOf types.str;
        default = { };
        description =
          "Per oh-my-opencode category model overrides (category-name -> provider/model key). Takes precedence over recommended routing.";
      };
      plugins = mkOption {
        type = types.listOf types.str;
        default = [
          "opencode-beads@0.4.0"
          "opencode-antigravity-auth@1.5.1"
          "@tarquinen/opencode-dcp@2.1.3"
          "@franlol/opencode-md-table-formatter@0.0.3"
          "oh-my-opencode@3.5.5"
          "opencode-openai-codex-auth@4.4.0"
          "opencode-websearch-cited@1.2.0"
          "@simonwjackson/opencode-direnv@2025.1211.9"
        ];
        description = "OpenCode npm plugins (name@version).";
      };
    };
    codex = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = "Whether to enable Codex service";
      };
    };
    ollama = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = "Whether to enable Ollama service";
      };
      acceleration = mkOption {
        type = types.nullOr (types.enum [ false "rocm" "cuda" ]);
        default = null;
        description = "What interface to use for hardware acceleration";
      };
    };
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
          description =
            "Enable beads hooks for Claude Code (SessionStart, PreCompact)";
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
    home.packages = with pkgs;
      mkMerge [
        (mkIf cfg.beads.enable [ beads uv ])
        (mkIf (cfg.beads.enable && cfg.beads.ui) [ bdui ])
      ];

    programs.codex.enable = cfg.codex.enable;

    services.ollama = mkIf (cfg.ollama.enable && !pkgs.stdenv.isDarwin) {
      inherit (cfg.ollama) acceleration;
      enable = true;
      environmentVariables = { OLLAMA_CONTEXT_LENGTH = "32768"; };
    };

  };
}
