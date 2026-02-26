{
  description = "Unified AI tools configuration for Claude Code, OpenCode, and MCP servers";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    flake-parts.url = "github:hercules-ci/flake-parts";

    opencode.url = "github:sst/opencode";
    opencode.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs =
    inputs@{ self, flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [
        "x86_64-linux"
        "aarch64-linux"
        "aarch64-darwin"
        "x86_64-darwin"
      ];

      flake = {
        # Home Manager module
        homeManagerModules.default = import ./modules/ai-tools.nix;

        # Overlay: uses inputs.nixpkgs (via follows) for packages missing in consumer's nixpkgs
        overlays.default = import ./overlays/default.nix { inherit inputs; };
      };

      perSystem =
        {
          pkgs,
          system,
          lib,
          ...
        }:
        {
          # Configure nixpkgs with overlay
          _module.args.pkgs = import inputs.nixpkgs {
            inherit system;
            config.allowUnfree = true;
            overlays = [ self.overlays.default ];
          };

          # Packages from overlay
          packages = {
            inherit (pkgs)
              spec-kit
              beads
              bdui
              ccusage
              ccusage-codex
              ccusage-opencode
              opencode
              ;
          } // lib.optionalAttrs pkgs.stdenv.isLinux {
            inherit (pkgs) agent-browser; # chromium only available on Linux
          };

          # Quick AI shell (without home-manager)
          devShells.default = pkgs.mkShell {
            name = "ai-tools";
            packages = [
              pkgs.opencode
              pkgs.claude-code
              pkgs.beads
              pkgs.bdui
              pkgs.gh # Required for ticket-driven-developer agent
            ] ++ lib.optionals pkgs.stdenv.isLinux [
              pkgs.agent-browser # chromium only available on Linux
            ];

            shellHook = ''
              echo "AI Tools: opencode, claude-code, beads (bd), bdui, agent-browser, gh"
              echo "For full config: use nixosModules.default"
            '';
          };
        };
    };
}
