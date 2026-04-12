{ inputs }:
final: prev:
{
  # Custom packages - use consuming flake's nixpkgs
  latchkey = final.callPackage ../pkgs/latchkey.nix { };
  spec-kit = final.callPackage ../pkgs/spec-kit.nix { };
  beads = final.callPackage ../pkgs/beads.nix { };
  bdui = final.callPackage ../pkgs/bdui.nix { };
  ccusage = final.callPackage ../pkgs/ccusage.nix { };
  ccusage-codex = final.callPackage ../pkgs/ccusage-codex.nix { };
  ccusage-opencode = final.callPackage ../pkgs/ccusage-opencode.nix { };

  # Packages from other flakes - only use upstream opencode when bun is new enough
  opencode =
    if builtins.compareVersions prev.bun.version "1.3.10" >= 0 then
      (inputs.opencode.packages.${final.stdenv.hostPlatform.system}.default or prev.opencode).overrideAttrs
        (old: {
          patches = (old.patches or [ ]) ++ [ ../patches/opencode-sort-tools.patch ];
          postPatch = (old.postPatch or "") + ''
            # Relax bun version requirement to match nixpkgs
            sed -i 's/"bun@[0-9.]*"/"bun@${prev.bun.version}"/' package.json
          '';
        })
    else
      prev.opencode;
  
  # Pi coding agent
  pi-coding-agent = final.callPackage ../pkgs/pi-coding-agent.nix { };

  # Tmux integration
  tmux-agent-indicator = final.callPackage ../pkgs/tmux-agent-indicator.nix { };
  tmux-ai-pane-browser = final.callPackage ../pkgs/tmux-ai-pane-browser.nix { };

  # Use packages from consuming flake's nixpkgs (respects their version choice)
  # These are available in nixpkgs unstable
  mcp-proxy = prev.mcp-proxy;
  claude-code = prev.claude-code;
} // (if (prev ? stdenv) && (prev.stdenv ? isLinux) && prev.stdenv.isLinux then {
  # chromium is Linux-only in nixpkgs; avoid eval failures on Darwin
  agent-browser = final.callPackage ../pkgs/agent-browser.nix { };
} else { })
