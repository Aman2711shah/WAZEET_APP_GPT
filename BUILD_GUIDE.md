# 🚀 WAZEET Production Build Guide

Complete guide for building production-ready Android APK/AAB and iOS IPA files.

---

## 📋 Prerequisites

### Required Tools

| Tool | Version | Installation |
|------|---------|--------------|
| Flutter | 3.24.0+ | [flutter.dev](https://flutter.dev/docs/get-started/install) |
| Android Studio | Latest | [developer.android.com](https://developer.android.com/studio) |
| Xcode | 15.0+ | Mac App Store (macOS only) |
| CocoaPods | 1.11+ | `sudo gem install cocoapods` |
| Java JDK | 11+ | Bundled with Android Studio |

### Platform Support

| Platform | Android | iOS |
|----------|---------|-----|
| macOS | ✅ | ✅ |
| Linux | ✅ | ❌ |
| Windows | ✅ | ❌ |

---

## 🔐 Android Signing Setup (One-Time)

### 1. Generate Release Keystore

```bash
# Navigate to android directory
cd android

# Generate keystore
keytool -genkey -v -keystore key.jks -keyalg RSA -keysize 2048 -validity 10000 -alias wazeet

# You'll be prompted for:
# - Keystore password (remember this!)
# - Key password (can be same as keystore password)
# - Your name, organization, city, state, country
```

**⚠️ IMPORTANT:** 
- Store the keystore file (`android/key.jks`) securely
- **Never commit it to version control** (already in `.gitignore`)
- Back it up in a secure location
- If you lose this keystore, you cannot update your app on Google Play!

### 2. Configure key.properties

The `android/key.properties` file is already created. Update it with your actual passwords:

```properties
storePassword=YOUR_KEYSTORE_PASSWORD
keyPassword=YOUR_KEY_PASSWORD
keyAlias=wazeet
storeFile=../key.jks
```

### 3. Verify Configuration

```bash
# Check keystore is readable
keytool -list -v -keystore android/key.jks -alias wazeet

# Check build.gradle.kts has signing config
grep -A 5 "signingConfigs" android/app/build.gradle.kts
```

---

## 🍏 iOS Signing Setup (macOS Only)

### 1. Apple Developer Account

- Enroll in [Apple Developer Program](https://developer.apple.com/programs/) ($99/year)
- Create App ID in [App Store Connect](https://appstoreconnect.apple.com)
- Bundle ID: `com.wazeet.wazeet` (already configured)

### 2. Code Signing in Xcode

```bash
# Open workspace
open ios/Runner.xcworkspace

# In Xcode:
# 1. Select "Runner" project
# 2. Go to "Signing & Capabilities" tab
# 3. Select your Team (Apple Developer account)
# 4. Ensure "Automatically manage signing" is checked
# 5. Verify Bundle Identifier is "com.wazeet.wazeet"
```

### 3. Create App Store Connect Entry

1. Go to [App Store Connect](https://appstoreconnect.apple.com)
2. Click **My Apps** → **+** → **New App**
3. Enter app details:
   - **Platform:** iOS
   - **Name:** WAZEET
   - **Primary Language:** English
   - **Bundle ID:** com.wazeet.wazeet
   - **SKU:** wazeet-ios

---

## 🔨 Building Releases

### Quick Build (All Platforms)

```bash
# Build both Android and iOS (if on macOS)
./scripts/build_release.sh

# Build Android only
./scripts/build_release.sh android

# Build iOS only
./scripts/build_release.sh ios
```

### Manual Build Steps

#### Android APK

```bash
# Clean and prepare
flutter clean
flutter pub get
flutter analyze

# Build split APKs (smaller size)
flutter build apk --release --split-per-abi

# Output: build/app/outputs/flutter-apk/
# - app-armeabi-v7a-release.apk (32-bit ARM)
# - app-arm64-v8a-release.apk (64-bit ARM, most common)
# - app-x86_64-release.apk (Intel emulators)
```

#### Android AAB (Play Store)

```bash
# Build App Bundle
flutter build appbundle --release

# Output: build/app/outputs/bundle/release/app-release.aab
```

#### iOS IPA

```bash
# Update CocoaPods
cd ios
pod install --repo-update
cd ..

# Build IPA
flutter build ipa --release --export-method app-store

# Output: build/ios/ipa/wazeet.ipa
```

---

## 📦 Build Artifacts

### Android

| File | Purpose | Size (approx) |
|------|---------|---------------|
| `app-arm64-v8a-release.apk` | 64-bit ARM devices (most phones) | ~50-80 MB |
| `app-armeabi-v7a-release.apk` | 32-bit ARM devices (older) | ~45-75 MB |
| `app-x86_64-release.apk` | Intel emulators | ~55-85 MB |
| `app-release.aab` | Google Play Store upload | ~60-90 MB |

### iOS

| File | Purpose | Size (approx) |
|------|---------|---------------|
| `wazeet.ipa` | App Store / TestFlight upload | ~60-100 MB |

---

## 🧪 Testing Release Builds

### Android

```bash
# Install on connected device
adb install build/app/outputs/flutter-apk/app-arm64-v8a-release.apk

# Check installed version
adb shell dumpsys package com.wazeet.app | grep versionName

# View logs
adb logcat | grep -i flutter
```

### iOS

```bash
# Install via Xcode
open ios/Runner.xcworkspace
# Product → Archive → Distribute → Development
# Install on connected device

# Or use TestFlight:
# Upload IPA to App Store Connect
# Add internal testers
# Install via TestFlight app
```

---

## 📤 Publishing

### Google Play Store

1. **Create App Listing**
   - Go to [Google Play Console](https://play.google.com/console)
   - Create new app
   - Fill in app details, descriptions, screenshots

2. **Upload AAB**
   - Navigate to **Production** → **Create new release**
   - Upload `app-release.aab`
   - Add release notes
   - Review and rollout

3. **Internal Testing** (Recommended)
   - Use **Internal Testing** track first
   - Add testers via email
   - Get feedback before production

### Apple App Store

1. **Upload to TestFlight**
   ```bash
   # Option 1: Xcode
   open ios/Runner.xcworkspace
   # Product → Archive → Distribute → App Store Connect
   
   # Option 2: Command line (requires app-specific password)
   xcrun altool --upload-app --type ios --file "build/ios/ipa/wazeet.ipa" \
     --username "your@apple.id" --password "@keychain:APP_SPECIFIC_PASSWORD"
   ```

2. **TestFlight Beta Testing**
   - Add internal testers in App Store Connect
   - Get feedback from beta testers
   - Fix any issues before public release

3. **Submit for Review**
   - Complete all app metadata
   - Add screenshots (6.7", 6.5", 5.5" sizes)
   - Submit for App Store review
   - Review typically takes 1-2 days

---

## 🔄 Version Management

### Current Version

Check `pubspec.yaml`:
```yaml
version: 1.0.0+1
#        ^^^^^ ^^
#        name  build number
```

### Incrementing Version

**For minor updates (bug fixes):**
```bash
# 1.0.0+1 → 1.0.1+2
# Update manually in pubspec.yaml
```

**For major updates (new features):**
```bash
# 1.0.0+1 → 1.1.0+2
# Update manually in pubspec.yaml
```

**The build script will prompt to auto-increment build number.**

### Version Checklist

- [ ] Increment `version` in `pubspec.yaml`
- [ ] Update `CHANGELOG.md` with new features/fixes
- [ ] Commit version bump: `git commit -m "Bump version to 1.0.1"`
- [ ] Tag release: `git tag v1.0.1 && git push --tags`

---

## 🐛 Troubleshooting

### Android Issues

#### "No keystore found"
```bash
# Generate new keystore
cd android
keytool -genkey -v -keystore key.jks -keyalg RSA -keysize 2048 -validity 10000 -alias wazeet
```

#### "Execution failed for task ':app:lintVitalRelease'"
```bash
# Disable lint errors in android/app/build.gradle.kts
android {
    lintOptions {
        checkReleaseBuilds = false
    }
}
```

#### "Minimum supported Gradle version"
```bash
# Update gradle wrapper
cd android
./gradlew wrapper --gradle-version 8.0
```

### iOS Issues

#### "Code signing error"
```bash
# Open Xcode and configure signing
open ios/Runner.xcworkspace
# Select Runner → Signing & Capabilities → Select Team
```

#### "Pod install fails"
```bash
cd ios
rm -rf Pods Podfile.lock
pod install --repo-update
```

#### "Archive not showing in Organizer"
```bash
# Ensure scheme is set to Release
# Product → Scheme → Edit Scheme → Run → Build Configuration → Release
```

### Common Flutter Issues

#### "Flutter SDK not found"
```bash
flutter doctor -v
flutter upgrade
```

#### "Dependency version conflict"
```bash
flutter pub get
flutter pub upgrade
```

#### "Build fails with memory error"
```bash
# Increase Gradle memory in android/gradle.properties
org.gradle.jvmargs=-Xmx4G
```

---

## 📊 Build Performance

### Typical Build Times (M1 Mac)

| Task | Duration |
|------|----------|
| `flutter clean` | 5s |
| `flutter pub get` | 15s |
| `flutter build apk` | 2-3 min |
| `flutter build appbundle` | 2-3 min |
| `flutter build ipa` | 5-8 min |
| **Total (both platforms)** | **~15-20 min** |

### Optimization Tips

1. **Use build cache:**
   ```bash
   # Don't run flutter clean every time
   # Only clean when necessary
   ```

2. **Parallel builds (Gradle):**
   ```properties
   # android/gradle.properties
   org.gradle.parallel=true
   org.gradle.workers.max=4
   ```

3. **Skip unnecessary tasks:**
   ```bash
   # Build APK without running tests
   flutter build apk --release --no-test
   ```

---

## 🔒 Security Checklist

Before releasing to production:

- [ ] Remove all `print()` statements
- [ ] Obfuscate code (`--obfuscate` flag)
- [ ] Disable debug logging
- [ ] Verify API keys are not hardcoded
- [ ] Check Firebase security rules
- [ ] Enable ProGuard/R8 (Android)
- [ ] Test on physical devices
- [ ] Run penetration tests
- [ ] Review app permissions
- [ ] Test payment flows in production mode

---

## 📞 Support

- **Flutter Issues:** [GitHub Issues](https://github.com/flutter/flutter/issues)
- **Android Issues:** [Stack Overflow](https://stackoverflow.com/questions/tagged/android)
- **iOS Issues:** [Apple Developer Forums](https://developer.apple.com/forums/)

---

## 📝 Build Report

After running `./scripts/build_release.sh`, check `BUILD_REPORT.md` for:
- Version information
- Build artifacts with paths and sizes
- Checksums for verification
- Upload instructions
- Pre-release checklist

---

**Last Updated:** November 3, 2025  
**Build Script:** `scripts/build_release.sh`  
**Version:** 1.0.0
