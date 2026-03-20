# Helper to package self-contained npm tarballs (0 runtime dependencies).
# Usage:
#   mkNpmPackage {
#     pname = "ccusage";
#     version = "18.0.5";
#     url = "https://registry.npmjs.org/ccusage/-/ccusage-18.0.5.tgz";
#     hash = "sha256-Co9+jFDk4WmefrDnJvladjjYk+XHhYYEKNKb9MbrkU8=";
#     description = "Usage analysis tool for Claude Code";
#     homepage = "https://github.com/ryoppippi/ccusage";
#     nodejs = nodejs_20;
#   }
{
  lib,
  stdenvNoCC,
  fetchurl,
  makeWrapper,
}:

{
  pname,
  version,
  url,
  hash,
  nodejs,
  description ? "",
  homepage ? "",
  license ? lib.licenses.mit,
  binName ? pname,
  entryPoint ? "dist/index.js",
  extraWrapperArgs ? [ ],
  platforms ? lib.platforms.all,
}:

stdenvNoCC.mkDerivation {
  inherit pname version;

  src = fetchurl { inherit url hash; };

  sourceRoot = "package";
  nativeBuildInputs = [ makeWrapper ];

  installPhase = ''
    runHook preInstall
    mkdir -p $out/lib/${pname} $out/bin
    cp -R . $out/lib/${pname}
    makeWrapper ${nodejs}/bin/node $out/bin/${binName} \
      --add-flags $out/lib/${pname}/${entryPoint} \
      ${lib.concatStringsSep " " extraWrapperArgs}
    runHook postInstall
  '';

  meta = {
    inherit description homepage license platforms;
    mainProgram = binName;
  };
}
