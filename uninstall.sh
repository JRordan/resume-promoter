#!/usr/bin/env bash
# Curl-runnable uninstaller.
# User-facing one-liner:
#   curl -fsSL https://raw.githubusercontent.com/JRordan/resume-promoter/main/uninstall.sh | bash
#
# Removes the OS integration (Finder Quick Action / Dolphin service menu),
# the config file, and the installed copy at ~/.local/share/resume-promoter/.
# The user's resume PDFs and folders are NEVER touched.
set -euo pipefail

INSTALL_DIR="${RESUME_PROMOTER_HOME:-$HOME/.local/share/resume-promoter}"

echo "==> Uninstalling resume-promoter"

if [ -x "$INSTALL_DIR/setup.sh" ]; then
    # Delegate to the installed setup.sh so the removal logic stays in one place.
    bash "$INSTALL_DIR/setup.sh" --uninstall || true
else
    echo "==> No installed copy found at $INSTALL_DIR"
    echo "==> Removing integration files anyway..."
    case "$(uname -s)" in
        Darwin)
            rm -rf "$HOME/Library/Services/PromoteResume.workflow" 2>/dev/null || true
            /System/Library/CoreServices/pbs -flush >/dev/null 2>&1 || true
            ;;
        Linux)
            rm -f "$HOME/.local/share/kio/servicemenus/promote-resume.desktop" 2>/dev/null || true
            command -v kbuildsycoca6 >/dev/null 2>&1 && kbuildsycoca6 >/dev/null 2>&1 || true
            ;;
    esac
    rm -f "$HOME/.config/resume-promoter/config" 2>/dev/null || true
fi

if [ -d "$INSTALL_DIR" ]; then
    echo "==> Removing installed copy at $INSTALL_DIR"
    rm -rf "$INSTALL_DIR"
fi

echo "==> Uninstall complete. Your resume PDFs and folders were not touched."
