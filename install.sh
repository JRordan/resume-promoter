#!/usr/bin/env bash
# Curl-installable entry point.
# User-facing one-liner:
#   curl -fsSL https://raw.githubusercontent.com/JRordan/resume-promoter/main/install.sh | bash
#
# Downloads the current main branch as a tarball, unpacks it into
# ~/.local/share/resume-promoter/, then hands off to setup.sh --install
# for the interactive name/folder prompts and OS integration.
set -euo pipefail

REPO="JRordan/resume-promoter"
BRANCH="main"
INSTALL_DIR="${RESUME_PROMOTER_HOME:-$HOME/.local/share/resume-promoter}"

command -v curl >/dev/null 2>&1 || { echo "ERROR: curl is required." >&2; exit 1; }
command -v tar  >/dev/null 2>&1 || { echo "ERROR: tar is required."  >&2; exit 1; }

echo "==> Installing resume-promoter to: $INSTALL_DIR"

tmp="$(mktemp -d 2>/dev/null || mktemp -d -t resume-promoter)"
trap 'rm -rf "$tmp"' EXIT

echo "==> Downloading latest from github.com/$REPO ($BRANCH)"
curl -fsSL "https://github.com/$REPO/archive/refs/heads/$BRANCH.tar.gz" | tar -xz -C "$tmp"

src="$(find "$tmp" -mindepth 1 -maxdepth 1 -type d | head -1)"
if [ -z "$src" ] || [ ! -f "$src/setup.sh" ]; then
    echo "ERROR: downloaded archive did not contain a valid resume-promoter release." >&2
    exit 1
fi

mkdir -p "$(dirname "$INSTALL_DIR")"
rm -rf "$INSTALL_DIR"
mkdir -p "$INSTALL_DIR"
cp -R "$src"/. "$INSTALL_DIR/"

chmod +x "$INSTALL_DIR/setup.sh"
[ -f "$INSTALL_DIR/promote-resume" ] && chmod +x "$INSTALL_DIR/promote-resume"
[ -f "$INSTALL_DIR/promote-picker" ] && chmod +x "$INSTALL_DIR/promote-picker"

echo "==> Launching interactive setup..."
exec bash "$INSTALL_DIR/setup.sh" --install
