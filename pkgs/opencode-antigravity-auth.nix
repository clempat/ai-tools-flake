{
  lib,
  stdenv,
  fetchFromGitHub,
}:

stdenv.mkDerivation rec {
  pname = "opencode-antigravity-auth";
  version = "1.3.1";

  src = fetchFromGitHub {
    owner = "NoeFabris";
    repo = "opencode-antigravity-auth";
    rev = "v${version}";
    hash = "sha256-n9VeE0HsTHpI3tB154z6mT0eeD2TC1xyXE6CeBgwHvs=";
  };

  dontBuild = true;
  dontConfigure = true;

  installPhase = ''
    runHook preInstall

    mkdir -p $out/share/opencode/plugins

    cp -r src/ $out/share/opencode/plugins/ 2>/dev/null || true
    cp *.ts $out/share/opencode/plugins/ 2>/dev/null || true
    cp package.json $out/share/opencode/plugins/

    runHook postInstall
  '';

  meta = with lib; {
    description = "Antigravity (Google) OAuth auth plugin for OpenCode - use Gemini/Claude models with Google credentials";
    homepage = "https://github.com/NoeFabris/opencode-antigravity-auth";
    license = licenses.mit;
    maintainers = [ ];
    platforms = platforms.all;
  };
}
