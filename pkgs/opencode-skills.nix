{
  lib,
  stdenv,
  fetchFromGitHub,
}:

stdenv.mkDerivation rec {
  pname = "opencode-skills";
  version = "0.1.7";

  src = fetchFromGitHub {
    owner = "malhashemi";
    repo = "opencode-skills";
    rev = "v${version}";
    hash = "sha256-YajcjnJCOmY+cgtCDx6eySQa2f6acmzWR7AftZBBsTY=";
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
    cat > $out/share/opencode/plugins/opencode-skills.ts <<EOF
// OpenCode Skills Plugin
export { default as SkillsPlugin } from './index.js';
EOF
    
    runHook postInstall
  '';

  meta = with lib; {
    description = "Brings Anthropic's Agent Skills Specification to OpenCode with auto-discovery and dynamic tools";
    homepage = "https://github.com/malhashemi/opencode-skills";
    license = licenses.mit;
    maintainers = [ ];
    platforms = platforms.all;
  };
}