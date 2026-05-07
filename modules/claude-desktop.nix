# Claude Desktop configuration module
#
# Claude Desktop config is managed manually (not by Nix)
# to allow setting API keys/secrets without them going through the Nix store.
# Config location: ~/Library/Application Support/Claude/claude_desktop_config.json
{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.programs.ai-tools;
  isDarwin = pkgs.stdenv.isDarwin;
in {
  config = mkIf (cfg.enable && isDarwin) {
    home.packages = [ pkgs.mcp-proxy ];
  };
}
