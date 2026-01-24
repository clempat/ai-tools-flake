{
  lib,
  stdenvNoCC,
  fetchurl,
  makeWrapper,
  nodejs_20,
}:

stdenvNoCC.mkDerivation {
  pname = "ccusage";
  version = "18.0.5";

  src = fetchurl {
    url = "https://registry.npmjs.org/ccusage/-/ccusage-18.0.5.tgz";
    sha256 = "sha256-Co9+jFDk4WmefrDnJvladjjYk+XHhYYEKNKb9MbrkU8=";
  };

  sourceRoot = "package";
  nativeBuildInputs = [ makeWrapper ];

  installPhase = ''
    runHook preInstall
    mkdir -p $out/lib/ccusage $out/bin
    cp -R . $out/lib/ccusage
    makeWrapper ${nodejs_20}/bin/node $out/bin/ccusage \
      --add-flags $out/lib/ccusage/dist/index.js
    runHook postInstall
  '';

  meta = {
    description = "Usage analysis tool for Claude Code";
    homepage = "https://github.com/ryoppippi/ccusage";
    license = lib.licenses.mit;
    mainProgram = "ccusage";
  };
}
