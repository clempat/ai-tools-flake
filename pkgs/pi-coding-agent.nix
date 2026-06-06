{
  lib,
  writeShellScriptBin,
  nodejs_22,
}:

let
  # renovate: datasource=npm depName=@mariozechner/pi-coding-agent
  version = "0.73.1";
in
writeShellScriptBin "pi" ''
  export PATH="${nodejs_22}/bin:$PATH"
  exec npx @mariozechner/pi-coding-agent@${version} "$@"
''
