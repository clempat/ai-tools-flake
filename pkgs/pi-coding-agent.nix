{
  lib,
  buildNpmPackage,
  nodejs_22,
  makeWrapper,
}:

buildNpmPackage rec {
  pname = "pi-coding-agent";
  version = "0.62.0";

  # Use a wrapper package.json that pulls in the published npm package
  src = lib.fileset.toSource {
    root = ./.;
    fileset = lib.fileset.unions [
      ./pi-coding-agent-package.json
      ./pi-coding-agent-package-lock.json
    ];
  };

  postPatch = ''
    cp pi-coding-agent-package.json package.json
    cp pi-coding-agent-package-lock.json package-lock.json
  '';

  nodejs = nodejs_22;
  npmDepsHash = "sha256-jY4cqa7+Z5xZyYKUg34Mcnp9r35fs7j/2YBsNNvwhrM=";

  dontNpmBuild = true;

  nativeBuildInputs = [ makeWrapper ];

  installPhase = ''
    runHook preInstall
    mkdir -p $out/lib/pi-coding-agent $out/bin

    cp -R node_modules $out/lib/pi-coding-agent/

    makeWrapper ${nodejs_22}/bin/node $out/bin/pi \
      --add-flags "$out/lib/pi-coding-agent/node_modules/@mariozechner/pi-coding-agent/dist/cli.js" \
      --set NODE_PATH "$out/lib/pi-coding-agent/node_modules"

    runHook postInstall
  '';

  meta = {
    description = "Pi - AI coding agent CLI";
    homepage = "https://github.com/badlogic/pi-mono";
    license = lib.licenses.mit;
    mainProgram = "pi";
  };
}
