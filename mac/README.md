# Resume Promoter — Mac Install & Usage

A tiny tool that adds a right-click menu to Finder so you can promote any tailored resume PDF into a single "Upload" folder — automatically renamed to a consistent name and replacing whatever was there before. It saves you the copy → paste → delete → rename ritual every time you apply to a job.

---

## What you'll get

After install, right-clicking a PDF in Finder shows a new **Quick Actions → Promote Resume to Upload** command. Choosing it:

1. Copies that PDF into your "Upload" folder
2. Renames the copy to `Your Name Resume.pdf`
3. Deletes any previous PDF that was in the Upload folder

Then you just attach the file from the Upload folder to your job application.

---

## Before you start

You'll need to decide on two things (the installer will ask):

- **Your full name.** This becomes the upload filename. Example: `Alex Chen` → `Alex Chen Resume.pdf`.
- **Where to keep your resumes.** A folder on your Mac. The installer recommends `~/Documents/Resumes` (a folder called "Resumes" inside your Documents folder). It'll create two subfolders inside it: `Versions` (your tailored PDFs go here) and `Upload` (the current file to attach).

You don't need to be technical. The installer uses regular Mac dialog boxes.

---

## Install (one time)

1. Open the folder you were given. Inside, go into `tools`, then `mac`.
2. **Right-click** (or hold Control and click) the app icon called **Resume Promoter Setup**, then choose **Open**.

   > ⚠️ You must right-click and choose Open the *first* time. If you just double-click it, macOS will refuse with a security warning because the app isn't signed by Apple. After the first Open, double-click will work.

3. A warning may appear: *"macOS cannot verify the developer..."* — click **Open**.
4. The setup window opens. Choose **Install**.
5. Enter your full name when asked.
6. Pick the folder for your resumes (or accept the default `~/Documents/Resumes`).
7. If the folder doesn't exist yet, the installer asks if it should create it — click **Yes**.
8. A "Install complete" message appears. You're done.

---

## How to use it

1. Put your tailored resume PDFs into the **Versions** subfolder (e.g. `~/Documents/Resumes/Versions`). Name each one after the role, like `Backend Developer.pdf` or `Product Manager.pdf`.
2. In Finder, right-click the resume you want to send.
3. Choose **Quick Actions → Promote Resume to Upload**.
   - On smaller menus this may be under **Services** instead.
4. Open your **Upload** folder. It now contains exactly one file: `Your Name Resume.pdf`.
5. Attach that file to the job application.

That's the whole workflow.

---

## Optional: keyboard shortcut

If you'd rather use a keystroke than the right-click menu:

1. Open **System Settings → Keyboard**.
2. Scroll to **Keyboard Shortcuts…** and click it.
3. In the left column, click **Services**.
4. In the right pane, find the **Files and Folders** section.
5. Find **Promote Resume to Upload** in that list.
6. Click the empty area to the right of its name, then press the key combo you want (for example ⌘ + Option + R).
7. Close the settings window.

Now, in Finder, click any PDF in the Versions folder and press that combo to promote it.

---

## Uninstall

1. Right-click **Resume Promoter Setup** in `tools/mac/` and choose **Open**.
2. Choose **Uninstall**.
3. Confirm.

This removes the right-click menu and settings file. **It does NOT delete your resume PDFs or your Resumes folder** — those are yours and are left alone. If you want to fully remove the tool afterwards, drag the whole folder that was given to you (the one containing `tools`) to the Trash.

---

## Changing your name or folder later

Just re-run the installer and choose **Install** again. Enter the new name or pick a different folder. Existing files are not touched; only the settings and right-click menu are updated.

---

## Troubleshooting

**"Resume Promoter Setup can't be opened because Apple cannot check it for malicious software."**
Right-click the app and choose **Open** instead of double-clicking. Confirm the warning. You only need to do this once.

**Right-clicking a PDF doesn't show "Promote Resume to Upload".**
- The menu only appears for PDF files, not other file types.
- Try refreshing Finder: hold Option, right-click the Finder icon in the Dock, choose **Relaunch**.
- Re-open the installer and confirm setup finished without errors.
- Some Macs group it under **Services** instead of **Quick Actions** in the right-click menu.

**The Upload folder still shows the old file.**
Refresh the Finder window by pressing ⌘R, or close and reopen the folder.

**The installer says "Setup script not found".**
The setup app must stay inside the `tools/mac/` folder — it locates the installer relative to itself. If you moved it, put it back.

**Nothing happens when I right-click and choose the action.**
Open the installer once and confirm the folder paths are correct. If your Versions folder is empty, add at least one PDF to it and try again.
