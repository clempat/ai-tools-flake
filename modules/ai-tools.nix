# Unified AI tools configuration module
# Orchestrates opencode, claude-code, and claude-desktop configurations
{ inputs }:
{ config, lib, pkgs, ... }:

with lib;

let cfg = config.programs.ai-tools;

in {
  imports = [
    (import ./opencode.nix { inherit inputs; })
    ./claude-code.nix
    ./claude-desktop.nix
  ];

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
          "Whether to apply recommended oh-my-opencode-slim agent model routing defaults.";
      };
      modelByAgent = mkOption {
        type = types.attrsOf types.str;
        default = { };
        description =
          "Per oh-my-opencode-slim agent model overrides (agent-name -> provider/model key). Takes precedence over recommended routing.";
      };
      plugins = mkOption {
        type = types.listOf types.str;
        default = [
          "opencode-beads@0.6.0"
          "opencode-antigravity-auth@1.6.0"
          "@tarquinen/opencode-dcp@2.1.8"
          "@franlol/opencode-md-table-formatter@0.0.6"
          "oh-my-opencode-slim@0.8.3"
          "opencode-openai-codex-auth@4.4.0"
          "opencode-websearch-cited@1.2.0"
          "@simonwjackson/opencode-direnv@2025.1211.9"
        ];
        description = "OpenCode npm plugins (name@version).";
      };
      defaultEnabledMcpTools = mkOption {
        type = types.listOf types.str;
        default = [ ];
        example = [ "refs" "exa" ];
        description =
          "MCP tool prefixes enabled by default in OpenCode tools policy. Empty means default-deny for all MCP tools unless enabled by agent/tool overrides.";
      };
      enableAllMcpToolsByDefault = mkOption {
        type = types.bool;
        default = false;
        description =
          "Enable all configured MCP tools by default in OpenCode. Prefer false for least-privilege policy.";
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
    tmux = {
      enable = mkOption {
        type = types.bool;
        default = false;
        description =
          "Enable tmux AI agent integrations (status bar indicator, pane browser)";
      };
      agentIndicator.enable = mkOption {
        type = types.bool;
        default = true;
        description =
          "Enable tmux-agent-indicator hooks for Claude Code and OpenCode";
      };
      fzfPaneBrowser.enable = mkOption {
        type = types.bool;
        default = true;
        description = "Install fzf-based tmux AI pane browser";
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
        [ pi-coding-agent latchkey ]
        (mkIf cfg.beads.enable [ beads uv ])
        (mkIf (cfg.beads.enable && cfg.beads.ui) [ bdui ])
        (mkIf pkgs.stdenv.isLinux [ agent-browser ])
        (mkIf (cfg.tmux.enable && cfg.tmux.fzfPaneBrowser.enable)
          [ tmux-ai-pane-browser ])
      ];

    programs.codex.enable = cfg.codex.enable;

    services.ollama = mkIf (cfg.ollama.enable && !pkgs.stdenv.isDarwin) {
      inherit (cfg.ollama) acceleration;
      enable = true;
      environmentVariables = { OLLAMA_CONTEXT_LENGTH = "32768"; };
    };

  };
}
