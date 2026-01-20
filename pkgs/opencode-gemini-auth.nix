{
  lib,
  stdenv,
  fetchFromGitHub,
}:

stdenv.mkDerivation rec {
  pname = "opencode-gemini-auth";
  version = "1.3.3";

  src = fetchFromGitHub {
    owner = "jenslys";
    repo = "opencode-gemini-auth";
    rev = "v${version}";
    hash = "sha256-E47EeQy3JBWZys9GQWWY126wVG0/i9iW6X/d4vHQzyg=";
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
    cat > $out/share/opencode/plugins/opencode-gemini-auth.ts <<EOF
// OpenCode Gemini Auth Plugin
export { default as GeminiAuthPlugin } from './index.js';
EOF
    
    runHook postInstall
  '';

  meta = with lib; {
    description = "Authenticates OpenCode CLI with Google account to use existing Gemini plan and quotas";
    homepage = "https://github.com/jenslys/opencode-gemini-auth";
    license = licenses.mit;
    maintainers = [ ];
    platforms = platforms.all;
  };
}