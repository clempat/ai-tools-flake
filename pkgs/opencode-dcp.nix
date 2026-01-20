{
  lib,
  stdenv,
  fetchFromGitHub,
}:

stdenv.mkDerivation rec {
  pname = "opencode-dcp";
  version = "1.0.4";

  src = fetchFromGitHub {
    owner = "Tarquinen";
    repo = "opencode-dynamic-context-pruning";
    rev = "v${version}";
    hash = "sha256-+pIbY42WXxeYgg3TDdtRP+hWrAYZJq/HSbJKgQRndxw=";
  };

  # No build phase needed - OpenCode handles TypeScript directly
  dontBuild = true;
  dontConfigure = true;

  installPhase = ''
    runHook preInstall
    
    mkdir -p $out/share/opencode/plugins
    
    # Copy source files - OpenCode will handle TypeScript compilation
    cp -r src/ $out/share/opencode/plugins/ 2>/dev/null || true
    cp *.ts $out/share/opencode/plugins/ 2>/dev/null || true
    cp package.json $out/share/opencode/plugins/
    
    # Create the main plugin file that OpenCode can import
    cat > $out/share/opencode/plugins/opencode-dcp.ts <<EOF
// OpenCode Dynamic Context Pruning Plugin
export { default as DCPPlugin } from './index.js';
EOF
    
    runHook postInstall
  '';

  meta = with lib; {
    description = "Dynamic Context Pruning plugin that optimizes token usage by removing obsolete tool outputs";
    homepage = "https://github.com/Tarquinen/opencode-dynamic-context-pruning";
    license = licenses.mit;
    maintainers = [ ];
    platforms = platforms.all;
  };
}