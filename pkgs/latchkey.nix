{ lib, buildNpmPackage, fetchFromGitHub, nodejs_22, makeWrapper, playwright-driver }:

buildNpmPackage rec {
  pname = "latchkey";
  version = "2.5.3";

  src = fetchFromGitHub {
    owner = "imbue-ai";
    repo = "latchkey";
    rev = version;
    hash = "sha256-Rv/tCmd9RH27HBtKFtoq1b1qrpAc6LbrFvrOvXqXHRQ=";
  };

  nodejs = nodejs_22;
  npmDepsHash = "sha256-h/tYUyniaz87NN5UFeyKg1sMiyeJfqVzYCeDLw+0kzo=";

  nativeBuildInputs = [ makeWrapper ];

  npmBuildScript = "build";

  # Skip playwright browser download during npm install
  env.PLAYWRIGHT_SKIP_BROWSER_DOWNLOAD = "1";

  installPhase = ''
    runHook preInstall
    mkdir -p $out/lib/latchkey $out/bin

    cp -R dist $out/lib/latchkey/
    cp -R node_modules $out/lib/latchkey/
    cp package.json $out/lib/latchkey/

    # Copy skills directory (needed at runtime)
    cp -R skills $out/lib/latchkey/ 2>/dev/null || true

    makeWrapper ${nodejs_22}/bin/node $out/bin/latchkey \
      --add-flags "$out/lib/latchkey/dist/src/cli.js" \
      --set NODE_PATH "$out/lib/latchkey/node_modules" \
      --set PLAYWRIGHT_BROWSERS_PATH "${playwright-driver.browsers}"

    runHook postInstall
  '';

  meta = {
    description = "A command-line tool that injects credentials to curl requests to known public APIs";
    homepage = "https://github.com/imbue-ai/latchkey";
    license = lib.licenses.mit;
    mainProgram = "latchkey";
  };
}
