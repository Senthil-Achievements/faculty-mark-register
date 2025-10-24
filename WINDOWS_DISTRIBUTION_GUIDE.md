# Faculty Marks Manager - Windows Distribution Guide

## Distribution Options

### Option 1: Create Windows Installer (Recommended)

**Requirements:**
- Download and install [Inno Setup](https://jrsoftware.org/isdl.php) (free)

**Steps:**
1. Install Inno Setup from the link above
2. Open `windows_installer.iss` with Inno Setup Compiler
3. Click "Compile" (or press Ctrl+F9)
4. The installer will be created in `installer_output` folder
5. Share the single `.exe` installer file with users

**Result:** 
- Single `.exe` installer file (approximately 50-60 MB)
- Automatic installation of all DLL files
- Creates desktop shortcut
- Adds to Windows Start Menu
- Easy uninstallation

---

### Option 2: ZIP Archive (Simple)

**Steps:**
1. Navigate to `build\windows\x64\runner\Release\`
2. Select all files and folders in the Release directory
3. Right-click → Send to → Compressed (zipped) folder
4. Rename to `FacultyMarksManager-Windows.zip`

**To Install:**
1. Extract the ZIP file to any folder (e.g., `C:\Program Files\FacultyMarksManager\`)
2. Run `faculty_marks_app.exe`
3. (Optional) Create a desktop shortcut manually

**Important:** All DLL files must stay in the same folder as the .exe file!

---

### Option 3: Portable (No Installation)

**Steps:**
1. Copy the entire `build\windows\x64\runner\Release\` folder
2. Rename it to `FacultyMarksManager-Portable`
3. Share the entire folder

**Usage:**
- Users can run directly from a USB drive
- No installation needed
- All DLLs are included in the folder

---

## Required Files in Release Folder

The following files are **required** and must be distributed together:

### Executable:
- `faculty_marks_app.exe` - Main application

### DLL Files (Required):
- `flutter_windows.dll` - Flutter engine
- `sqlite3.dll` - Database engine
- Various other Flutter plugin DLLs

### Data Folder:
- `data\` - Contains app resources and assets

All these files are automatically included when you:
- Create an installer using Option 1
- ZIP the Release folder (Option 2)
- Copy the entire Release folder (Option 3)

---

## App Features

✅ Custom purple theme (#1E1E2F, #4C2A59, #9E4B8A)
✅ "Built by Senthil" developer credit
✅ Offline SQLite database
✅ Student marks management
✅ Data import/export
✅ Backup and restore

---

## File Locations

**Windows EXE:** `build\windows\x64\runner\Release\faculty_marks_app.exe`
**Android APK:** `build\app\outputs\flutter-apk\app-release.apk`
**Installer Script:** `windows_installer.iss`

---

## Troubleshooting

**Q: "Missing DLL" error?**
A: Make sure all files from the Release folder are in the same directory as the .exe

**Q: App won't start?**
A: Check Windows Defender - it may have blocked the app. Click "More info" → "Run anyway"

**Q: Database error?**
A: Ensure `sqlite3.dll` is in the same folder as the .exe file

---

Built by Senthil
