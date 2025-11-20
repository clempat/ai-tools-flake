{
  description = "Unified AI tools configuration for Claude Code, OpenCode, and MCP servers";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    flake-parts.url = "github:hercules-ci/flake-parts";

    opencode.url = "github:sst/opencode";
    opencode.flake = false;
  };

  outputs = inputs@{ flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [ "x86_64-linux" "aarch64-linux" "aarch64-darwin" "x86_64-darwin" ];

      flake = {
        # Home-manager module
        homeManagerModules.default = ./modules/ai-tools.nix;

        # Default configurations
        lib.defaultConfig = {
          agents = import ./config/agents.nix;
          mcpServers = import ./config/mcps.nix;
          memory = ./config/memory.md;
        };

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
        };

        # Quick AI shell (without home-manager)
        devShells.default = pkgs'.mkShell {
          name = "ai-tools";
          packages = with pkgs'; [
            opencode
            claude-code
          ];
          
          shellHook = ''
            echo "AI Tools: opencode, claude-code"
            echo "For full config: use homeManagerModules.default"
          '';
        };
      };
    };
}
