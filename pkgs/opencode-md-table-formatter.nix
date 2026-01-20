{
  lib,
  stdenv,
  fetchFromGitHub,
}:

stdenv.mkDerivation rec {
  pname = "opencode-md-table-formatter";
  version = "0.0.3";

  src = fetchFromGitHub {
    owner = "franlol";
    repo = "opencode-md-table-formatter";
    rev = "v${version}";
    hash = "sha256-YkS2pohLT9s+V+I0sd+RfNtcetZLMC6o9A2WXeZK+S8=";
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
    cat > $out/share/opencode/plugins/opencode-md-table-formatter.ts <<EOF
// OpenCode Markdown Table Formatter Plugin
export { default as MDTableFormatterPlugin } from './index.js';
EOF
    
    runHook postInstall
  '';

  meta = with lib; {
    description = "Markdown table formatter plugin for OpenCode with concealment mode support";
    homepage = "https://github.com/franlol/opencode-md-table-formatter";
    license = licenses.mit;
    maintainers = [ ];
    platforms = platforms.all;
  };
}