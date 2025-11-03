# ✅ Beta Distribution Setup Checklist

Use this checklist to track your setup progress for iOS and Android beta distribution.

---

## 📋 Pre-Setup (Both Platforms)

- [ ] Fastlane installed: `gem install fastlane`
- [ ] Flutter dependencies updated: `flutter pub get`
- [ ] Git configured with proper user name and email
- [ ] Code committed and pushed to remote
- [ ] No uncommitted changes in working directory

---

## 🍎 iOS Setup Checklist

### Prerequisites
- [ ] macOS machine with Xcode 15+ installed
- [ ] Apple Developer account (Admin or App Manager role)
- [ ] App created in App Store Connect

### App Store Connect API Key
- [ ] API Key created in App Store Connect
- [ ] Downloaded `.p8` file
- [ ] Noted Key ID
- [ ] Noted Issuer ID
- [ ] API Key stored securely (e.g., 1Password)

### Code Signing (Match)
- [ ] Private Git repository created for certificates
- [ ] Repository access configured (SSH or HTTPS token)
- [ ] Match initialized: `cd ios && fastlane match init`
- [ ] Match passphrase set (strong and secure)
- [ ] Certificates generated: `fastlane match appstore`
- [ ] Match repository URL saved
- [ ] Match passphrase stored securely

### Xcode Configuration
- [ ] Opened `ios/Runner.xcworkspace` in Xcode
- [ ] Team selected in Runner target → Signing & Capabilities
- [ ] Bundle Identifier verified: `com.wazeet.wazeet`
- [ ] "Automatically manage signing" enabled (if not using Match)

### Fastlane Setup
- [ ] Navigated to ios directory: `cd ios`
- [ ] Bundle install run: `bundle install`
- [ ] Fastfile reviewed and understood
- [ ] Gemfile present

### Local Test
- [ ] Test build successful: `bundle exec fastlane build`
- [ ] Test deployment successful: `./scripts/deploy-ios-beta.sh`
- [ ] Build appears in App Store Connect → TestFlight
- [ ] Version number incremented correctly
- [ ] Git tag created

---

## 🤖 Android Setup Checklist

### Prerequisites
- [ ] Google Play Console account (Release Manager or Admin)
- [ ] App created in Play Console
- [ ] At least one manual release uploaded to Internal Testing

### Upload Keystore
- [ ] Keystore generated (if new app)
- [ ] Keystore password saved securely
- [ ] Key alias noted
- [ ] Key password saved securely
- [ ] Keystore file: `android/app/upload-keystore.jks`

### Key Properties
- [ ] Created `android/key.properties`
- [ ] Populated with keystore details
- [ ] File added to .gitignore (verified not committed)

### Build Configuration
- [ ] Updated `android/app/build.gradle.kts` with signing config
- [ ] Loaded `key.properties` in Gradle script
- [ ] Created release signing config
- [ ] Applied signing config to release build type
- [ ] Test build successful: `flutter build appbundle --release`

### Play Console Service Account
- [ ] Service account created in Play Console → API access
- [ ] Permissions granted (Release Manager or Admin)
- [ ] JSON key downloaded
- [ ] Saved as `android/play-store-credentials.json`
- [ ] File added to .gitignore (verified not committed)

### Fastlane Setup
- [ ] Navigated to android directory: `cd android`
- [ ] Bundle install run: `bundle install`
- [ ] Fastfile reviewed and understood
- [ ] Gemfile present

### Local Test
- [ ] Test build successful: `bundle exec fastlane build`
- [ ] Test deployment successful: `./scripts/deploy-android-beta.sh`
- [ ] Build appears in Play Console → Internal Testing
- [ ] Version code incremented correctly
- [ ] Git tag created

---

## 🔐 GitHub Actions Setup (Optional)

### Repository Configuration
- [ ] Repository is public or has Actions enabled
- [ ] GitHub Actions workflows enabled

### iOS Secrets (8 required)
- [ ] `APP_STORE_CONNECT_KEY_ID`
- [ ] `APP_STORE_CONNECT_ISSUER_ID`
- [ ] `APP_STORE_CONNECT_KEY_CONTENT` (entire .p8 file)
- [ ] `MATCH_GIT_URL`
- [ ] `MATCH_PASSWORD`
- [ ] `MATCH_GIT_BASIC_AUTHORIZATION` (base64 of username:token)
- [ ] `FASTLANE_USER` (Apple ID)
- [ ] `FASTLANE_PASSWORD` (Apple ID password)
- [ ] `FASTLANE_APPLE_APPLICATION_SPECIFIC_PASSWORD`

### Android Secrets (3 required)
- [ ] `ANDROID_KEYSTORE_BASE64` (base64 of .jks file)
- [ ] `ANDROID_KEY_PROPERTIES` (entire file content)
- [ ] `PLAY_STORE_CONFIG_JSON` (entire JSON content)

### Workflow Testing
- [ ] Workflow file present: `.github/workflows/deploy-beta.yml`
- [ ] Workflow syntax validated (GitHub Actions tab)
- [ ] Manual trigger tested from Actions tab
- [ ] Tag trigger tested: `git tag v1.0.0-beta && git push origin v1.0.0-beta`
- [ ] Builds successful in Actions logs
- [ ] Apps appear in TestFlight/Play Console after workflow

---

## 🧪 Testing Checklist

### Alpha Testing (Internal)
- [ ] Test plan reviewed: `docs/TEST_PLAN_ALPHA.md`
- [ ] Internal testers added to TestFlight/Play Console
- [ ] Test accounts documented securely
- [ ] Bug report template shared with testers
- [ ] Critical paths tested on 3 device sizes
- [ ] No P0/P1 bugs remaining
- [ ] Crash-free rate ≥ 99%
- [ ] Alpha exit criteria met

### Beta Testing (External)
- [ ] Test plan reviewed: `docs/TEST_PLAN_BETA.md`
- [ ] External testers invited (10-50)
- [ ] Release notes shared with testers
- [ ] Feedback channels set up (forms, email)
- [ ] Analytics/crash reporting enabled
- [ ] Beta issues triaged daily
- [ ] Crash-free sessions ≥ 99.5%
- [ ] SUS score ≥ 70
- [ ] Task completion rate ≥ 90%
- [ ] Beta exit criteria met

---

## 📚 Documentation Review

- [ ] Read: `docs/BETA_DISTRIBUTION.md` (full setup guide)
- [ ] Read: `BETA_DEPLOY_QUICK_START.md` (quick reference)
- [ ] Read: `docs/TEST_PLAN_ALPHA.md`
- [ ] Read: `docs/TEST_PLAN_BETA.md`
- [ ] Read: `docs/DEPLOYMENT_ARCHITECTURE.md` (optional, visual diagrams)
- [ ] Reviewed: `.github/ISSUE_TEMPLATE/bug_report.md`

---

## 🎯 One-Command Deployment Ready

Once all boxes above are checked:

```bash
# iOS beta to TestFlight
./scripts/deploy-ios-beta.sh

# Android beta to Play Console
./scripts/deploy-android-beta.sh

# Both platforms
./scripts/deploy-beta-all.sh
```

**Success indicators:**
- ✅ Script runs without errors
- ✅ Build uploaded to platform
- ✅ Version incremented and committed
- ✅ Git tag created and pushed
- ✅ App appears in TestFlight/Internal Testing shortly

---

## 🆘 Need Help?

- Troubleshooting: See `docs/BETA_DISTRIBUTION.md` → Troubleshooting section
- Common issues: Check `BETA_DEPLOY_QUICK_START.md` → Common Issues
- File bug: Use `.github/ISSUE_TEMPLATE/bug_report.md` template
- Fastlane docs: https://docs.fastlane.tools

---

**Completion Status:** _____% (_____ of _____ items checked)

**Last Updated:** _______________
