# 🚀 Quick Build Reference

## One-Command Build

```bash
# Build everything (Android + iOS if on macOS)
./scripts/build_release.sh

# Android only
./scripts/build_release.sh android

# iOS only (macOS only)
./scripts/build_release.sh ios
```

---

## 📦 Output Locations

| Platform | File Type | Location |
|----------|-----------|----------|
| Android | APK | `build/app/outputs/flutter-apk/*.apk` |
| Android | AAB | `build/app/outputs/bundle/release/app-release.aab` |
| iOS | IPA | `build/ios/ipa/wazeet.ipa` |

---

## 🔐 First-Time Setup

### Android Keystore (One-Time)
```bash
cd android
keytool -genkey -v -keystore key.jks -keyalg RSA \
  -keysize 2048 -validity 10000 -alias wazeet
```

Update `android/key.properties` with your passwords.

### iOS Signing (macOS Only)
```bash
open ios/Runner.xcworkspace
# Signing & Capabilities → Select Team
```

---

## 🧪 Test Builds

### Android
```bash
# Install on device
adb install build/app/outputs/flutter-apk/app-arm64-v8a-release.apk
```

### iOS
```bash
# Upload to TestFlight
open ios/Runner.xcworkspace
# Product → Archive → Distribute
```

---

## 📤 Upload

### Google Play
1. [Play Console](https://play.google.com/console)
2. Production → New Release
3. Upload `app-release.aab`

### App Store
1. [App Store Connect](https://appstoreconnect.apple.com)
2. TestFlight → Upload
3. Submit for Review

---

## 🔄 Version Bump

Edit `pubspec.yaml`:
```yaml
version: 1.0.1+2  # name+build
```

---

## 📊 Build Report

After build completes, check:
```
BUILD_REPORT.md
```

Contains:
- ✅ Version info
- 📦 Artifact paths & sizes
- 🔐 Checksums
- 📤 Upload instructions

---

## ⚡ Quick Commands

```bash
# Clean
flutter clean

# Get deps
flutter pub get

# Analyze
flutter analyze

# Build Android APK
flutter build apk --release --split-per-abi

# Build Android AAB
flutter build appbundle --release

# Build iOS IPA
flutter build ipa --release --export-method app-store

# Run tests
flutter test
```

---

## 🐛 Common Fixes

**Keystore not found:**
```bash
cd android
keytool -genkey -v -keystore key.jks -keyalg RSA -keysize 2048 -validity 10000 -alias wazeet
```

**iOS signing error:**
```bash
open ios/Runner.xcworkspace
# Configure signing in Xcode
```

**Pod install fails:**
```bash
cd ios && rm -rf Pods Podfile.lock && pod install --repo-update
```

**Gradle memory error:**
```properties
# android/gradle.properties
org.gradle.jvmargs=-Xmx4G
```

---

**Full Documentation:** `BUILD_GUIDE.md`
