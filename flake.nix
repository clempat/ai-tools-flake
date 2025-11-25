{
  description = "Unified AI tools configuration for Claude Code, OpenCode, and MCP servers";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    flake-parts.url = "github:hercules-ci/flake-parts";

    opencode.url = "github:sst/opencode";
  };

  outputs = inputs@{ self, flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [ "x86_64-linux" "aarch64-linux" "aarch64-darwin" "x86_64-darwin" ];

      flake = {
        # Home-manager module (pass self for package access)
        homeManagerModules.default = import ./modules/ai-tools.nix self;

        # Overlays
        overlays.default = import ./overlays/default.nix { inherit inputs; };
      };

      perSystem = { config, self', inputs', pkgs, system, ... }: let
        # Allow unfree packages
        pkgs' = import inputs.nixpkgs {
          inherit system;
          config.allowUnfree = true;
        };
      in {
        # Packages
        packages = {
          spec-kit = pkgs'.callPackage ./pkgs/spec-kit.nix { };

          # Export opencode (from sst/opencode flake if available, else nixpkgs)
          opencode = if inputs.opencode ? packages.${system}.default
            then inputs.opencode.packages.${system}.default
            else pkgs'.opencode;

          # Export claude-code (from unstable nixpkgs)
          claude-code = pkgs'.claude-code;
        };

        # Quick AI shell (without home-manager)
        devShells.default = pkgs'.mkShell {
          name = "ai-tools";
          packages = [
            self'.packages.opencode
            pkgs'.claude-code
            pkgs'.gh  # Required for ticket-driven-developer agent
          ];
          
          shellHook = ''
            echo "AI Tools: opencode, claude-code, gh"
            echo "For full config: use homeManagerModules.default"
          '';
        };
      };
    };
}
