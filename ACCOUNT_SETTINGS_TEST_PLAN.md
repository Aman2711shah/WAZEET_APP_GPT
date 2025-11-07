# Account Settings - Testing Quick Reference

## ✅ Implementation Complete

All 5 Account Settings features have been fully implemented:

1. **Access Denied** - Admin-only page guard ✅
2. **Appearance** - Theme selector with persistence ✅
3. **Change Password** - Provider-aware (email + federated) ✅
4. **Two-Factor Authentication** - SMS MFA (fully working) ✅
5. **Download Your Data** - Cloud Function + UI ✅

## Quick Test Flow

### 1. Theme Settings (2 min)
```
1. Navigate: Settings → Appearance
2. Select "Light Mode" → Verify app switches to light theme
3. Reload app → Verify light theme persists
4. Select "Dark Mode" → Verify app switches back
```

### 2. Change Password - Email User (3 min)
```
1. Sign in with email/password account
2. Navigate: Account Settings → Change Password
3. Enter current password: [your password]
4. Enter new password: TestPass123!
5. Confirm new password: TestPass123!
6. Click "Change Password"
7. Verify forced sign-out
8. Sign back in with new password
```

### 3. Change Password - Federated User (3 min)
```
1. Sign in with Google/Apple account
2. Navigate: Account Settings → Change Password
3. See "Create a password" heading
4. Enter email address
5. Enter new password: TestPass123!
6. Confirm new password: TestPass123!
7. Click "Create Password"
8. Verify success message
9. Sign out and sign in with email/password
```

### 4. Two-Factor Authentication (5 min)
```
1. Navigate: Account Settings → Two-Factor Authentication
2. See "No SMS authentication factors enrolled"
3. Click "Add SMS Authentication"
4. Enter phone: +1234567890 (your real phone)
5. Wait for SMS code
6. Enter 6-digit code
7. Verify factor appears in list
8. Note enrollment date
9. Click trash icon → Confirm unenrollment
10. Verify factor removed
```

### 5. Download Your Data (2 min)
```
1. Navigate: Account Settings → Download Your Data
2. Click "Generate Data Export"
3. See progress spinner with message
4. Wait ~10-30 seconds
5. See success message + "Download Data" button
6. Click "Download Data"
7. Verify ZIP file downloads
8. Extract and inspect JSON files:
   - user-profile.json
   - preferences.json
   - activity.json
   - bookings.json
   - favorites.json
   - reviews.json
   - applications.json
   - metadata.json
```

### 6. Access Denied (1 min)
```
SETUP: Ensure test user is NOT admin
1. Try to navigate to Service Requests page (or any admin page)
2. See "Access Denied" screen with red block icon
3. Click "Go Back" → Returns to previous page

SETUP: Set test user role to 'admin' in Firestore
4. Navigate to Service Requests
5. Verify page loads successfully
```

## Test Accounts Needed

### 1. Email/Password User
- Create account with email/password
- Use for testing password change

### 2. Google Sign-In User
- Sign in with Google
- Use for testing federated password creation

### 3. Admin User
- Set `role: 'admin'` in Firestore `users/{uid}` doc
- Use for testing Access Denied page

### 4. Regular User
- No special role
- Use for testing Access Denied blocking

## Expected Results

### ✅ Success Indicators
- [ ] Theme changes immediately and persists after reload
- [ ] Password users can change password successfully
- [ ] Federated users can create password and sign in with it
- [ ] SMS MFA enrolls successfully and shows in list
- [ ] Data export generates ZIP with all expected files
- [ ] Non-admin users blocked from admin pages
- [ ] Admin users can access admin pages

### ⚠️ Known Behaviors
- Theme defaults to Dark if no preference saved
- Password change forces sign-out (security feature)
- MFA enrollment requires real phone number (SMS sent)
- Export signed URL expires after 1 hour
- Delete Account permanently removes all data (irreversible)

## Troubleshooting Quick Fixes

### Theme not saving
```bash
# Clear app data and try again
flutter clean
flutter pub get
flutter run
```

### MFA verification failing
```
1. Check phone format: +[country][number] (e.g., +12125551234)
2. Verify MFA enabled in Firebase Console
3. Check SMS quota not exceeded
4. Try different phone number
```

### Export fails
```
1. Check Firebase Console → Functions → Logs
2. Verify function deployed: firebase deploy --only functions:exportUserData
3. Ensure Storage bucket exists
4. Check timeout setting (increase to 540s if needed)
```

### Access Denied always showing
```
1. Open Firestore Console
2. Navigate to users/{uid}
3. Add field: role = 'admin'
4. In app, call roleService.refreshToken()
5. Try again
```

## Development Testing

### Run with hot reload
```bash
flutter run -d chrome
# Or use VS Code "Flutter: Run App" task
```

### Watch Cloud Function logs
```bash
firebase functions:log --only exportUserData
firebase functions:log --only deleteUserData
```

### Check Firestore rules
```bash
firebase deploy --only firestore:rules
```

## Pre-Production Checklist

- [ ] All 6 test flows pass
- [ ] Theme persists across app restarts
- [ ] Both password and federated users can add passwords
- [ ] SMS MFA works for real phone numbers
- [ ] Data exports contain expected files
- [ ] Access control blocks non-admin users
- [ ] Cloud Functions respond within timeout
- [ ] Firestore rules enforce security
- [ ] No console errors during testing
- [ ] Export cleanup runs successfully

## Time Estimate
- **Full test suite**: ~20 minutes
- **Quick smoke test**: ~5 minutes (one flow per feature)
- **Comprehensive QA**: ~1 hour (edge cases, error states)

---

**Ready to Test**: ✅ All features deployed and ready
**Documentation**: See `docs/ACCOUNT_SETTINGS_COMPLETE.md`
**Support**: Check Cloud Function logs for any runtime errors
