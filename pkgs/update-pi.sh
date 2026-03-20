#!/usr/bin/env bash
# Update pi-coding-agent to a new version.
# Usage: ./pkgs/update-pi.sh 0.62.0
set -euo pipefail
cd "$(dirname "$0")"

VERSION="${1:?Usage: update-pi.sh <version>}"

echo "Updating pi-coding-agent to ${VERSION}..."

# Update wrapper package.json
sed -i '' "s/\"@mariozechner\/pi-coding-agent\": \"[^\"]*\"/\"@mariozechner\/pi-coding-agent\": \"${VERSION}\"/" pi-coding-agent-package.json

# Regenerate lockfile in a temp dir
TMPDIR=$(mktemp -d)
trap 'rm -rf "$TMPDIR"' EXIT
cp pi-coding-agent-package.json "$TMPDIR/package.json"
(cd "$TMPDIR" && npm install --package-lock-only --ignore-scripts 2>/dev/null)
cp "$TMPDIR/package-lock.json" pi-coding-agent-package-lock.json

# Update version in nix file
sed -i '' "s/version = \"[^\"]*\"/version = \"${VERSION}\"/" pi-coding-agent.nix

# Clear hash so nix build prints the correct one
sed -i '' "s/npmDepsHash = \"[^\"]*\"/npmDepsHash = \"\"/" pi-coding-agent.nix

echo "Done! Now run:"
echo "  nix build .#pi-coding-agent"
echo "Copy the hash from the error output and paste it into pkgs/pi-coding-agent.nix"
