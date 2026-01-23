{
  lib,
  stdenv,
  fetchFromGitHub,
}:

stdenv.mkDerivation rec {
  pname = "opencode-codex-auth";
  version = "4.4.0";

  src = fetchFromGitHub {
    owner = "numman-ali";
    repo = "opencode-openai-codex-auth";
    rev = "v${version}";
    hash = "sha256-Kz2n5BpHqirc2AxE4huJJ5LOPyy9jVOydQnqE+AlZOc=";
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
    description = "OpenAI ChatGPT (Codex backend) OAuth auth plugin for OpenCode - use ChatGPT Plus/Pro subscription";
    homepage = "https://github.com/numman-ali/opencode-openai-codex-auth";
    license = licenses.mit;
    maintainers = [ ];
    platforms = platforms.all;
  };
}
