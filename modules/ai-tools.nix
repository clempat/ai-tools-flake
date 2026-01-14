# Unified AI tools configuration module
# Orchestrates opencode, claude-code, and claude-desktop configurations
{ config, lib, pkgs, ... }:

with lib;

let cfg = config.programs.ai-tools;

in {
  imports = [ ./opencode.nix ./claude-code.nix ./claude-desktop.nix ];

  options.programs.ai-tools = {
    enable = mkEnableOption "unified AI tools configuration";
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
  };

  config = mkIf cfg.enable {
    # Install beads (bd) - git-backed issue tracker for AI agents
    home.packages = [ pkgs.beads ];

    services.ollama = mkIf (cfg.ollama.enable && !pkgs.stdenv.isDarwin) {
      inherit acceleration;
      enable = true;
      environmentVariables = { OLLAMA_CONTEXT_LENGTH = "32768"; };
    };
  };
}
