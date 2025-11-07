# Android Google Sign-In Configuration Guide

## 🎯 Quick Fix Checklist

- [ ] Package name matches Firebase (com.wazeet.app)
- [ ] SHA-1 and SHA-256 added to Firebase Console
- [ ] google-services.json is up to date
- [ ] Google Services plugin applied in build.gradle
- [ ] Auth service has proper error handling
- [ ] Tested on physical device (not emulator)

---

## 📋 Current Configuration Status

### ✅ Package Name
- **App**: `com.wazeet.app` (in `android/app/build.gradle.kts`)
- **Firebase**: `com.wazeet.app` (in `google-services.json`)
- **Status**: ✅ MATCHES

### ✅ Gradle Configuration
- **Root build.gradle**: ✅ Google Services plugin 4.4.2
- **App build.gradle**: ✅ Plugin applied
- **Status**: ✅ CORRECT

### ⚠️ SHA Fingerprints
- **Status**: ⚠️ NEEDS VERIFICATION
- **Action Required**: Add SHA-1 and SHA-256 to Firebase Console

---

## 🔧 Step-by-Step Setup

### Step 1: Get SHA Fingerprints

Run the automated script:

```bash
chmod +x scripts/get_sha_fingerprints.sh
./scripts/get_sha_fingerprints.sh
```

Or manually:

#### Debug Keystore (for development)
```bash
keytool -list -v -alias androiddebugkey \
  -keystore ~/.android/debug.keystore \
  -storepass android -keypass android
```

#### Release Keystore (for production)
```bash
keytool -list -v -alias <your_alias> \
  -keystore android/key.jks
```

**Important**: Copy both SHA-1 and SHA-256 for each keystore!

### Step 2: Add Fingerprints to Firebase

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select project: **business-setup-application**
3. Navigate to: **Project Settings** > **Your apps**
4. Click on your Android app: **com.wazeet.app**
5. Scroll to **SHA certificate fingerprints**
6. Click **Add fingerprint** button
7. Add these fingerprints (you'll need 4 entries total):
   - Debug SHA-1
   - Debug SHA-256
   - Release SHA-1
   - Release SHA-256
8. Click **Save**

### Step 3: Download Updated google-services.json

1. In Firebase Console, after adding SHA fingerprints
2. Click **Download google-services.json**
3. Replace the file at: `android/app/google-services.json`

### Step 4: Clean and Rebuild

```bash
flutter clean
flutter pub get
cd android && ./gradlew clean
cd ..
flutter run -v
```

---

## 🧪 Testing

### On Physical Device (Recommended)

```bash
# Run with verbose logging
flutter run -v

# Watch Android logs
adb logcat | grep -i -e google -e auth -e firebase
```

### Common Test Scenarios

1. **Happy Path**
   - Tap "Continue with Google"
   - Select account
   - Grant permissions
   - Should land on home screen

2. **User Cancels**
   - Tap "Continue with Google"
   - Tap back or close
   - Should show: "Sign-in cancelled."

3. **Network Error**
   - Turn off WiFi/Data
   - Tap "Continue with Google"
   - Should show: "Network error. Please check your connection..."

4. **Missing Token (SHA not configured)**
   - Should show detailed error about SHA fingerprints

---

## 🐛 Troubleshooting

### Error: "Google sign-in failed. Please try again."

**Causes:**
- SHA fingerprints not added to Firebase
- google-services.json not updated after adding SHA
- Google Play Services not installed/updated

**Solutions:**
1. Verify SHA fingerprints are in Firebase Console
2. Download fresh google-services.json
3. Clean and rebuild project
4. Update Google Play Services on device

### Error: "Invalid token from Google"

**Causes:**
- SHA-1/SHA-256 mismatch
- Wrong keystore used for signing
- google-services.json is outdated

**Solutions:**
1. Verify you're using the correct keystore (debug vs release)
2. Get SHA from that specific keystore
3. Add to Firebase Console
4. Download new google-services.json

### Error: "Account exists with different credential"

**Cause:**
- User previously signed in with email/password
- Now trying Google with same email

**Solution:**
- Sign in with original method first
- Or link accounts programmatically

### Sign-in works on debug but not release

**Cause:**
- Release keystore SHA fingerprints not added to Firebase

**Solution:**
1. Get SHA from release keystore
2. Add to Firebase Console
3. Download new google-services.json
4. Rebuild release

---

## 📱 Device Requirements

### Minimum Requirements
- Android 5.0 (API 21) or higher
- Google Play Services installed
- Google account on device

### Recommended
- Android 8.0 (API 26) or higher
- Latest Google Play Services
- Physical device (emulator may have issues)

---

## 🔐 Security Best Practices

### ✅ Do's
- Keep google-services.json in `.gitignore` for private repos
- Use different keystores for debug and release
- Add SHA for both debug and release keystores
- Rotate release keystore periodically
- Enable 2FA on Firebase project

### ❌ Don'ts
- Don't commit keystores to public repos
- Don't share keystore passwords
- Don't use debug keystore for production
- Don't skip SHA-256 (add both SHA-1 and SHA-256)

---

## 📊 Verification Checklist

After setup, verify these:

```bash
# 1. Check package name
grep "applicationId" android/app/build.gradle.kts

# 2. Check Firebase config
cat android/app/google-services.json | grep package_name

# 3. Verify Google Services plugin
grep "google-services" android/app/build.gradle.kts

# 4. Run with verbose logging
flutter run -v 2>&1 | tee debug.log
```

---

## 🆘 Support

If you're still having issues:

1. Check logs: `flutter run -v` and `adb logcat`
2. Verify all steps completed
3. Try on different device
4. Check Firebase Console for any alerts

### Helpful Commands

```bash
# View detailed Android logs
adb logcat -v time | grep -i -e GoogleSignIn -e FirebaseAuth

# Check Play Services version
adb shell dumpsys package com.google.android.gms | grep versionName

# Clear app data and retry
adb shell pm clear com.wazeet.app

# Force stop and restart
adb shell am force-stop com.wazeet.app
flutter run
```

---

## 📚 Additional Resources

- [Firebase Android Setup](https://firebase.google.com/docs/android/setup)
- [Google Sign-In for Android](https://developers.google.com/identity/sign-in/android/start)
- [Flutter Firebase Auth](https://firebase.flutter.dev/docs/auth/overview)
- [SHA Certificate Fingerprints](https://developers.google.com/android/guides/client-auth)

---

**Last Updated**: November 6, 2025  
**App Version**: 1.0.4+8  
**Package**: com.wazeet.app
