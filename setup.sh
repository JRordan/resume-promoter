#!/usr/bin/env bash
# Cross-platform GUI setup: pick Install or Uninstall.
#
# Install: prompt for name and parent folder, write config, install
#          OS-native right-click integration (Finder Quick Action on Mac,
#          Dolphin service menu on KDE Linux).
# Uninstall: remove the OS integration and config file. Resume PDFs and
#            folders are never touched.
#
# Uses AppleScript dialogs on macOS, kdialog/zenity on Linux, and falls
# back to plain `read` prompts if no GUI is available.
set -euo pipefail

resolve_path() {
    if command -v realpath >/dev/null 2>&1; then
        realpath -- "$1"
    else
        perl -MCwd -e 'print Cwd::realpath($ARGV[0])' -- "$1"
    fi
}

SCRIPT_DIR="$(cd "$(dirname "$(resolve_path "$0")")" && pwd)"
CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/resume-promoter"
CONFIG_FILE="$CONFIG_DIR/config"

OS="$(uname -s)"
TITLE="Resume Promoter Setup"

# Load any prior config so prompts are prefilled with the previous values.
FULL_NAME=""
VERSIONS_DIR=""
UPLOAD_DIR=""
if [ -f "$CONFIG_FILE" ]; then
    # shellcheck disable=SC1090
    . "$CONFIG_FILE"
fi
: "${FULL_NAME:=}"

# Recommended default parent folder. If a prior config exists and its
# Versions/Upload share a parent, prefill that instead.
DEFAULT_PARENT="$HOME/Documents/Resumes"
if [ -n "$VERSIONS_DIR" ] && [ -n "$UPLOAD_DIR" ]; then
    v_parent="$(dirname "$VERSIONS_DIR")"
    u_parent="$(dirname "$UPLOAD_DIR")"
    if [ "$v_parent" = "$u_parent" ]; then
        DEFAULT_PARENT="$v_parent"
    fi
fi

have() { command -v "$1" >/dev/null 2>&1; }

# -------- GUI helpers --------

gui_text() {
    local title="$1" prompt="$2" default="$3"
    case "$OS" in
        Darwin)
            osascript <<APPLESCRIPT
try
    set res to text returned of (display dialog "$prompt" default answer "$default" with title "$title" buttons {"Cancel","OK"} default button "OK")
    return res
on error
    return ""
end try
APPLESCRIPT
            ;;
        Linux)
            if have kdialog; then
                kdialog --title "$title" --inputbox "$prompt" "$default" 2>/dev/null || true
            elif have zenity; then
                zenity --title="$title" --entry --text="$prompt" --entry-text="$default" 2>/dev/null || true
            else
                printf "%s\n[%s] " "$prompt" "$default" >&2
                local r; IFS= read -r r || true
                printf "%s" "${r:-$default}"
            fi
            ;;
    esac
}

gui_folder() {
    local title="$1" prompt="$2" default="$3"
    case "$OS" in
        Darwin)
            osascript <<APPLESCRIPT
try
    set res to POSIX path of (choose folder with prompt "$prompt" default location POSIX file "$default")
    if res ends with "/" then set res to text 1 thru -2 of res
    return res
on error
    return ""
end try
APPLESCRIPT
            ;;
        Linux)
            if have kdialog; then
                kdialog --title "$title" --getexistingdirectory "$default" 2>/dev/null || true
            elif have zenity; then
                zenity --title="$title" --file-selection --directory --filename="$default/" 2>/dev/null || true
            else
                printf "%s\n[%s] " "$prompt" "$default" >&2
                local r; IFS= read -r r || true
                printf "%s" "${r:-$default}"
            fi
            ;;
    esac
}

gui_yesno() {
    local title="$1" prompt="$2"
    case "$OS" in
        Darwin)
            osascript <<APPLESCRIPT >/dev/null 2>&1
try
    display dialog "$prompt" with title "$title" buttons {"No","Yes"} default button "Yes"
    if button returned of result is "Yes" then return 0
    error number -128
on error
    error number -128
end try
APPLESCRIPT
            ;;
        Linux)
            if have kdialog; then
                kdialog --title "$title" --yesno "$prompt" >/dev/null 2>&1
            elif have zenity; then
                zenity --title="$title" --question --text="$prompt" >/dev/null 2>&1
            else
                printf "%s [y/N] " "$prompt" >&2
                local r; IFS= read -r r || true
                case "$r" in y|Y|yes|YES) return 0 ;; *) return 1 ;; esac
            fi
            ;;
    esac
}

gui_message() {
    local title="$1" body="$2"
    case "$OS" in
        Darwin)
            osascript <<APPLESCRIPT >/dev/null 2>&1 || true
display dialog "$body" with title "$title" buttons {"OK"} default button "OK"
APPLESCRIPT
            ;;
        Linux)
            if have kdialog; then
                kdialog --title "$title" --msgbox "$body" >/dev/null 2>&1 || true
            elif have zenity; then
                zenity --title="$title" --info --text="$body" >/dev/null 2>&1 || true
            else
                printf "%s: %s\n" "$title" "$body" >&2
            fi
            ;;
    esac
}

gui_error() {
    local title="$1" body="$2"
    case "$OS" in
        Darwin)
            osascript <<APPLESCRIPT >/dev/null 2>&1 || true
display dialog "$body" with title "$title" buttons {"OK"} default button "OK" with icon stop
APPLESCRIPT
            ;;
        Linux)
            if have kdialog; then
                kdialog --title "$title" --error "$body" >/dev/null 2>&1 || true
            elif have zenity; then
                zenity --title="$title" --error --text="$body" >/dev/null 2>&1 || true
            else
                printf "ERROR: %s: %s\n" "$title" "$body" >&2
            fi
            ;;
    esac
}

gui_choose_mode() {
    # Returns "install", "uninstall", or empty string.
    # Uses `display dialog` with buttons instead of `choose from list` —
    # the latter does not accept `with title` (compile error) and is less
    # reliable when the caller is a shell-script .app with no Cocoa lifecycle.
    case "$OS" in
        Darwin)
            osascript <<APPLESCRIPT
try
    tell me to activate
    set res to button returned of (display dialog "What would you like to do?" with title "$TITLE" buttons {"Cancel", "Uninstall", "Install"} default button "Install" cancel button "Cancel")
    if res is "Install" then return "install"
    if res is "Uninstall" then return "uninstall"
    return ""
on error
    return ""
end try
APPLESCRIPT
            ;;
        Linux)
            if have kdialog; then
                kdialog --title "$TITLE" --menu "What would you like to do?" \
                    install "Install" \
                    uninstall "Uninstall" 2>/dev/null || true
            elif have zenity; then
                zenity --title="$TITLE" --list --radiolist \
                    --text "What would you like to do?" \
                    --column "Pick" --column "Action" \
                    TRUE install "Install" \
                    FALSE uninstall "Uninstall" \
                    2>/dev/null || true
            else
                printf "1) Install\n2) Uninstall\nChoose [1]: " >&2
                local r; IFS= read -r r || true
                case "$r" in 2|u|U|uninstall) printf "uninstall" ;; *) printf "install" ;; esac
            fi
            ;;
    esac
}

# -------- Uninstall flow --------

do_uninstall() {
    local removed=""
    case "$OS" in
        Darwin)
            local target="$HOME/Library/Services/PromoteResume.workflow"
            if [ -e "$target" ]; then
                rm -rf "$target"
                removed="$removed
- Finder Quick Action"
            fi
            /System/Library/CoreServices/pbs -flush >/dev/null 2>&1 || true
            ;;
        Linux)
            local target="$HOME/.local/share/kio/servicemenus/promote-resume.desktop"
            if [ -e "$target" ]; then
                rm -f "$target"
                removed="$removed
- Dolphin right-click menu"
            fi
            if have kbuildsycoca6; then kbuildsycoca6 >/dev/null 2>&1 || true
            elif have kbuildsycoca5; then kbuildsycoca5 >/dev/null 2>&1 || true
            fi
            ;;
    esac
    if [ -f "$CONFIG_FILE" ]; then
        rm -f "$CONFIG_FILE"
        removed="$removed
- Config file"
    fi
    if [ -z "$removed" ]; then
        gui_message "$TITLE" "Nothing to uninstall — no components were installed."
    else
        gui_message "$TITLE" "Uninstalled:$removed

Your resume PDFs and folders were NOT touched. To fully remove the tool, drag the folder that contains 'tools' to the Trash."
    fi
}

# -------- Install flow --------

do_install() {
    local name_input parent_input
    name_input="$(gui_text "$TITLE" "Enter your full name (used as the upload filename prefix):" "$FULL_NAME")"
    if [ -z "$name_input" ]; then
        gui_error "$TITLE" "Install cancelled — no name entered."
        exit 1
    fi
    FULL_NAME="$name_input"

    parent_input="$(gui_folder "$TITLE" "Choose the folder to hold your resumes. A 'Versions' subfolder (for tailored PDFs) and an 'Upload' subfolder (for the file to attach) will be created inside it." "$DEFAULT_PARENT")"
    if [ -z "$parent_input" ]; then
        gui_error "$TITLE" "Install cancelled — no folder chosen."
        exit 1
    fi
    VERSIONS_DIR="$parent_input/Versions"
    UPLOAD_DIR="$parent_input/Upload"

    for d in "$parent_input" "$VERSIONS_DIR" "$UPLOAD_DIR"; do
        if [ ! -d "$d" ]; then
            if gui_yesno "$TITLE" "Folder does not exist:
$d

Create it?"; then
                mkdir -p "$d"
            else
                gui_error "$TITLE" "Install cancelled — folder missing: $d"
                exit 1
            fi
        fi
    done

    mkdir -p "$CONFIG_DIR"
    umask 077
    cat > "$CONFIG_FILE" <<EOF
# Resume promoter config. Sourced by promote-resume and promote-picker.
FULL_NAME="$FULL_NAME"
VERSIONS_DIR="$VERSIONS_DIR"
UPLOAD_DIR="$UPLOAD_DIR"
EOF

    case "$OS" in
        Darwin)
            local services_dir="$HOME/Library/Services"
            local workflow_template="$SCRIPT_DIR/mac/PromoteResume.workflow"
            local dest="$services_dir/PromoteResume.workflow"
            mkdir -p "$services_dir"
            rm -rf "$dest"
            cp -R "$workflow_template" "$dest"
            local promote_path="$SCRIPT_DIR/promote-resume"
            /usr/bin/python3 - "$dest/Contents/document.wflow" "$promote_path" <<'PY' || true
import sys, plistlib
path, promote = sys.argv[1], sys.argv[2]
with open(path, "rb") as f:
    doc = plistlib.load(f)
for action in doc.get("actions", []):
    a = action.get("action", {})
    params = a.get("ActionParameters", {})
    if "COMMAND_STRING" in params:
        params["COMMAND_STRING"] = f'"{promote}" "$@"'
with open(path, "wb") as f:
    plistlib.dump(doc, f)
PY
            chmod +x "$SCRIPT_DIR/promote-resume" "$SCRIPT_DIR/promote-picker"
            /System/Library/CoreServices/pbs -flush >/dev/null 2>&1 || true
            gui_message "$TITLE" "Install complete.

Right-click a PDF in $VERSIONS_DIR and choose:
  Quick Actions → Promote Resume to Upload

To bind a keyboard shortcut:
  System Settings → Keyboard → Keyboard Shortcuts → Services
  → Files and Folders → Promote Resume to Upload

To uninstall later, re-run this installer and choose Uninstall."
            ;;
        Linux)
            local servicemenu_dir="$HOME/.local/share/kio/servicemenus"
            mkdir -p "$servicemenu_dir"
            local desktop="$servicemenu_dir/promote-resume.desktop"
            local promote_path="$SCRIPT_DIR/promote-resume"
            cat > "$desktop" <<EOF
[Desktop Entry]
Type=Service
MimeType=application/pdf;
Actions=promoteResume;
X-KDE-Priority=TopLevel
X-KDE-ServiceTypes=KonqPopupMenu/Plugin

[Desktop Action promoteResume]
Name=Promote to Upload as "$FULL_NAME Resume.pdf"
Icon=document-send
Exec=$promote_path %F
EOF
            chmod +x "$desktop"
            chmod +x "$SCRIPT_DIR/promote-resume" "$SCRIPT_DIR/promote-picker"
            if have kbuildsycoca6; then kbuildsycoca6 >/dev/null 2>&1 || true
            elif have kbuildsycoca5; then kbuildsycoca5 >/dev/null 2>&1 || true
            fi
            gui_message "$TITLE" "Install complete.

Right-click a PDF in $VERSIONS_DIR and choose:
  Promote to Upload as \"$FULL_NAME Resume.pdf\"

Global fuzzel picker (add to ~/.config/hypr/custom/keybinds.lua):
  hl.bind(\"SUPER+SHIFT+R\", hl.dsp.exec_cmd(\"$SCRIPT_DIR/promote-picker\"),
      { description = \"Resumes: pick and promote\" })

To uninstall later, re-run this installer and choose Uninstall."
            ;;
        *)
            gui_error "$TITLE" "Unsupported OS: $OS"
            exit 1
            ;;
    esac
}

# -------- Main --------

MODE="$(gui_choose_mode)"
case "$MODE" in
    install)   do_install ;;
    uninstall)
        if ! gui_yesno "$TITLE" "Uninstall Resume Promoter?

This removes the right-click menu and settings file. Your resume PDFs and folders will NOT be deleted."; then
            exit 0
        fi
        do_uninstall
        ;;
    *) exit 0 ;;
esac
