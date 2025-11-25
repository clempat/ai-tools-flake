# Unified AI tools configuration module
# Orchestrates opencode, claude-code, and claude-desktop configurations
self: { config, lib, pkgs, ... }:

with lib;

let
  cfg = config.programs.ai-tools;
  
  # Get packages from self for the current system
  flakePackages = self.packages.${pkgs.stdenv.hostPlatform.system};

in {
  imports = [
    (import ./opencode.nix { inherit flakePackages; })
    (import ./claude-code.nix { inherit flakePackages; })
  ];

  options.programs.ai-tools = {
    enable = mkEnableOption "unified AI tools configuration";
  };
}
