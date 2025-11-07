# Authentication Setup Guide

This guide walks you through setting up Firebase Authentication with Email/Password, Google Sign-In, and Apple Sign-In for the WAZEET app.

## Prerequisites

- Firebase project created at [Firebase Console](https://console.firebase.google.com)
- Xcode (for iOS setup)
- Android Studio (for Android setup)
- Flutter SDK installed

## 1. Firebase Console Configuration

### Enable Authentication Methods

1. Go to [Firebase Console](https://console.firebase.google.com)
2. Select your project
3. Navigate to **Authentication** → **Sign-in method**
4. Enable the following providers:

#### Email/Password
- Click **Email/Password**
- Toggle **Enable**
- Click **Save**

#### Google
- Click **Google**
- Toggle **Enable**
- Add support email (required)
- Click **Save**

#### Apple (iOS only)
- Click **Apple**
- Toggle **Enable**
- Click **Save**
- Note: Additional Apple Developer setup required (see iOS section below)

---

## 2. Android Setup (Google Sign-In)

### Step 1: Generate SHA-1 and SHA-256 Fingerprints

Run these commands in your project root:

```bash
# For debug keystore (development)
keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android

# For release keystore (production)
keytool -list -v -keystore android/key.jks -alias upload -storepass YOUR_STORE_PASSWORD
```

Copy the **SHA-1** and **SHA-256** fingerprints from the output.

### Step 2: Add Fingerprints to Firebase

1. In Firebase Console, go to **Project Settings**
2. Select your Android app (or add one if not exists)
3. Click **Add fingerprint**
4. Paste your SHA-1 fingerprint
5. Click **Add fingerprint** again
6. Paste your SHA-256 fingerprint
7. Click **Save**

### Step 3: Download Updated google-services.json

1. In Firebase Console, go to **Project Settings**
2. Select your Android app
3. Click **Download google-services.json**
4. Replace the file at: `android/app/google-services.json`

### Step 4: Verify build.gradle Configuration

Your `android/app/build.gradle.kts` should already have:

```kotlin
plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services") // This line
}
```

---

## 3. iOS Setup

### Step 1: Google Sign-In Configuration

#### Add REVERSED_CLIENT_ID to Info.plist

1. Download `GoogleService-Info.plist` from Firebase Console:
   - Go to **Project Settings**
   - Select your iOS app
   - Download `GoogleService-Info.plist`

2. Open `GoogleService-Info.plist` and find the `REVERSED_CLIENT_ID` value

3. Open `ios/Runner/Info.plist` in a text editor

4. Add this configuration (replace `YOUR_REVERSED_CLIENT_ID` with the actual value):

```xml
<key>CFBundleURLTypes</key>
<array>
    <dict>
        <key>CFBundleTypeRole</key>
        <string>Editor</string>
        <key>CFBundleURLSchemes</key>
        <array>
            <string>YOUR_REVERSED_CLIENT_ID</string>
        </array>
    </dict>
</array>
```

Example:
```xml
<key>CFBundleURLTypes</key>
<array>
    <dict>
        <key>CFBundleTypeRole</key>
        <string>Editor</string>
        <key>CFBundleURLSchemes</key>
        <array>
            <string>com.googleusercontent.apps.123456789-abcdef</string>
        </array>
    </dict>
</array>
```

### Step 2: Apple Sign-In Configuration

#### Add Sign In with Apple Capability

1. Open Xcode: `open ios/Runner.xcworkspace`

2. Select the **Runner** target in the left sidebar

3. Go to the **Signing & Capabilities** tab

4. Click **+ Capability**

5. Search for and add **Sign In with Apple**

6. Ensure your **Team** is selected under **Signing**

#### Configure in Apple Developer Portal

1. Go to [Apple Developer Portal](https://developer.apple.com/account)

2. Navigate to **Certificates, Identifiers & Profiles**

3. Select **Identifiers**

4. Find and select your app's Bundle ID

5. Scroll down and enable **Sign In with Apple**

6. Click **Save**

#### Configure in Firebase Console (Optional)

If you want to use Apple Sign-In with Firebase on the web or need advanced features:

1. In Firebase Console, go to **Authentication** → **Sign-in method**
2. Click on **Apple**
3. Configure with your Service ID, Team ID, and Key ID from Apple Developer Portal

---

## 4. Install Dependencies

Run this command to install the required packages:

```bash
flutter pub get
```

Dependencies that were added:
- `google_sign_in: ^6.2.2`
- `sign_in_with_apple: ^6.1.3`
- `url_launcher: ^6.3.0`

---

## 5. Test the Implementation

### Fresh Install Test

1. Uninstall the app from your device/simulator
2. Run the app: `flutter run`
3. You should see the **AuthWelcomePage** with sign-in options

### Test Email Sign-Up Flow

1. Click **"Create account"**
2. Enter email and password
3. Click **"Create account"**
4. You should be redirected to **VerifyEmailPage**
5. Check your email inbox for verification link
6. Click the verification link
7. Return to app and click **"I've verified - Continue"**
8. You should be redirected to the main app (Home)

### Test Email Sign-In Flow

1. Click **"Sign in with email"**
2. Enter credentials
3. Click **"Sign in"**
4. You should be redirected to the main app

### Test Google Sign-In

1. Click **"Continue with Google"**
2. Select a Google account
3. Grant permissions
4. You should be redirected to the main app

### Test Apple Sign-In (iOS only)

1. Click **"Continue with Apple"**
2. Authenticate with Face ID/Touch ID
3. Grant permissions
4. You should be redirected to the main app

---

## 6. Troubleshooting

### Google Sign-In Issues on Android

**Problem:** "Developer Error" or "Sign in failed"

**Solutions:**
- Verify SHA-1 and SHA-256 fingerprints are added to Firebase
- Ensure `google-services.json` is up to date
- Clean and rebuild: `flutter clean && flutter build apk`
- Check that package name matches Firebase configuration

### Apple Sign-In Issues on iOS

**Problem:** "Sign In with Apple" button not working

**Solutions:**
- Verify capability is added in Xcode
- Ensure Bundle ID is configured in Apple Developer Portal
- Check that "Sign In with Apple" is enabled for Bundle ID
- Verify provisioning profile includes Sign In with Apple capability

### Email Verification Not Working

**Problem:** Verification email not received

**Solutions:**
- Check spam/junk folder
- Verify email domain is not blocked
- Check Firebase Console → Authentication → Templates to customize email
- Ensure Firebase project has billing enabled (for production)

### General Auth Issues

**Problem:** Various authentication errors

**Solutions:**
- Check Firebase Console → Authentication → Users for any issues
- Review Firebase Console → Authentication → Settings
- Ensure app has internet connectivity
- Check console logs for specific error messages
- Verify Firebase project configuration matches app configuration

---

## 7. Production Deployment

### Before Going to Production

1. **Update SHA fingerprints for release build**
   - Generate SHA-1 and SHA-256 for release keystore
   - Add to Firebase Console

2. **Test release builds**
   ```bash
   flutter build apk --release
   flutter build ios --release
   ```

3. **Enable email verification enforcement**
   - Currently handled automatically in the app
   - Users cannot access main app until verified

4. **Review Firebase Security Rules**
   - Ensure Firestore rules require authentication
   - Review Cloud Storage rules

5. **Configure email templates**
   - Go to Firebase Console → Authentication → Templates
   - Customize verification email
   - Customize password reset email

6. **Set up monitoring**
   - Enable Firebase Crashlytics
   - Set up alerts for auth failures

---

## 8. Analytics Events

The auth flow emits the following events (implement in your analytics service):

- `auth_login` - User successfully signed in
- `auth_signup` - User successfully signed up
- `auth_provider` - Provider used (email, google, apple)

Example implementation:

```dart
// After successful sign in
FirebaseAnalytics.instance.logLogin(loginMethod: 'google');

// After successful sign up
FirebaseAnalytics.instance.logSignUp(signUpMethod: 'email');
```

---

## 9. Guest Mode (Optional)

Guest mode is currently disabled via the constant `kAllowGuest = false` in `auth_welcome_page.dart`.

To enable:
1. Change `kAllowGuest` to `true`
2. Implement anonymous auth in AuthService:
   ```dart
   Future<UserCredential> signInAnonymously() async {
     return await _auth.signInAnonymously();
   }
   ```
3. Update AppRouter to handle anonymous users

---

## Support

For issues or questions:
- Check [Firebase Documentation](https://firebase.google.com/docs/auth)
- Review [Flutter Firebase Documentation](https://firebase.flutter.dev/docs/auth/usage)
- Check project issues on GitHub

---

## Summary Checklist

- [ ] Firebase Authentication enabled (Email, Google, Apple)
- [ ] Android SHA-1 and SHA-256 added to Firebase
- [ ] Android `google-services.json` updated
- [ ] iOS `REVERSED_CLIENT_ID` added to Info.plist
- [ ] iOS Sign In with Apple capability added in Xcode
- [ ] Apple Developer Bundle ID configured
- [ ] Dependencies installed (`flutter pub get`)
- [ ] Fresh install tested
- [ ] Email sign-up and verification tested
- [ ] Google Sign-In tested
- [ ] Apple Sign-In tested (iOS)
- [ ] Release builds configured

Once all items are checked, your authentication system is ready for production! 🎉
