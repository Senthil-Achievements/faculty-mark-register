# How to Create GitHub Release with Assets

## Step-by-Step Guide

### 1. Prepare Your Files

First, gather these files from your build:

**Android:**
- `build\app\outputs\flutter-apk\app-release.apk` → Rename to `FacultyMarksManager-v1.0.0-Android.apk`

**Windows:**
- `FacultyMarksManager-Windows.zip` (already created in project root)
- `installer_output\FacultyMarksManager_Setup.exe` → Rename to `FacultyMarksManager-v1.0.0-Setup.exe`

**Documentation:**
- `RELEASE_NOTES.md`
- `README.md`

---

### 2. Create GitHub Repository

1. Go to https://github.com/new
2. Repository name: `faculty-marks-manager`
3. Description: `A cross-platform marks management system for educators built with Flutter`
4. Choose: Public (or Private if preferred)
5. ✅ Add a README file (you'll replace this)
6. ✅ Add .gitignore → Select "Flutter"
7. Choose license (optional)
8. Click "Create repository"

---

### 3. Upload Your Code

#### Option A: Using GitHub Desktop (Easier)
1. Download GitHub Desktop
2. Clone your new repository
3. Copy all your project files
4. Commit with message: "Initial release v1.0.0"
5. Push to origin

#### Option B: Using Command Line
```bash
cd C:\Users\senth\OneDrive\Documents\projects\faculty_marks_app_new

# Initialize git (if not already)
git init

# Add remote
git remote add origin https://github.com/YOUR_USERNAME/faculty-marks-manager.git

# Add files
git add .

# Commit
git commit -m "Initial release v1.0.0"

# Push
git branch -M main
git push -u origin main
```

---

### 4. Replace README

1. On GitHub, click on `README.md`
2. Click the pencil icon (Edit)
3. Delete everything
4. Copy content from `GITHUB_README.md`
5. Update these placeholders:
   - `YOUR_USERNAME` → Your GitHub username
   - `YOUR_LINKEDIN` → Your LinkedIn profile
   - Add screenshot images
6. Commit changes

---

### 5. Create a Release

1. Go to your repository on GitHub
2. Click **"Releases"** (right sidebar)
3. Click **"Create a new release"**

4. **Choose a tag:**
   - Click "Choose a tag"
   - Type: `v1.0.0`
   - Click "Create new tag: v1.0.0 on publish"

5. **Release title:**
   ```
   Faculty Marks Manager v1.0.0 - Initial Release
   ```

6. **Description:**
   Copy and paste from `RELEASE_NOTES.md`

7. **Attach Assets:**
   Click "Attach binaries by dropping them here or selecting them"
   
   Upload these files:
   - ✅ `FacultyMarksManager-v1.0.0-Android.apk`
   - ✅ `FacultyMarksManager-Windows.zip`
   - ✅ `FacultyMarksManager-v1.0.0-Setup.exe`

8. **Options:**
   - ✅ Check "Set as the latest release"
   - ☑️ Check "Create a discussion for this release" (optional)

9. Click **"Publish release"**

---

### 6. Verify Download Links

After publishing, your release page will be at:
```
https://github.com/YOUR_USERNAME/faculty-marks-manager/releases/tag/v1.0.0
```

Test all download links to ensure they work!

---

### 7. Add Screenshots

1. Take screenshots of your app:
   - Home screen with subjects
   - Marks entry screen
   - Student detail screen
   - Setup screen

2. Create a folder: `screenshots/`

3. Add images:
   - `home_screen.png`
   - `marks_entry.png`
   - `student_details.png`

4. Update README.md to reference these images:
   ```markdown
   ![Home Screen](screenshots/home_screen.png)
   ```

5. Commit and push

---

### 8. Add Topics/Tags

1. Go to your repository main page
2. Click the gear icon ⚙️ next to "About"
3. Add topics:
   - `flutter`
   - `dart`
   - `education`
   - `marks-management`
   - `cross-platform`
   - `android`
   - `windows`
   - `sqlite`
   - `material-design`
   - `edtech`

4. Update website URL (if you have one)
5. Save changes

---

### 9. Optional: Add Badges

Add these to the top of your README.md:

```markdown
![Version](https://img.shields.io/github/v/release/YOUR_USERNAME/faculty-marks-manager)
![Downloads](https://img.shields.io/github/downloads/YOUR_USERNAME/faculty-marks-manager/total)
![Stars](https://img.shields.io/github/stars/YOUR_USERNAME/faculty-marks-manager)
![License](https://img.shields.io/github/license/YOUR_USERNAME/faculty-marks-manager)
```

---

### 10. Promote Your Release

✅ Share on LinkedIn (use templates from LINKEDIN_POST.md)
✅ Tweet about it (if you use Twitter)
✅ Post in relevant subreddits:
   - r/FlutterDev
   - r/androidapps
   - r/SideProject
✅ Share in Flutter Discord/Slack communities
✅ Add to your portfolio website
✅ Update your resume/CV

---

## File Checklist

Before creating release, ensure you have:

- [ ] `app-release.apk` renamed and ready
- [ ] `FacultyMarksManager-Windows.zip` created
- [ ] `FacultyMarksManager_Setup.exe` renamed and ready
- [ ] `README.md` updated with your info
- [ ] Screenshots taken and added
- [ ] `RELEASE_NOTES.md` finalized
- [ ] Repository created on GitHub
- [ ] Code pushed to GitHub
- [ ] .gitignore includes build files
- [ ] All download links tested

---

## Quick File Rename Commands

Run these in PowerShell from your project folder:

```powershell
# Rename Android APK
Copy-Item "build\app\outputs\flutter-apk\app-release.apk" "FacultyMarksManager-v1.0.0-Android.apk"

# Rename Windows Installer
Copy-Item "installer_output\FacultyMarksManager_Setup.exe" "FacultyMarksManager-v1.0.0-Setup.exe"

# Create release folder
New-Item -ItemType Directory -Path "release_assets" -Force

# Move all assets to release folder
Move-Item "FacultyMarksManager-v1.0.0-Android.apk" "release_assets\"
Move-Item "FacultyMarksManager-Windows.zip" "release_assets\"
Move-Item "FacultyMarksManager-v1.0.0-Setup.exe" "release_assets\"

# Open the folder
explorer "release_assets"
```

---

## Sample Release Description Template

```markdown
# 🎉 Faculty Marks Manager v1.0.0

**First stable release of Faculty Marks Manager!**

## What's New

- Complete marks management system for educators
- Cross-platform support (Android, Windows, Linux, macOS)
- Offline-first SQLite database
- Modern purple-themed UI
- Backup & restore functionality
- Real-time performance calculations

## 📥 Downloads

Choose your platform:

| Platform | File | Size |
|----------|------|------|
| Android | [FacultyMarksManager-v1.0.0-Android.apk](link) | ~46 MB |
| Windows (ZIP) | [FacultyMarksManager-Windows.zip](link) | ~50 MB |
| Windows (Installer) | [FacultyMarksManager-v1.0.0-Setup.exe](link) | ~50 MB |

## Installation

### Android
1. Download the APK
2. Enable "Install from Unknown Sources"
3. Install and enjoy!

### Windows
**Option 1 (ZIP):**
1. Download and extract ZIP
2. Run `faculty_marks_app.exe`

**Option 2 (Installer):**
1. Download and run the installer
2. Follow the wizard

## 📝 Full Release Notes

See [RELEASE_NOTES.md](link) for detailed changelog.

## 🐛 Known Issues

None at this time.

## 🙏 Feedback

Please report bugs or request features via [Issues](link).

---

**Built by Senthil** | [GitHub](link) | [LinkedIn](link)
```

---

## Tips for Success

1. **Clear File Names** - Use version numbers in file names
2. **Test Downloads** - Download and test each asset after release
3. **Update Links** - Make sure README links point to actual release URLs
4. **Professional Images** - Use high-quality screenshots
5. **Changelog** - Keep detailed release notes for future versions
6. **Engage** - Respond to issues and comments promptly

---

**Good luck with your release! 🚀**
