# Resume Promoter

Right-click any tailored resume PDF in your file manager to promote it into an "Upload" folder — renamed to a consistent name (e.g. `Your Name Resume.pdf`) and replacing whatever was there before. Saves you the copy → rename → delete → paste ritual every time you apply to a job.

Works on **macOS** (Finder Quick Action) and **Linux/KDE** (Dolphin service menu).

---

## Install

Open **Terminal** (on macOS: Applications → Utilities → Terminal) and paste this, then press Return:

```
curl -fsSL https://raw.githubusercontent.com/JRordan/resume-promoter/main/install.sh | bash
```

The installer will:

1. Download the tool to `~/.local/share/resume-promoter/`
2. Pop up a dialog asking your full name (used as the upload filename prefix)
3. Pop up a folder picker for where to keep your resumes (default: `~/Documents/Resumes`)
4. Install the right-click menu integration
5. Show an "Install complete" dialog

No admin password, no Gatekeeper warnings, nothing installed system-wide.

---

## Usage

1. Put your role-tailored resume PDFs into the **Versions** subfolder of the resumes folder you picked (e.g. `~/Documents/Resumes/Versions`). Name each after the role: `Backend Developer.pdf`, `Product Manager.pdf`, etc.
2. In your file manager, **right-click** any of those PDFs.
3. Choose **Promote Resume to Upload** (on macOS it may be under **Quick Actions** or **Services**).
4. Open the **Upload** subfolder — it now contains exactly one file: `Your Name Resume.pdf`.
5. Attach that file to your job application.

---

## Uninstall

Paste this into Terminal:

```
curl -fsSL https://raw.githubusercontent.com/JRordan/resume-promoter/main/uninstall.sh | bash
```

Removes the right-click menu, the settings file, and the installed copy at `~/.local/share/resume-promoter/`. **Your resume PDFs and folders are not touched.**

---

## Change your name or folder later

Re-run the install command. It'll prefill your previous answers so you can just accept them or type new ones.

---

## Optional: keyboard shortcut

### macOS

1. Open **System Settings → Keyboard**.
2. Click **Keyboard Shortcuts…**.
3. In the left column, click **Services**.
4. Under **Files and Folders**, find **Promote Resume to Upload**.
5. Click to the right of its name and press your desired key combo (e.g. ⌘⌥R).

### Linux (Hyprland with end-4 dots)

Add to `~/.config/hypr/custom/keybinds.lua`:

```lua
hl.bind("SUPER+SHIFT+R",
    hl.dsp.exec_cmd(os.getenv("HOME") .. "/.local/share/resume-promoter/promote-picker"),
    { description = "Resumes: pick and promote" })
```

---

## Troubleshooting

**Nothing happens after I paste the install command.**
Check your internet connection, then re-run it. If `curl: command not found`, install curl first (macOS ships with it by default).

**The dialog for name or folder doesn't appear.**
Look for a dialog behind other windows. On macOS, click the Terminal icon in the Dock — the dialog is usually attached to it.

**Right-clicking a PDF doesn't show "Promote Resume to Upload" (macOS).**
- The menu only appears for PDF files, not other file types.
- Refresh Finder: hold Option, right-click the Finder icon in the Dock, choose **Relaunch**.
- Some Macs show it under **Services** instead of **Quick Actions**.

**Right-clicking a PDF doesn't show the option (Linux/KDE).**
Run `kbuildsycoca6` in Terminal to refresh the service cache, then reopen Dolphin.

**The Upload folder still shows the old file.**
Refresh the file manager window (⌘R on Mac).

**I don't trust piping curl into bash.**
Reasonable. Instead:
```
curl -fsSL -O https://raw.githubusercontent.com/JRordan/resume-promoter/main/install.sh
less install.sh   # review
bash install.sh
```

---

## What gets installed where

| Path | Purpose |
|---|---|
| `~/.local/share/resume-promoter/` | The tool itself (scripts + Automator template) |
| `~/.config/resume-promoter/config` | Your name and folder settings |
| macOS: `~/Library/Services/PromoteResume.workflow` | Finder Quick Action |
| Linux: `~/.local/share/kio/servicemenus/promote-resume.desktop` | Dolphin right-click entry |

Uninstall removes all of the above. Your resume PDFs and the folder you chose for them are never touched.
