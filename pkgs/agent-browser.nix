{ lib, writeShellScriptBin, nodejs, chromium }:

(writeShellScriptBin "agent-browser" ''
  set -euo pipefail

  # Set Chrome path to nix chromium
  export CHROME_PATH="${chromium}/bin/chromium"
  export PLAYWRIGHT_CHROMIUM_EXECUTABLE_PATH="${chromium}/bin/chromium"

  # Use npx to run agent-browser (downloads on first use if needed)
  exec ${nodejs}/bin/npx -y agent-browser@latest "$@"
'').overrideAttrs (oldAttrs: {
  meta = {
    description = "Browser automation CLI for AI agents";
    longDescription = ''
      agent-browser is a headless browser automation CLI for AI agents with
      a fast Rust implementation and Node.js fallback.

      This package provides a wrapper that uses npx to run agent-browser with
      the Nix-provided chromium browser. No manual chromium installation needed.

      Note: First run may download the agent-browser package from npm.
    '';
    homepage = "https://github.com/vercel-labs/agent-browser";
    license = lib.licenses.asl20;
    maintainers = [ ];
    mainProgram = "agent-browser";
    platforms = lib.platforms.unix;
  };
})
