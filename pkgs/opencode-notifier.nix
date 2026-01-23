{
  lib,
  stdenv,
  fetchFromGitHub,
}:

stdenv.mkDerivation rec {
  pname = "opencode-notifier";
  version = "0.1.15";

  src = fetchFromGitHub {
    owner = "mohak34";
    repo = "opencode-notifier";
    rev = "v${version}";
    hash = "sha256-TPbz3WAPqoD/tJ3fB6g/jvvsM+OjVbuIwpo6dHjJwYM=";
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
    description = "OpenCode plugin for desktop notifications and sounds on permission, completion, and error events";
    homepage = "https://github.com/mohak34/opencode-notifier";
    license = licenses.mit;
    maintainers = [ ];
    platforms = platforms.all;
  };
}
