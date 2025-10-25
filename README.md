# Faculty Marks Manager

<div align="center">
  
  ![Flutter](https://img.shields.io/badge/Flutter-3.35.6-02569B?logo=flutter)
  ![Dart](https://img.shields.io/badge/Dart-3.0+-0175C2?logo=dart)
  ![Platform](https://img.shields.io/badge/Platform-Android%20%7C%20Windows%20%7C%20Linux%20%7C%20macOS-lightgrey)
  ![License](https://img.shields.io/badge/License-All%20Rights%20Reserved-red)
  
  **A comprehensive marks management system for educators**
  
  [Download Latest Release](../../releases/latest) • [Report Bug](../../issues) • [Request Feature](../../issues)
  
</div>

---

## 📖 About

Faculty Marks Manager is a powerful, cross-platform application designed to help teachers and faculty members efficiently manage student marks, assessments, and performance tracking. Built with Flutter, it offers a seamless experience across mobile and desktop platforms with offline-first architecture. "IF .EXE FILE WON'T RUN ON YOUR PC , DOWNLOAD AND EXTRACT THE ZIP AND LAUNCH THE "faculty_marks_app.EXE FILE TO RUN THAT!
### ✨ Key Features

- 📚 **Subject Management** - Organize students by subjects
- 👨‍🎓 **Student Tracking** - Maintain detailed student records with roll numbers
- 📝 **Assessment Creation** - Create unlimited assessments with customizable max marks
- 📊 **Marks Entry** - Quick and intuitive marks entry interface
- 📈 **Performance Analytics** - Real-time student performance calculations
- 💾 **Backup & Restore** - Secure data backup and restore functionality
- 🎨 **Modern UI** - Beautiful purple-themed dark interface
- 🔒 **Offline-First** - All data stored locally with SQLite

---

## 📥 Download

### Latest Release - v1.0.0

| Platform |
|----------|
| 🤖 **Android** 
| 🪟 **Windows**
| 🪟 **Windows Installer** 

> **Note:** Linux and macOS builds require building from source on respective platforms.
> check links in the releseas menu

---

## 🚀 Getting Started

### For Users

#### Android Installation
1. Download `app-release.apk`
2. Enable "Install from Unknown Sources" in Settings
3. Install and open the app

#### Windows Installation (ZIP)
1. Download `FacultyMarksManager-Windows.zip`
2. Extract to any folder
3. Run `faculty_marks_app.exe`

#### Windows Installation (Installer)
1. Download `FacultyMarksManager_Setup.exe`
2. Run the installer
3. Follow the installation wizard

### For Developers

```bash
# Clone the repository
git clone https://github.com/Senthil-Achievements/faculty-mark-register.git

# Navigate to project directory
cd faculty-mark-register

# Install dependencies
flutter pub get

# Run on your preferred platform
flutter run -d windows  # For Windows
flutter run -d android  # For Android
flutter run -d chrome   # For Web
```

---

## 🛠️ Built With

- **[Flutter](https://flutter.dev/)** - UI Framework
- **[Dart](https://dart.dev/)** - Programming Language
- **[SQLite](https://www.sqlite.org/)** - Local Database
- **sqflite_common_ffi** - Desktop SQLite support
- **Material Design 3** - Design System

---

## 📱 Platform Support

| Platform | Status | Minimum Version |
|----------|--------|----------------|
| Android | ✅ Supported | Android 5.0 (API 21) |
| iOS | ✅ Compatible | iOS 12.0+ |
| Windows | ✅ Supported | Windows 10+ |
| Linux | ✅ Compatible | Ubuntu 20.04+ |
| macOS | ✅ Compatible | macOS 10.14+ |
| Web | ✅ Supported | Modern Browsers |

---

## 🎨 Features in Detail

### Faculty Profile
- Create personalized faculty profile
- Store contact information and department details
- Profile picture support

### Subject Management
- Add unlimited subjects
- Delete subjects with cascade deletion of related data
- Quick subject switching

### Student Management
- Add students with roll numbers
- Organize by subject
- View complete student performance history

### Marks Entry
- Grid-based marks entry
- Support for partial assessments
- Real-time average calculation
- Visual performance indicators

### Data Security
- Local SQLite database
- JSON backup format
- Easy data migration
- No cloud dependency

---

## 📊 Technical Architecture

```
faculty_marks_app/
├── lib/
│   ├── models/          # Data models (Student, Subject, Assessment, etc.)
│   ├── database/        # SQLite database helper
│   ├── screens/         # UI screens
│   ├── utils/           # Utilities (backup, export, theme)
│   └── main.dart        # App entry point
├── android/             # Android platform code
├── windows/             # Windows platform code
├── web/                 # Web platform code
└── pubspec.yaml         # Dependencies
```

---

## 🤝 Contributing

Contributions, issues, and feature requests are welcome!

1. Fork the Project
2. Create your Feature Branch (`git checkout -b feature/AmazingFeature`)
3. Commit your Changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the Branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

---

## 📝 License

All rights reserved. This project is not open source and is the proprietary work of the author.

---

## 👤 Author

**Senthil**

- GitHub: [@Senthil-Achievements](https://github.com/Senthil-Achievements)
- LinkedIn: [P Senthil](https://www.linkedin.com/in/p-senthil-154933276)
- Portfolio: [Artfolio](https://www.artfolio.tech/senthilportfolio)

---

## 🙏 Acknowledgments

- Flutter team for the amazing framework
- Material Design for the design system
- SQLite for reliable local storage

---

## 📞 Support

If you like this project, please consider:
- ⭐ Starring the repository
- 🐛 Reporting bugs via [Issues](../../issues)
- 💡 Suggesting new features
- 📢 Sharing with others

---

<div align="center">
  
  **Built with ❤️ by Senthil**
  
  © 2025 All Rights Reserved
  
</div>
