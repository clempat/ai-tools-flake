{
  lib,
  writeShellScriptBin,
  nodejs_22,
}:

let
  # renovate: datasource=npm depName=@earendil-works/pi-coding-agent
  version = "0.84.2";
in
writeShellScriptBin "pi" ''
  export PATH="${nodejs_22}/bin:$PATH"
  exec npx @earendil-works/pi-coding-agent@${version} "$@"
''
