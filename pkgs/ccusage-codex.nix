{
  lib,
  stdenvNoCC,
  fetchurl,
  makeWrapper,
  nodejs_20,
}:

stdenvNoCC.mkDerivation {
  pname = "ccusage-codex";
  version = "18.0.5";

  src = fetchurl {
    url = "https://registry.npmjs.org/@ccusage/codex/-/codex-18.0.5.tgz";
    sha256 = "sha256-q4tHdc7sIz8qao47BgYqLzEDJUbsUn4MzoHxp1NyzPI=";
  };

  sourceRoot = "package";
  nativeBuildInputs = [ makeWrapper ];

  installPhase = ''
    runHook preInstall
    mkdir -p $out/lib/ccusage-codex $out/bin
    cp -R . $out/lib/ccusage-codex
    makeWrapper ${nodejs_20}/bin/node $out/bin/ccusage-codex \
      --add-flags $out/lib/ccusage-codex/dist/index.js
    runHook postInstall
  '';

  meta = {
    description = "Usage analysis tool for OpenAI Codex";
    homepage = "https://github.com/ryoppippi/ccusage";
    license = lib.licenses.mit;
    mainProgram = "ccusage-codex";
  };
}
