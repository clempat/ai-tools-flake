{ inputs }:
final: prev:
{
  # Custom packages - use consuming flake's nixpkgs
  spec-kit = final.callPackage ../pkgs/spec-kit.nix { };

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
