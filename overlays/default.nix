{ inputs, ... }:
final: prev: {
  # Use a wrapper for opencode that sets up proper library paths for ARM64
  opencode = prev.writeShellScriptBin "opencode" ''
    export LD_LIBRARY_PATH="${prev.stdenv.cc.cc.lib}/lib:${prev.glibc}/lib:$LD_LIBRARY_PATH"
    exec ${prev.opencode}/bin/opencode "$@"
  '';
}
