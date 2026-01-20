{ lib, writeShellScriptBin, bun, git }:

(writeShellScriptBin "bdui" ''
  set -euo pipefail
  
  # Use the bun from the nix store
  BUN_CMD="${bun}/bin/bun"
  
  # Check if we're in a directory with .beads
  if ! find . -maxdepth 5 -name ".beads" -type d >/dev/null 2>&1; then
    echo "Error: No .beads directory found in current directory or parent directories"
    echo "Please run bdui from within a beads project directory"
    exit 1
  fi
  
  # Create temporary directory for bdui
  BDUI_DIR="''${XDG_CACHE_HOME:-$HOME/.cache}/bdui"
  mkdir -p "$BDUI_DIR"
  
  # Clone or update bdui repository
  if [ ! -d "$BDUI_DIR/repo" ]; then
    echo "Cloning bdui repository..."
    ${git}/bin/git clone https://github.com/assimelha/bdui.git "$BDUI_DIR/repo"
  else
    echo "Updating bdui repository..."
    cd "$BDUI_DIR/repo"
    ${git}/bin/git pull origin master
  fi
  
  cd "$BDUI_DIR/repo"
  
  # Install dependencies if needed
  if [ ! -d "node_modules" ] || [ "package.json" -nt "node_modules" ]; then
    echo "Installing dependencies..."
    "$BUN_CMD" install
  fi
  
  # Run bdui
  exec "$BUN_CMD" run src/index.tsx "$@"
'').overrideAttrs (oldAttrs: {
  meta = {
    description = "Real-time Text User Interface for bd (beads) issue tracker with Kanban, Tree, Graph views, and notifications";
    longDescription = ''
      BD TUI is a beautiful, real-time Text User Interface (TUI) visualizer for the bd (beads) issue tracker.
      
      This package provides a wrapper script that automatically clones the bdui repository and runs it with Bun.
      Note: This requires internet access on first run to download the source code and dependencies.
      
      Features:
      - Multiple visualizations (Kanban, Tree, Dependency Graph, Statistics)
      - Real-time updates with file watching
      - Search & filter capabilities
      - Custom themes
      - Desktop notifications
      - Issue management (create, edit, export)
    '';
    homepage = "https://github.com/assimelha/bdui";
    license = lib.licenses.mit;
    maintainers = [ ];
    mainProgram = "bdui";
    platforms = lib.platforms.unix;
  };
})