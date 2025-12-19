{
  description =
    "Unified AI tools configuration for Claude Code, OpenCode, and MCP servers";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    flake-parts.url = "github:hercules-ci/flake-parts";

    opencode.url = "github:sst/opencode";
  };

  outputs = inputs@{ self, flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems =
        [ "x86_64-linux" "aarch64-linux" "aarch64-darwin" "x86_64-darwin" ];

      flake = {
        # Home-manager module
        homeManagerModules.default = import ./modules/ai-tools.nix;

        # Overlay: uses inputs.nixpkgs (via follows) for packages missing in consumer's nixpkgs
        overlays.default = import ./overlays/default.nix { inherit inputs; };
      };

      perSystem = { config, self', inputs', pkgs, system, ... }: {
        # Configure nixpkgs with overlay
        _module.args.pkgs = import inputs.nixpkgs {
          inherit system;
          config.allowUnfree = true;
          overlays = [ self.overlays.default ];
        };

        # Packages from overlay
        packages = { inherit (pkgs) spec-kit beads opencode; };

        # Quick AI shell (without home-manager)
        devShells.default = pkgs.mkShell {
          name = "ai-tools";
          packages = [
            pkgs.opencode
            pkgs.claude-code
            pkgs.beads
            pkgs.gh # Required for ticket-driven-developer agent
          ];

          shellHook = ''
            echo "AI Tools: opencode, claude-code, beads (bd), gh"
            echo "For full config: use homeManagerModules.default"
          '';
        };
      };
    };
}
