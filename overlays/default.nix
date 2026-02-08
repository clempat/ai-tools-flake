{ inputs }:
final: prev:
{
  # Custom packages - use consuming flake's nixpkgs
  spec-kit = final.callPackage ../pkgs/spec-kit.nix { };
  beads = final.callPackage ../pkgs/beads.nix { };
  bdui = final.callPackage ../pkgs/bdui.nix { };
  ccusage = final.callPackage ../pkgs/ccusage.nix { };
  ccusage-codex = final.callPackage ../pkgs/ccusage-codex.nix { };
  ccusage-opencode = final.callPackage ../pkgs/ccusage-opencode.nix { };

  # Packages from other flakes - prefer consuming flake's versions
  opencode = inputs.opencode.packages.${final.stdenv.hostPlatform.system}.default or prev.opencode;
  
  # Use packages from consuming flake's nixpkgs (respects their version choice)
  # These are available in nixpkgs unstable
  mcp-proxy = prev.mcp-proxy;
  claude-code = prev.claude-code;
} // prev.lib.optionalAttrs prev.stdenv.isLinux {
  # chromium is Linux-only in nixpkgs; avoid eval failures on Darwin
  agent-browser = final.callPackage ../pkgs/agent-browser.nix { };
}
