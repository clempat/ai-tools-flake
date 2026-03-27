{
  lib,
  writeShellScriptBin,
  nodejs_22,
}:

let
  version = "0.63.1";
in
writeShellScriptBin "pi" ''
  export PATH="${nodejs_22}/bin:$PATH"
  exec npx @mariozechner/pi-coding-agent@${version} "$@"
''
