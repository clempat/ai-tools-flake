{ inputs }:
final: prev:
{
  # Custom packages - use consuming flake's nixpkgs
  spec-kit = final.callPackage ../pkgs/spec-kit.nix { };
  beads = final.callPackage ../pkgs/beads.nix { };

  # Packages from other flakes - prefer consuming flake's versions
  opencode = inputs.opencode.packages.${final.system}.default or prev.opencode;
  
  # Use packages from consuming flake's nixpkgs (respects their version choice)
  # These are available in nixpkgs unstable
  mcp-proxy = prev.mcp-proxy;
  claude-code = prev.claude-code;
}
