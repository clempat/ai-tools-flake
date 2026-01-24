{
  lib,
  stdenvNoCC,
  fetchurl,
  makeWrapper,
  nodejs_20,
}:

stdenvNoCC.mkDerivation {
  pname = "ccusage-opencode";
  version = "18.0.5";

  src = fetchurl {
    url = "https://registry.npmjs.org/@ccusage/opencode/-/opencode-18.0.5.tgz";
    sha256 = "sha256-5bgHdd2Xd52zcBtVKcEKyd5Vd78pLaPmyFBPm2Sq+Ko=";
  };

  sourceRoot = "package";
  nativeBuildInputs = [ makeWrapper ];

  installPhase = ''
    runHook preInstall
    mkdir -p $out/lib/ccusage-opencode $out/bin
    cp -R . $out/lib/ccusage-opencode
    makeWrapper ${nodejs_20}/bin/node $out/bin/ccusage-opencode \
      --add-flags $out/lib/ccusage-opencode/dist/index.js
    runHook postInstall
  '';

  meta = {
    description = "Usage analysis tool for OpenCode";
    homepage = "https://github.com/ryoppippi/ccusage";
    license = lib.licenses.mit;
    mainProgram = "ccusage-opencode";
  };
}
