{
  lib,
  stdenv,
  fetchFromGitHub,
}:

stdenv.mkDerivation rec {
  pname = "opencode-beads";
  version = "0.2.2";

  src = fetchFromGitHub {
    owner = "joshuadavidthomas";
    repo = "opencode-beads";
    rev = "v${version}";
    hash = "sha256-j0VCerW+RAfDhg7CCdWqpz5dtAINFL+0KkRhy4a5fLU=";
  };

  # No build phase needed - OpenCode handles TypeScript directly
  dontBuild = true;
  dontConfigure = true;

  installPhase = ''
    runHook preInstall
    
    mkdir -p $out/share/opencode/plugins
    
    # Copy source files - OpenCode will handle TypeScript compilation
    cp -r src/ $out/share/opencode/plugins/
    cp -r vendor/ $out/share/opencode/plugins/
    cp package.json $out/share/opencode/plugins/
    
    # Create the main plugin file that OpenCode can import
    cat > $out/share/opencode/plugins/opencode-beads.ts <<EOF
// OpenCode Beads Plugin
export { BeadsPlugin } from './src/plugin.js';
EOF
    
    runHook postInstall
  '';

  meta = with lib; {
    description = "A plugin for OpenCode that provides integration with the beads issue tracker";
    homepage = "https://github.com/joshuadavidthomas/opencode-beads";
    license = licenses.mit;
    maintainers = [ ];
    platforms = platforms.all;
  };
}