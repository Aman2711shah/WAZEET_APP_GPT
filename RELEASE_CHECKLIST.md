# WAZEET App Release Checklist
**Version:** 1.0.4+8
**Date:** November 11, 2025

---

## ⚠️ CRITICAL SECURITY CHECKS

### 1. Environment Variables & Secrets ✅
- [x] `.env` file is in `.gitignore` and NOT committed to git
- [x] `android/key.properties` is in `.gitignore` and NOT committed
- [ ] **ACTION REQUIRED**: Remove or rotate the OpenAI API key in `.env` if this repo is/will be public
  - Current key in `.env` starts with: `sk-proj-z0qvymz8...`
  - Consider using Firebase Functions to secure API calls instead of client-side keys
- [ ] Verify Firebase config files don't contain admin secrets
- [ ] Review all committed files for accidentally exposed credentials

### 2. Build Configuration ✅
- [x] Release keystore exists: `android/key.jks`
- [x] Key properties configured: `android/key.properties`
- [x] Signing config setup in `android/app/build.gradle.kts`
- [x] Version: `1.0.4+8` in `pubspec.yaml`

---

## 🔧 PRE-BUILD STEPS

### A. Code Quality
```bash
# 1. Run analyzer
flutter analyze

# 2. Run all tests
flutter test

# 3. Run integration tests (if available)
flutter test integration_test

# 4. Check for outdated dependencies
flutter pub outdated
```

### B. Clean Build Environment
```bash
# Clean previous builds
flutter clean
flutter pub get

# Clear device caches
rm -rf build/
rm -rf .dart_tool/
```

### C. Update Version (if needed)
Current version: `1.0.4+8`
- Update in `pubspec.yaml`
- Format: `version: MAJOR.MINOR.PATCH+BUILD_NUMBER`
- Example next version: `1.0.5+9`

---

## 📱 ANDROID RELEASE BUILD

### 1. Build Release AAB (for Play Store)
```bash
# Build App Bundle (recommended for Play Store)
flutter build appbundle --release

# Output location:
# build/app/outputs/bundle/release/app-release.aab
```

### 2. Build Release APK (for direct distribution/testing)
```bash
# Build APK
flutter build apk --release --split-per-abi

# Output locations:
# build/app/outputs/flutter-apk/app-armeabi-v7a-release.apk
# build/app/outputs/flutter-apk/app-arm64-v8a-release.apk
# build/app/outputs/flutter-apk/app-x86_64-release.apk
```

### 3. Verify Android Build
```bash
# Install on physical device
adb install build/app/outputs/flutter-apk/app-arm64-v8a-release.apk

# Or for AAB, use bundletool:
# Download: https://github.com/google/bundletool/releases
java -jar bundletool.jar build-apks \
  --bundle=build/app/outputs/bundle/release/app-release.aab \
  --output=wazeet.apks \
  --mode=universal

unzip -p wazeet.apks universal.apk > wazeet.apk
adb install wazeet.apk
```

### 4. Android Smoke Tests
- [ ] App launches without crashes
- [ ] Sign in with Google works
- [ ] Sign in with Apple works (if testing on compatible device)
- [ ] Navigate all tabs: Services, Free Zones, Community, Account
- [ ] Search functionality works (services search with sub-services)
- [ ] Service details load correctly
- [ ] Free zone details load correctly
- [ ] Community feed loads and posts display
- [ ] Payment flow initializes (don't complete actual payment)
- [ ] File upload works (document picker)
- [ ] Logout and re-login works

---

## 🍎 iOS RELEASE BUILD

### 1. Pre-build iOS Setup
```bash
# Navigate to iOS directory
cd ios

# Install/update CocoaPods
pod install --repo-update

cd ..
```

### 2. Build iOS Release
```bash
# Build iOS release (creates .app)
flutter build ios --release

# The output will be in:
# build/ios/iphoneos/Runner.app
```

### 3. Create Archive via Xcode
**You MUST use Xcode for App Store distribution:**

1. Open Xcode:
   ```bash
   open ios/Runner.xcworkspace
   ```

2. In Xcode:
   - Select **Product > Scheme > Runner**
   - Select **Any iOS Device** or a physical device (NOT simulator)
   - Select **Product > Archive**
   - Wait for archive to complete
   - **Window > Organizer** will open automatically
   - Select your archive
   - Click **Distribute App**
   - Choose **App Store Connect**
   - Follow prompts to upload

### 4. iOS Smoke Tests (via TestFlight)
- [ ] App launches without crashes
- [ ] Sign in with Apple works
- [ ] Sign in with Google works
- [ ] Navigate all tabs: Services, Free Zones, Community, Account
- [ ] Search functionality works
- [ ] Service details load correctly
- [ ] Free zone details load correctly
- [ ] Community feed loads and posts display
- [ ] Payment flow works (Stripe integration)
- [ ] File upload works
- [ ] Logout and re-login works
- [ ] Push notifications work (if implemented)

---

## 🏪 STORE METADATA PREPARATION

### Google Play Store

#### Required Screenshots (upload in Play Console)
- **Phone:**
  - Minimum 2 screenshots
  - Recommended: 4-8 screenshots
  - JPEG or 24-bit PNG (no alpha)
  - Min dimension: 320px
  - Max dimension: 3840px
  - Max aspect ratio: 2:1

- **Tablet (optional but recommended):**
  - 7-inch and 10-inch tablets
  - Similar requirements as phone

- **Feature Graphic:**
  - 1024 x 500 px
  - JPEG or 24-bit PNG (no alpha)

#### App Description
- **Short description:** Max 80 characters
- **Full description:** Max 4000 characters
- Highlight key features:
  - UAE business setup services
  - Free zone comparison
  - AI-powered business consultation
  - Community features
  - Secure payments

#### Privacy Policy
- [ ] Upload/link privacy policy URL
- [ ] Review data safety section:
  - Data collected (emails, names, payment info)
  - Data sharing practices
  - Security measures
  - User controls

#### Release Notes (v1.0.4)
Example:
```
What's New in v1.0.4:
• Enhanced services search - now includes sub-services
• Improved search functionality across all service categories
• Bug fixes and performance improvements
• Updated UI for better user experience
```

### Apple App Store

#### Required Screenshots
- **iPhone:**
  - 6.7" (iPhone 14 Pro Max, 15 Pro Max): 1290 x 2796 px
  - 6.5" (iPhone 11 Pro Max, XS Max): 1242 x 2688 px
  - 5.5" (iPhone 8 Plus): 1242 x 2208 px

- **iPad (if supporting):**
  - 12.9" iPad Pro: 2048 x 2732 px
  - 11" iPad Pro: 1668 x 2388 px

#### App Description
- **Subtitle:** Max 30 characters
- **Promotional text:** Max 170 characters (can be updated without review)
- **Description:** Max 4000 characters

#### Privacy Details
Required in App Store Connect:
- [ ] Data collection practices
- [ ] Data usage policies
- [ ] Third-party SDK data collection
- [ ] Privacy policy URL

#### Release Notes
Example:
```
Version 1.0.4

NEW FEATURES:
• Enhanced search - Find services and sub-services faster
• Improved UI across all screens

IMPROVEMENTS:
• Better performance and stability
• Updated service categories

BUG FIXES:
• Fixed search filtering issues
• Resolved navigation glitches
```

---

## 🧪 INTERNAL TESTING

### Android (Play Console Internal Testing)
1. Go to Play Console
2. Navigate to **Testing > Internal testing**
3. Create new release
4. Upload AAB file
5. Add release notes
6. Add internal testers (email addresses)
7. Save and review
8. Start rollout to internal testing

### iOS (TestFlight)
1. After uploading build via Xcode
2. Go to App Store Connect
3. Navigate to **TestFlight** tab
4. Select your build
5. Add internal testers
6. Fill out export compliance info
7. Enable testing
8. Testers will receive email invitation

### Testing Checklist (Both Platforms)
- [ ] Fresh install on physical device
- [ ] Sign up new account
- [ ] Sign in with existing account
- [ ] Test all major features
- [ ] Test on slow network
- [ ] Test in airplane mode (offline behavior)
- [ ] Test with different screen sizes
- [ ] Check error messages are user-friendly
- [ ] Verify all images load
- [ ] Test payment flow end-to-end
- [ ] Check analytics/crash reporting works

---

## 🚀 PRODUCTION RELEASE

### Pre-Release Final Checks
- [ ] All internal testing completed
- [ ] No critical bugs reported
- [ ] Analytics/monitoring configured
- [ ] Backend services verified
- [ ] Firebase Functions deployed
- [ ] Database rules reviewed
- [ ] Storage rules reviewed
- [ ] Payment gateway tested in production mode
- [ ] Customer support ready

### Google Play Store Release
1. Go to **Production** track in Play Console
2. Create new release
3. Upload AAB (same file as tested in internal)
4. Add release notes
5. Review and start rollout
6. Options:
   - **Staged rollout:** Start with 10-20% of users
   - **Full rollout:** 100% of users immediately

### Apple App Store Release
1. In App Store Connect, go to **App Store** tab
2. Create new version (1.0.4)
3. Select build from TestFlight
4. Fill in all required metadata
5. Submit for review
6. Wait for Apple review (1-3 days typically)
7. Once approved, choose:
   - **Automatic release:** Goes live immediately
   - **Manual release:** You control timing

---

## 📊 POST-RELEASE MONITORING

### First 24 Hours
- [ ] Monitor crash reports (Firebase Crashlytics)
- [ ] Check user reviews/ratings
- [ ] Monitor analytics for:
  - Install/uninstall rates
  - User engagement
  - Feature usage
  - Error rates
- [ ] Watch for payment processing issues
- [ ] Monitor backend logs

### First Week
- [ ] Respond to user reviews
- [ ] Track key metrics
- [ ] Plan hotfix if critical issues found
- [ ] Gather user feedback
- [ ] Monitor competition

---

## 🛠️ ROLLBACK PLAN

### If Critical Issues Found

#### Android
1. Stop staged rollout in Play Console
2. Halt release
3. Fix issues
4. Test thoroughly
5. Upload new build with incremented version
6. Resume rollout

#### iOS
1. Remove app from sale (temporary)
2. Expedited review process available for critical bugs
3. Submit hotfix build
4. Request expedited review
5. Re-enable sale once approved

---

## 📋 BUILD COMMANDS SUMMARY

### Full Release Script (Android)
```bash
#!/bin/bash
# Save as: scripts/release-android.sh

set -e

echo "🧹 Cleaning previous builds..."
flutter clean
flutter pub get

echo "🔍 Running analyzer..."
flutter analyze

echo "🧪 Running tests..."
flutter test

echo "📦 Building release AAB..."
flutter build appbundle --release

echo "📦 Building release APKs..."
flutter build apk --release --split-per-abi

echo "✅ Android builds complete!"
echo "AAB: build/app/outputs/bundle/release/app-release.aab"
echo "APKs: build/app/outputs/flutter-apk/"
```

### Full Release Script (iOS)
```bash
#!/bin/bash
# Save as: scripts/release-ios.sh

set -e

echo "🧹 Cleaning previous builds..."
flutter clean
flutter pub get

echo "📦 Installing CocoaPods..."
cd ios
pod install --repo-update
cd ..

echo "🔍 Running analyzer..."
flutter analyze

echo "🧪 Running tests..."
flutter test

echo "📦 Building iOS release..."
flutter build ios --release

echo "✅ iOS build complete!"
echo "Now open Xcode to create archive:"
echo "  open ios/Runner.xcworkspace"
```

---

## 🔐 SECURITY FINAL CHECKS

- [ ] All API keys are server-side or properly secured
- [ ] No hardcoded credentials in source code
- [ ] SSL/TLS pinning implemented (if applicable)
- [ ] ProGuard/R8 obfuscation enabled for Android
- [ ] Bitcode enabled for iOS (if applicable)
- [ ] App Transport Security configured
- [ ] Sensitive data encrypted at rest
- [ ] Proper session management
- [ ] Rate limiting on backend APIs
- [ ] Input validation on all forms

---

## 📞 SUPPORT PREPAREDNESS

- [ ] Support email configured: support@wazeet.com
- [ ] Support phone ready: +971559986386
- [ ] FAQ/Help section updated
- [ ] Customer support team briefed on new features
- [ ] Escalation process defined
- [ ] Response templates prepared

---

## ✅ FINAL SIGN-OFF

- [ ] Tech Lead approval
- [ ] QA approval
- [ ] Product Owner approval
- [ ] Legal/Compliance approval (if applicable)
- [ ] Marketing team notified
- [ ] Press release prepared (if applicable)

---

**Good luck with your release! 🚀**
