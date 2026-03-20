{
  lib,
  stdenvNoCC,
  fetchurl,
  makeWrapper,
  nodejs,
  chromium,
}:

let
  version = "0.21.2";
in
stdenvNoCC.mkDerivation {
  pname = "agent-browser";
  inherit version;

  src = fetchurl {
    url = "https://registry.npmjs.org/agent-browser/-/agent-browser-${version}.tgz";
    hash = "sha256-CnN2wYmPq/aFNPWwrCX8AhVReyuX/3xNjk5YKlk/oY=";
  };

  sourceRoot = "package";
  nativeBuildInputs = [ makeWrapper ];

  installPhase =
    let
      nativeBin = {
        "x86_64-linux" = "agent-browser-linux-x64";
        "aarch64-linux" = "agent-browser-linux-arm64";
        "x86_64-darwin" = "agent-browser-darwin-x64";
        "aarch64-darwin" = "agent-browser-darwin-arm64";
      }.${stdenvNoCC.hostPlatform.system} or (throw "Unsupported platform: ${stdenvNoCC.hostPlatform.system}");
    in
    ''
      runHook preInstall
      mkdir -p $out/lib/agent-browser $out/bin

      cp -R . $out/lib/agent-browser/

      # Try native binary first, fall back to Node.js entrypoint
      if [ -f "$out/lib/agent-browser/bin/${nativeBin}" ]; then
        chmod +x "$out/lib/agent-browser/bin/${nativeBin}"
        makeWrapper "$out/lib/agent-browser/bin/${nativeBin}" $out/bin/agent-browser \
          --set CHROME_PATH "${chromium}/bin/chromium" \
          --set PLAYWRIGHT_CHROMIUM_EXECUTABLE_PATH "${chromium}/bin/chromium"
      else
        makeWrapper ${nodejs}/bin/node $out/bin/agent-browser \
          --add-flags "$out/lib/agent-browser/bin/agent-browser.js" \
          --set CHROME_PATH "${chromium}/bin/chromium" \
          --set PLAYWRIGHT_CHROMIUM_EXECUTABLE_PATH "${chromium}/bin/chromium"
      fi

      runHook postInstall
    '';

  meta = {
    description = "Browser automation CLI for AI agents";
    homepage = "https://github.com/vercel-labs/agent-browser";
    license = lib.licenses.asl20;
    mainProgram = "agent-browser";
    platforms = lib.platforms.linux; # chromium dependency
  };
}
