{ inputs }:
final: prev:
{
  # Fix broken mcp package - upstream removed time.sleep(0.1) from test_integration.py
  # TODO: Remove this override once nixpkgs-unstable includes commit fa82e35
  python3Packages = prev.python3Packages.overrideScope (pyFinal: pyPrev: {
    mcp = pyPrev.mcp.overrideAttrs (old: {
      postPatch = prev.lib.optionalString prev.stdenv.buildPlatform.isDarwin ''
        substituteInPlace tests/client/test_stdio.py \
          --replace-fail "time.sleep(0.1)" "time.sleep(1)"
      '';
    });
  });

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
