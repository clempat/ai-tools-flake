{
  lib,
  stdenv,
  fetchFromGitHub,
}:

stdenv.mkDerivation rec {
  pname = "opencode-websearch-cited";
  version = "1.2.0";

  src = fetchFromGitHub {
    owner = "ghoulr";
    repo = "opencode-websearch-cited";
    rev = "v${version}";
    hash = "sha256-E83yoMRQjEdzTwrUQCl4GrN1Jw2k5FyMgKjoiDvBILc=";
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
    description = "OpenCode plugin that provides LLM cited web search";
    homepage = "https://github.com/ghoulr/opencode-websearch-cited";
    license = licenses.mit;
    maintainers = [ ];
    platforms = platforms.all;
  };
}
