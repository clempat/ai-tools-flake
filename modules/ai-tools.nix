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
  };
}
