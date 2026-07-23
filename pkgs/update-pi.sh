#!/usr/bin/env bash
# Update pi-coding-agent to a new version.
# Usage: ./pkgs/update-pi.sh 0.81.1
set -euo pipefail
cd "$(dirname "$0")"

PACKAGE="@earendil-works/pi-coding-agent"
VERSION="${1:?Usage: update-pi.sh <version>}"

sedi() {
  if sed --version >/dev/null 2>&1; then
    sed -i "$@"
  else
    sed -i '' "$@"
  fi
}

echo "Updating ${PACKAGE} to ${VERSION}..."

# Update Renovate dependency name and package version in the Nix wrapper.
sedi "s#depName=[^[:space:]]*#depName=${PACKAGE}#" pi-coding-agent.nix
sedi "s#version = \"[^\"]*\"#version = \"${VERSION}\"#" pi-coding-agent.nix
sedi "s#@mariozechner/pi-coding-agent@\${version}#${PACKAGE}@\${version}#" pi-coding-agent.nix
sedi "s#@earendil-works/pi-coding-agent@\${version}#${PACKAGE}@\${version}#" pi-coding-agent.nix

echo "Done! Now run:"
echo "  nix build .#pi-coding-agent"
echo "  ./result/bin/pi -v"
