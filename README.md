# Hey Notes

A beautiful and intuitive note-taking app built with Flutter. Organize your thoughts, ideas, and tasks with ease.

![App Screenshot](screenshots/app_screenshot.png)

## ✨ Features

- 📝 Create, view, edit, and delete notes
- 🔍 Search through your notes by title or content
- 🏷️ Add tags to organize your notes
- 🌓 Light and dark theme support
- 📤 Share notes as text or export as files (TXT/PDF)
- 🔄 Auto-save and local storage with Hive
- 📱 Responsive design for all screen sizes

## 🚀 Getting Started

### Prerequisites

- Flutter SDK (latest stable version)
- Android Studio / Xcode (for running on emulator/device)
- VS Code or Android Studio (recommended for development)

### Installation

1. Clone the repository:
   ```bash
   git clone https://github.com/Collins-01/hey_notes.git
   cd hey_notes
   ```

2. Install dependencies:
   ```bash
   flutter pub get
   ```

3. Run the app:
   ```bash
   flutter run
   ```

## 🛠 Building the App

### For Development

```bash
flutter run
```

### For Release (APK)

1. Clean the project:
   ```bash
   flutter clean
   ```

2. Get dependencies:
   ```bash
   flutter pub get
   ```

3. Build the release APK:
   ```bash
   flutter build apk --release
   ```

4. The APK will be available at:
   ```
   build/app/outputs/flutter-apk/app-release.apk
   ```

### For Release (iOS)

1. Update the version in `pubspec.yaml`
2. Run:
   ```bash
   flutter build ios --release
   ```
3. Open Xcode and archive the app

## 📱 Screenshots

| Home Screen | Note Editor | Dark Theme |
|-------------|-------------|------------|
| ![Home](screenshots/home.png) | ![Editor](screenshots/editor.png) | ![Dark](screenshots/dark_theme.png) |

## 🛡️ Permissions

- **Android**:
  - `READ_EXTERNAL_STORAGE` - For saving exported files
  - `WRITE_EXTERNAL_STORAGE` - For saving exported files

- **iOS**:
  - `NSDocumentsFolderUsageDescription` - For file operations
  - `NSPhotoLibraryUsageDescription` - For saving files to photo library

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

