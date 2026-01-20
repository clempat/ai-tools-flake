{ inputs }:
final: prev:
{
  # Custom packages - use consuming flake's nixpkgs
  spec-kit = final.callPackage ../pkgs/spec-kit.nix { };
  beads = final.callPackage ../pkgs/beads.nix { };
  bdui = final.callPackage ../pkgs/bdui.nix { };
  agent-browser = final.callPackage ../pkgs/agent-browser.nix { };
  
  # OpenCode plugins
  opencode-beads = final.callPackage ../pkgs/opencode-beads.nix { };
  opencode-skills = final.callPackage ../pkgs/opencode-skills.nix { };
  opencode-gemini-auth = final.callPackage ../pkgs/opencode-gemini-auth.nix { };
  opencode-dcp = final.callPackage ../pkgs/opencode-dcp.nix { };
  opencode-md-table-formatter = final.callPackage ../pkgs/opencode-md-table-formatter.nix { };

  # Packages from other flakes - prefer consuming flake's versions
  opencode = inputs.opencode.packages.${final.system}.default or prev.opencode;
  
  # Use packages from consuming flake's nixpkgs (respects their version choice)
  # These are available in nixpkgs unstable
  mcp-proxy = prev.mcp-proxy;
  claude-code = prev.claude-code;
}
