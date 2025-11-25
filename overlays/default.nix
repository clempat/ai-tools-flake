{ inputs }:
final: prev:
let
  # Always use this flake's nixpkgs (unstable) - ignores follows
  unstable = import inputs.nixpkgs {
    inherit (final) system;
    config.allowUnfree = true;
  };
in {
  # Custom packages
  spec-kit = final.callPackage ../pkgs/spec-kit.nix { };

  # All packages from this flake's unstable nixpkgs
  opencode = inputs.opencode.packages.${final.system}.default or unstable.opencode;
  mcp-proxy = unstable.mcp-proxy;
  claude-code = unstable.claude-code;
}
