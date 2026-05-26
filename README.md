# Smart Scan — Billing Application

A Flutter-based mobile app for scanning items and managing billing quickly and reliably.

**Core features**
- Scan barcodes/QR codes and extract product information.
- Create and manage bills/invoices.
- Persist data locally and sync with Firebase (optional).

**Prerequisites**
- Install Flutter SDK (stable channel) and ensure `flutter` is on your PATH.
- For Android: Android SDK and an emulator or device.
- For iOS (macOS only): Xcode and related tools.

**Setup**

1. Clone the repo:

```
git clone <repo-url>
cd Smart-Scan-Billing-Apllication
```

2. Install dependencies:

```
flutter pub get
```

**Environment & secrets**

- This project excludes sensitive files from git. Add the following locally if you use Firebase or Android services:
  - `android/app/google-services.json` (Android Firebase config)
  - `ios/GoogleService-Info.plist` (iOS Firebase config)
  - `local.properties` (Android SDK path)
  - Keystore files (`*.jks`, `*.keystore`) and `key.properties` for signing

- The repository's `.gitignore` includes `android/app/google-services.json` so do not commit those files.

**Running the app**

- Run on a connected Android device or emulator:

```
flutter run -d android
```

- Run on the web:

```
flutter run -d chrome
```

**Building release**

- Android release build:

```
flutter build apk --release
```

- iOS release build (macOS only):

```
flutter build ios --release
```

**Testing**

```
flutter test
```

**Common issues**

- If Flutter cannot find the Android SDK, create or update `local.properties` with:

```
sdk.dir=C:\Users\<YourUser>\AppData\Local\Android\sdk
```

- If Firebase throws configuration errors, ensure the platform-specific config files are present and correctly placed.

**Contributing**

- Fork, create a branch, and open a PR. Keep changes small and focused.

**License**

This project does not include a license file. Add one if you plan to open-source the code.

---

If you'd like, I can expand any section (detailed build steps, CI, or example environment files).# smartscan_app

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Learn Flutter](https://docs.flutter.dev/get-started/learn-flutter)
- [Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Flutter learning resources](https://docs.flutter.dev/reference/learning-resources)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
