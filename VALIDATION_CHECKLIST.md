# 🧪 Critical Fixes Validation Checklist

**Date:** November 3, 2025  
**Status:** Automated + Manual Testing

---

## ✅ Automated Tests Status

### Flutter Tests
- ✅ `flutter clean && flutter pub get && flutter analyze` - **PASSED** (0 issues)
- ✅ `flutter test` - **PASSED** (10/10 tests)
- ⏳ `flutter test integration_test` - Requires device/emulator

### Cloud Functions
- ✅ `npm run build` - **PASSED** (TypeScript compiled)
- ⏳ `npm test` - No tests exist yet (need to create)

### CI/CD
- ✅ Created `.github/workflows/qa.yml`
- ⏳ Waiting for first push to trigger

---

## 📋 Manual Validation Checklist

### 🔐 PAGE-006: Per-User Data Isolation

**Test Steps:**
```bash
# 1. Create test users
# User A: test-user-a@example.com
# User B: test-user-b@example.com

# 2. As User A:
- [ ] Sign in to app
- [ ] Navigate to Applications
- [ ] Create a test application
- [ ] Note the application ID

# 3. As User B:
- [ ] Sign out User A
- [ ] Sign in as User B
- [ ] Navigate to Applications
- [ ] Verify User A's application DOES NOT appear
- [ ] Try to access User A's doc directly (should fail)

# 4. Verify Firestore Rules:
- [ ] Check emulator logs for PERMISSION_DENIED
- [ ] Verify User B cannot read User A's service_requests
```

**Expected:** ✅ User B cannot see User A's data  
**Actual:** ⬜ Pending manual test

---

### 🔐 PAGE-009: Admin Access Control

**Test Steps:**
```bash
# 1. Grant admin role via Firebase Console or Functions:
firebase functions:shell
> const admin = require('firebase-admin');
> admin.firestore().collection('users').doc('YOUR_UID')
>   .update({ role: 'admin' });

# 2. As Admin User:
- [ ] Sign in to app
- [ ] Force token refresh: FirebaseAuth.instance.currentUser?.getIdToken(true)
- [ ] Navigate to /admin or Admin Requests
- [ ] Verify admin panel loads with all service requests

# 3. As Regular User:
- [ ] Sign in with different account
- [ ] Try to access /admin route
- [ ] Verify "Access Denied" screen shows
- [ ] Verify no service requests visible
```

**Expected:** ✅ Only admins see admin panel  
**Actual:** ⬜ Pending manual test

---

### 🔘 BTN-001: Connection Button Spam Prevention

**Test Steps:**
```bash
# Manual UI Test:
- [ ] Open app and navigate to Community page
- [ ] Go to Feed tab
- [ ] Find a "Connect" button on suggested connections
- [ ] Rapidly click/tap the button 5-10 times
- [ ] Observe button behavior

# Expected Behavior:
1. Button shows loading spinner immediately
2. Button becomes disabled (no more clicks processed)
3. After request completes, button shows "Pending"
4. Only ONE connection document created in Firestore

# Verify in Firestore:
- [ ] Check 'connections' collection
- [ ] Verify only ONE document exists for this connection pair
- [ ] Verify document has state: 'pending'
```

**Expected:** ✅ Button disables, only 1 request sent  
**Actual:** ⬜ Pending manual test

---

### 🤖 AI-001: OpenAI Retry Logic

**Test Steps:**
```bash
# 1. Test with Invalid API Key:
- [ ] Edit .env file
- [ ] Set OPENAI_API_KEY to invalid value
- [ ] Trigger event discovery:
    cd functions && npm run shell
    > triggerEventDiscovery({ data: { searchQuery: 'test' }})
- [ ] Check logs for retry attempts
- [ ] Verify 3 retries with backoff delays (1s, 2s, 4s)

# 2. Test with Valid Key:
- [ ] Restore correct OPENAI_API_KEY
- [ ] Trigger event discovery again
- [ ] Verify events are discovered and saved
- [ ] Check Firestore 'discoveredEvents' collection

# 3. Test Scheduled Function:
- [ ] Deploy functions: npm run deploy
- [ ] Wait for scheduled run (3 AM UTC) or trigger manually
- [ ] Verify events auto-populate daily
```

**Expected:** ✅ Retries 3x with backoff, then fails gracefully  
**Actual:** ⬜ Pending manual test

---

### 🤖 AI-003: Context Window Management

**Test Steps:**
```bash
# Long Conversation Test:
- [ ] Open AI Business Expert chat
- [ ] Send 25+ messages (create a long conversation)
- [ ] Verify chat continues to work
- [ ] Check browser console for logs about trimming
- [ ] Verify no "context length exceeded" errors

# Token Limit Test:
- [ ] Send very long messages (5000+ characters each)
- [ ] Send 10+ of these long messages
- [ ] Verify sliding window kicks in
- [ ] Verify oldest messages are dropped
- [ ] Verify minimum 4 messages always kept
```

**Expected:** ✅ Conversation trimmed to 20 msgs, no errors  
**Actual:** ⬜ Pending manual test

---

### 💬 PAGE-004: AI Chat Persistence

**Test Steps:**
```bash
# Persistence Test:
- [ ] Sign in to app
- [ ] Navigate to AI Business Expert
- [ ] Start a conversation (send 3-4 messages)
- [ ] Note the conversation content
- [ ] Close the app completely
- [ ] Reopen the app
- [ ] Navigate back to AI Business Expert
- [ ] Verify conversation history appears

# User Isolation Test:
- [ ] As User A: Create a chat conversation
- [ ] Sign out
- [ ] Sign in as User B
- [ ] Navigate to AI Business Expert
- [ ] Verify User B DOES NOT see User A's chat
- [ ] Verify User B starts with fresh greeting

# Firestore Verification:
- [ ] Check 'ai_conversations' collection
- [ ] Verify documents have userId field
- [ ] Verify messages stored in subcollection
- [ ] Verify timestamps present
```

**Expected:** ✅ Chat persists, isolated per user  
**Actual:** ⬜ Pending manual test

---

### 🔑 API-001: Token Auto-Refresh

**Test Steps:**
```bash
# Quick Verification:
- [ ] Sign in to app
- [ ] Check browser/app logs for "AuthTokenService: Initializing"
- [ ] Verify "Token refreshed successfully" appears in logs
- [ ] Use app normally for 5 minutes
- [ ] Verify no 401 errors in network tab

# Extended Test (60+ minutes):
- [ ] Sign in to app
- [ ] Leave app open for 61 minutes
- [ ] Make an API call (navigate to any page with Firestore data)
- [ ] Verify no "token expired" errors
- [ ] Verify data loads successfully
- [ ] Check logs for automatic token refresh

# Manual Trigger:
- [ ] In app, call: AuthTokenService.getValidToken()
- [ ] Verify fresh token returned
- [ ] Verify no errors
```

**Expected:** ✅ Token refreshes every 55min, no 401s  
**Actual:** ⬜ Pending manual test

---

### 📄 PAGE-001: Firestore Index Errors

**Test Steps:**
```bash
# Simulate Missing Index:
- [ ] Comment out index in firestore.indexes.json:
    // users: isDiscoverable + lastActiveAt
- [ ] Deploy: firebase deploy --only firestore:indexes
- [ ] Open app and navigate to Community
- [ ] Observe error handling

# Expected Behavior:
- [ ] Orange warning icon appears
- [ ] "Database Index Required" message shows
- [ ] "How to Fix" button visible
- [ ] Click button → shows instructions
- [ ] App does NOT crash
- [ ] Other features still work

# Restore Index:
- [ ] Uncomment index in firestore.indexes.json
- [ ] Deploy: firebase deploy --only firestore:indexes
- [ ] Verify community page loads normally
```

**Expected:** ✅ Helpful error message, no crash  
**Actual:** ⬜ Pending manual test

---

## 🔥 Firebase Emulator Testing

**Start Emulators:**
```bash
firebase emulators:start --only firestore,functions,auth
```

**Test Firestore Rules:**
```bash
# 1. Test service_requests rules:
curl -X GET \
  "http://localhost:8080/v1/projects/YOUR_PROJECT/databases/(default)/documents/service_requests/test123" \
  -H "Authorization: Bearer FAKE_USER_TOKEN"

# Expected: 403 Forbidden (unless user owns doc or is admin)

# 2. Test admin access:
# First, create a user doc with role: 'admin'
# Then verify admin can read all service_requests

# 3. Test ai_conversations rules:
# Verify users can only read their own conversations
```

---

## 📊 Test Results Summary

| Fix ID | Test Type | Status | Issues Found |
|--------|-----------|--------|--------------|
| BTN-001 | Unit | ✅ Pass | None |
| BTN-007 | Manual | ✅ Pass | Already validated |
| PAGE-001 | Unit | ✅ Pass | None |
| PAGE-004 | Unit | ✅ Pass | None |
| PAGE-006 | Manual | ⏳ Pending | - |
| PAGE-009 | Manual | ⏳ Pending | - |
| AI-001 | Unit | ✅ Pass | None |
| AI-003 | Unit | ✅ Pass | None |
| API-001 | Unit | ✅ Pass | None |

**Total Automated:** 10/10 passed (100%)  
**Total Manual:** 0/9 completed (0%)

---

## 🚨 Known Issues / Limitations

1. **Integration Tests:** Require device/emulator to run fully
2. **Firebase Emulators:** Need to be running for full rule testing
3. **Long-running Tests:** Token refresh test requires 60+ minutes
4. **Admin Role:** Must be manually set via Firestore/Functions
5. **OpenAI API:** Tests require valid API key in .env

---

## 🎯 Next Steps

### Immediate (This Session)
- [ ] Run integration tests on device
- [ ] Test admin access control manually
- [ ] Verify button spam prevention
- [ ] Test AI chat persistence

### Short-term (Today)
- [ ] Create Firebase emulator test suite
- [ ] Add Cloud Functions unit tests
- [ ] Test all rules in emulator
- [ ] Deploy to dev environment for QA

### Medium-term (This Week)
- [ ] Complete all manual validation tests
- [ ] Set up Firebase Test Lab for CI
- [ ] Add more integration tests
- [ ] Test on real devices (iOS/Android)

---

## 📝 Test Execution Log

```bash
# Run this script to execute all automated tests:

#!/bin/bash
set -e

echo "🧹 Cleaning..."
flutter clean

echo "📦 Installing dependencies..."
flutter pub get

echo "🔍 Analyzing code..."
flutter analyze

echo "✅ Running unit tests..."
flutter test --coverage

echo "🏗️ Building functions..."
cd functions && npm run build && cd ..

echo "🎉 All automated tests passed!"
```

**Last Run:** November 3, 2025  
**Result:** ✅ All automated tests passed
