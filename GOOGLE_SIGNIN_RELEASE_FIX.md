# 🔧 Google Sign-In Release Build Fix

**Issue:** Google Sign-In works in debug but fails in release APK  
**Cause:** Release keystore SHA-1 fingerprint not registered in Firebase Console  
**Status:** ⚠️ REQUIRES FIREBASE CONSOLE UPDATE

---

## 🔍 Problem Analysis

Your release build is signed with a different certificate than the debug build, but Firebase only has the debug SHA-1 registered.

### Current Fingerprints:

**Release Keystore SHA-1 (MISSING in Firebase):**
```
83:B9:34:34:C3:B3:11:DC:9B:D6:52:CE:1F:9D:7E:07:D6:8F:D7:F9
```

**Release Keystore SHA-256:**
```
EA:1B:D2:64:13:4F:EA:BC:3B:34:6F:32:F4:13:A7:B5:85:B9:D8:1E:87:FA:9A:B1:7B:B2:1B:7C:45:6C:93:05
```

**Debug Certificate (already in Firebase):**
```
d5d1bcabe3fbaafecf5bc70c347c8babf61fc66d
```

---

## ✅ Solution: Add Release SHA-1 to Firebase

### Step 1: Go to Firebase Console
1. Open [Firebase Console](https://console.firebase.google.com/)
2. Select project: **business-setup-application**
3. Click the gear icon ⚙️ → **Project settings**

### Step 2: Add SHA-1 Certificate
1. Scroll down to **Your apps** section
2. Find your Android app: `com.wazeet.app`
3. Click **Add fingerprint** button
4. Paste this SHA-1:
   ```
   83:B9:34:34:C3:B3:11:DC:9B:D6:52:CE:1F:9D:7E:07:D6:8F:D7:F9
   ```
5. Click **Save**

### Step 3: Download Updated google-services.json
1. After adding the fingerprint, click the download icon
2. Download the updated `google-services.json`
3. Replace it at: `android/app/google-services.json`

### Step 4: Rebuild the App
```bash
flutter clean
flutter pub get
flutter build apk --release
```

### Step 5: Test on Device
```bash
# Install the new APK
adb install android/build/app/outputs/apk/release/app-release.apk

# Or transfer via USB and install manually
```

---

## 🖼️ Visual Guide

### Firebase Console Navigation:

```
Firebase Console
  └─ Select Project: business-setup-application
      └─ Project Settings (⚙️)
          └─ Your apps
              └─ Android app (com.wazeet.app)
                  └─ SHA certificate fingerprints
                      └─ [Add fingerprint] button
```

### What You'll See:

**Before (only debug SHA-1):**
```
SHA certificate fingerprints:
✓ d5d1bcabe3fbaafecf5bc70c347c8babf61fc66d (Debug)
```

**After (both debug and release):**
```
SHA certificate fingerprints:
✓ d5d1bcabe3fbaafecf5bc70c347c8babf61fc66d (Debug)
✓ 83:B9:34:34:C3:B3:11:DC:9B:D6:52:CE:1F:9D:7E:07:D6:8F:D7:F9 (Release)
```

---

## 🔐 Alternative: Get SHA-1 Manually

If you need to verify or get the SHA-1 again:

```bash
# For release keystore
keytool -list -v -keystore android/key.jks -alias wazeet -storepass wazeet_release_2024

# For debug keystore (already added)
keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android
```

---

## 🚨 Important Notes

1. **Both Certificates Needed:**
   - Debug SHA-1: For development builds (`flutter run`)
   - Release SHA-1: For release builds (`flutter build apk`)
   - Keep both in Firebase for seamless development → production

2. **Propagation Time:**
   - Changes take effect immediately
   - No need to wait for propagation

3. **OAuth Client:**
   - Firebase will automatically update the OAuth client configuration
   - The new `google-services.json` will have both certificates

4. **Don't Delete Debug:**
   - Keep the debug certificate for development
   - Add release certificate alongside it

---

## ✅ Verification Checklist

After completing the steps:

- [ ] Release SHA-1 added to Firebase Console
- [ ] Updated `google-services.json` downloaded
- [ ] File replaced in `android/app/google-services.json`
- [ ] App rebuilt with `flutter clean && flutter build apk`
- [ ] New APK installed on test device
- [ ] Google Sign-In tested successfully

---

## 🔧 Quick Copy-Paste Commands

```bash
# 1. Get SHA-1 (already done, but for reference)
keytool -list -v -keystore android/key.jks -alias wazeet -storepass wazeet_release_2024 | grep SHA1

# 2. Clean and rebuild
flutter clean
flutter pub get
flutter build apk --release

# 3. Install on device
adb install android/build/app/outputs/apk/release/app-release.apk

# 4. Check logs if still issues
adb logcat | grep -E "GoogleSignIn|FirebaseAuth"
```

---

## 🐛 Troubleshooting

### If Google Sign-In Still Fails:

**Check 1: Package Name Match**
```
AndroidManifest.xml: com.wazeet.app ✓
Firebase Console: com.wazeet.app ✓
google-services.json: com.wazeet.app ✓
```

**Check 2: Google Play Services Updated**
- Ensure device has latest Google Play Services
- Settings → Apps → Google Play Services → Update

**Check 3: Internet Connection**
- Release builds use different network settings
- Ensure device has active internet

**Check 4: Firebase Configuration**
```bash
# Verify google-services.json is properly embedded
unzip -p android/build/app/outputs/apk/release/app-release.apk assets/flutter_assets/google-services.json
```

**Check 5: OAuth Consent Screen**
- Go to Google Cloud Console
- APIs & Services → OAuth consent screen
- Ensure app is published (at least Testing mode)
- Add test users if in Testing mode

---

## 📱 Alternative: Use Email Sign-In

If you need immediate testing without fixing Google Sign-In:

The app has email authentication as fallback:
1. Tap "Existing user" button
2. Use email/password sign-in
3. This works in both debug and release builds

---

## 🎯 For Play Store Release

When submitting to Play Store, you'll need **TWO MORE** SHA-1 certificates:

1. **Upload Key SHA-1** (if using Play App Signing)
2. **App Signing Key SHA-1** (generated by Google Play)

Get these from:
- Play Console → App → Setup → App integrity
- Add both to Firebase Console

---

## 📞 Support

If issues persist after adding SHA-1:

1. Check Firebase Console has saved the fingerprint
2. Download fresh `google-services.json`
3. Clean build: `flutter clean`
4. Check device logs: `adb logcat | grep Google`
5. Verify OAuth consent screen configuration

---

## ✨ Success Indicators

You'll know it's fixed when:
- ✅ "Continue with Google" button works
- ✅ Google account picker appears
- ✅ User signs in successfully
- ✅ No error messages in red box
- ✅ App proceeds to home screen

---

**Next Step:** Go to Firebase Console and add the SHA-1 fingerprint now! ⬆️
