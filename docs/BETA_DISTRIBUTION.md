# Beta Distribution Setup Guide

This guide explains how to set up and use automated beta distribution for the WAZEET app using Fastlane and GitHub Actions.

## Quick Start (One Command)

Once set up, deploy beta builds with a single command:

```bash
# Deploy iOS beta to TestFlight
./scripts/deploy-ios-beta.sh

# Deploy Android beta to Play Console
./scripts/deploy-android-beta.sh

# Deploy both platforms
./scripts/deploy-beta-all.sh
```

---

## Prerequisites

### General
- [Flutter SDK](https://flutter.dev/docs/get-started/install) (3.24.x or later)
- [Fastlane](https://docs.fastlane.tools/getting-started/ios/setup/) installed via `gem install fastlane`
- Git configured with proper credentials

### iOS Requirements
- macOS with Xcode 15+ installed
- Apple Developer account with Admin or App Manager role
- App Store Connect API Key (recommended) OR Apple ID credentials
- Code signing certificates and provisioning profiles (via Match or manual)

### Android Requirements
- Google Play Console account with release permissions
- Upload keystore for app signing
- Play Console Service Account JSON key

---

## iOS Setup

### 1. App Store Connect API Key (Recommended)

1. Go to [App Store Connect → Users and Access → Keys](https://appstoreconnect.apple.com/access/api)
2. Create a new API key with **App Manager** or **Admin** role
3. Download the `.p8` file
4. Note the **Key ID** and **Issuer ID**

### 2. Code Signing with Match (Recommended for Teams)

Fastlane Match stores certificates and profiles in a private Git repository.

```bash
cd ios
fastlane match init
```

Follow prompts to:
- Choose `git` storage
- Provide a private Git repository URL for storing certificates
- Set a strong passphrase

Then generate certificates:

```bash
fastlane match appstore
```

### 3. Configure Xcode Project

1. Open `ios/Runner.xcworkspace` in Xcode
2. Select **Runner** target → **Signing & Capabilities**
3. Choose your **Team**
4. Verify **Bundle Identifier**: `com.wazeet.wazeet`
5. Enable **Automatically manage signing** (if not using Match)

### 4. Test Local Build

```bash
./scripts/deploy-ios-beta.sh
```

---

## Android Setup

### 1. Create Upload Keystore

If you don't have one already:

```bash
keytool -genkey -v -keystore upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
```

**Important**: Store the keystore password, key password, and alias securely (e.g., 1Password).

### 2. Configure Signing

Create `android/key.properties`:

```properties
storePassword=<your-store-password>
keyPassword=<your-key-password>
keyAlias=upload
storeFile=../app/upload-keystore.jks
```

**Never commit this file to Git.** Add to `.gitignore`:

```bash
echo "android/key.properties" >> .gitignore
echo "android/app/upload-keystore.jks" >> .gitignore
```

### 3. Update `android/app/build.gradle.kts`

Add signing configuration:

```kotlin
// Load keystore properties
val keystorePropertiesFile = rootProject.file("key.properties")
val keystoreProperties = Properties()
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}

android {
    // ... existing config

    signingConfigs {
        create("release") {
            keyAlias = keystoreProperties["keyAlias"] as String?
            keyPassword = keystoreProperties["keyPassword"] as String?
            storeFile = keystoreProperties["storeFile"]?.let { file(it) }
            storePassword = keystoreProperties["storePassword"] as String?
        }
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("release")
        }
    }
}
```

### 4. Play Console Service Account

1. Go to [Google Play Console → Setup → API access](https://play.google.com/console/developers/api-access)
2. Create a new service account or use existing
3. Grant **Release Manager** or **Admin** permissions
4. Download the JSON key file
5. Save as `android/play-store-credentials.json`

**Never commit this file.** Add to `.gitignore`:

```bash
echo "android/play-store-credentials.json" >> .gitignore
```

### 5. Initialize Play Console App

Ensure your app is created in Play Console with:
- At least one manual release in **Internal Testing** track
- App bundle uploaded (required for first-time setup)

### 6. Test Local Build

```bash
./scripts/deploy-android-beta.sh
```

---

## GitHub Actions (CI/CD)

The workflow `.github/workflows/deploy-beta.yml` automates beta deployments.

### Required GitHub Secrets

#### iOS Secrets

| Secret Name | Description | Example/Source |
|------------|-------------|----------------|
| `APP_STORE_CONNECT_KEY_ID` | API Key ID | `ABC123DEFG` |
| `APP_STORE_CONNECT_ISSUER_ID` | API Issuer ID | `12345678-1234-1234-1234-123456789012` |
| `APP_STORE_CONNECT_KEY_CONTENT` | API Key `.p8` file content | Copy entire file content |
| `MATCH_GIT_URL` | Match repo URL | `https://github.com/yourorg/certificates` |
| `MATCH_PASSWORD` | Match encryption passphrase | Your strong passphrase |
| `MATCH_GIT_BASIC_AUTHORIZATION` | Match repo auth token (base64) | `base64(username:token)` |
| `FASTLANE_USER` | Apple ID email | `you@example.com` |
| `FASTLANE_PASSWORD` | Apple ID password | Your Apple ID password |
| `FASTLANE_APPLE_APPLICATION_SPECIFIC_PASSWORD` | App-specific password | Generated in appleid.apple.com |

#### Android Secrets

| Secret Name | Description | Example/Source |
|------------|-------------|----------------|
| `ANDROID_KEYSTORE_BASE64` | Base64-encoded keystore | `base64 -i upload-keystore.jks` |
| `ANDROID_KEY_PROPERTIES` | Key properties file content | Copy entire file content |
| `PLAY_STORE_CONFIG_JSON` | Service account JSON | Copy entire JSON file content |

### Adding Secrets to GitHub

1. Go to your repository → **Settings → Secrets and variables → Actions**
2. Click **New repository secret**
3. Add each secret listed above

### Trigger Deployment

#### Manual Trigger

1. Go to **Actions** tab in GitHub
2. Select **Deploy Beta Builds** workflow
3. Click **Run workflow**
4. Choose platform: `ios`, `android`, or `both`

#### Automatic on Tag

Push a version tag:

```bash
git tag v1.0.0-beta
git push origin v1.0.0-beta
```

---

## Fastlane Lanes Reference

### iOS Lanes

```bash
cd ios

# Deploy to TestFlight
bundle exec fastlane beta

# Build only (no upload)
bundle exec fastlane build

# Setup code signing (CI)
bundle exec fastlane setup_signing
```

### Android Lanes

```bash
cd android

# Deploy to Internal Testing
bundle exec fastlane beta

# Promote internal to beta (closed testing)
bundle exec fastlane promote_to_beta

# Build APK only (no upload)
bundle exec fastlane build
```

---

## Troubleshooting

### iOS Issues

**Problem**: Code signing errors
- **Solution**: Run `fastlane match appstore` to sync certificates
- Verify team is selected in Xcode project settings

**Problem**: "No valid certificates found"
- **Solution**: Check Match repository has certificates; re-run `fastlane match appstore`

**Problem**: "Could not find valid login credentials"
- **Solution**: Set `FASTLANE_USER` and `FASTLANE_PASSWORD` environment variables
- Use App Store Connect API key instead (recommended)

### Android Issues

**Problem**: "Could not find upload-keystore.jks"
- **Solution**: Ensure `key.properties` points to correct keystore path
- Check keystore file exists at specified location

**Problem**: "Google Play API error"
- **Solution**: Verify service account has **Release Manager** permissions
- Check JSON key file is valid and not expired

**Problem**: "Version code X already exists"
- **Solution**: Manually increment version code in `pubspec.yaml`
- Fastlane should auto-increment on next run

---

## Version Management

### iOS
- Build number auto-incremented by Fastlane using `agvtool`
- Version number managed in Xcode project (synced from `pubspec.yaml`)
- Tags created: `ios-v1.0.0-123`

### Android
- Version code auto-incremented in `pubspec.yaml`
- Version name from `pubspec.yaml` (e.g., `1.0.0`)
- Tags created: `android-v1.0.0-456`

---

## Security Best Practices

1. **Never commit**:
   - `key.properties`
   - `upload-keystore.jks`
   - `play-store-credentials.json`
   - `.p8` API key files
   - Any file with passwords or secrets

2. **Use environment variables** in CI/CD

3. **Restrict GitHub secrets** access to necessary people

4. **Rotate credentials** periodically (every 6-12 months)

5. **Enable 2FA** on Apple ID and Google accounts

---

## Distribution Workflow

### Alpha Testing (Internal)
1. Deploy to internal testers via TestFlight/Play Console Internal
2. Monitor crash reports and feedback
3. Fix P0/P1 issues
4. Re-deploy as needed

### Beta Testing (External)
1. Once stable, promote to external beta:
   - iOS: Enable external testing in TestFlight
   - Android: Run `fastlane promote_to_beta`
2. Share with limited external testers
3. Collect feedback via in-app forms and GitHub issues
4. Iterate based on feedback

### Production Release
1. Create production release candidate
2. Final QA pass
3. Submit for App Store/Play Store review
4. Monitor post-launch metrics

---

## Additional Resources

- [Fastlane iOS Documentation](https://docs.fastlane.tools/getting-started/ios/setup/)
- [Fastlane Android Documentation](https://docs.fastlane.tools/getting-started/android/setup/)
- [App Store Connect API](https://developer.apple.com/documentation/appstoreconnectapi)
- [Google Play Console API](https://developers.google.com/android-publisher)
- [Flutter Release Process](https://docs.flutter.dev/deployment/flavors)

---

## Support

For issues or questions:
- File a bug using `.github/ISSUE_TEMPLATE/bug_report.md`
- Label with `ci-cd` or `deployment`
- Include relevant logs and error messages
