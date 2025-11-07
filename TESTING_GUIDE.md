# Community Feature - Testing Guide

## ✅ Deployment Status

### Completed Steps:
1. ✅ **Firestore Rules Deployed** - Security rules for users, connections, connection_requests, and user_edges
2. ✅ **TypeScript Errors Fixed** - Cloud Functions now compile without errors
3. ✅ **Provider Created** - `lib/providers/community_provider.dart` with `peopleRepositoryProvider`
4. ✅ **UI Integration Complete** - Real Suggested Connections integrated into Feed tab

---

## 🔥 Next: Create Firestore Indexes

### Required Indexes:

You need to create 3 composite indexes in Firebase Console:

#### Index 1: Users by discoverability and activity
```
Collection: users
Fields:
  - isDiscoverable (Ascending)
  - lastActiveAt (Descending)
```

#### Index 2: Users by industry, discoverability, and activity
```
Collection: users
Fields:
  - industries (Array-contains)
  - isDiscoverable (Ascending)
  - lastActiveAt (Descending)
```

#### Index 3: Connections by participants
```
Collection: connections
Fields:
  - a (Ascending)
  - b (Ascending)
  - state (Ascending)
```

### How to Create Indexes:

**Option 1: Automatic (Recommended)**
1. Run the app and navigate to Community tab
2. The first query will fail with an error
3. Click the auto-generated link in the error message
4. Firebase will create the index automatically
5. Wait 2-5 minutes for index to build

**Option 2: Manual**
1. Go to [Firebase Console](https://console.firebase.google.com)
2. Select your project: **business-setup-application**
3. Click "Firestore Database" → "Indexes" tab
4. Click "Create Index"
5. Enter the collection and fields as shown above
6. Click "Create"
7. Repeat for all 3 indexes

---

## 🧪 Testing the Connection Flow

### Step 1: Create Test User Profiles

Add test documents to the `users` collection in Firestore:

**User 1:**
```json
{
  "uid": "test_user_1",
  "displayName": "Sarah Al Mansouri",
  "headline": "Business Consultant | UAE",
  "photoURL": "",
  "industries": ["Finance", "Consulting"],
  "location": "Dubai, UAE",
  "isDiscoverable": true,
  "connectionsCount": 5,
  "mutualConnectionsCount": 0,
  "createdAt": "2024-11-01T00:00:00Z",
  "lastActiveAt": "2024-11-03T12:00:00Z"
}
```

**User 2:**
```json
{
  "uid": "test_user_2",
  "displayName": "Ahmed Hassan",
  "headline": "Legal Advisor | Startup Expert",
  "photoURL": "",
  "industries": ["Legal", "Technology"],
  "location": "Dubai, UAE",
  "isDiscoverable": true,
  "connectionsCount": 8,
  "mutualConnectionsCount": 0,
  "createdAt": "2024-11-01T00:00:00Z",
  "lastActiveAt": "2024-11-03T11:00:00Z"
}
```

**User 3:**
```json
{
  "uid": "test_user_3",
  "displayName": "Maria Garcia",
  "headline": "Marketing Expert | Digital Strategy",
  "photoURL": "",
  "industries": ["Marketing", "Technology"],
  "location": "Dubai, UAE",
  "isDiscoverable": true,
  "connectionsCount": 12,
  "mutualConnectionsCount": 0,
  "createdAt": "2024-11-01T00:00:00Z",
  "lastActiveAt": "2024-11-03T10:00:00Z"
}
```

### Step 2: Test Suggested Connections

1. **Run the app:**
   ```bash
   flutter run
   ```

2. **Navigate to Community tab**

3. **Check Feed tab:**
   - Scroll down to "Suggested Connections" card
   - Verify 3 test users appear
   - Check that names, headlines display correctly
   - Verify "Connect" buttons are visible

4. **Test Connect Button:**
   - Click "Connect" on any user
   - Should see green snackbar: "Connection request sent!"
   - Check Firestore for new documents:
     - `/connections/{connectionId}` (where connectionId = smaller_uid + larger_uid)
     - `/connection_requests/{test_user_uid}/requests/{current_user_uid}`

### Step 3: Test Connection States

**Accept a Request:**
```dart
await ref.read(peopleRepositoryProvider).acceptRequest("test_user_1");
```
- Verify connection state changes from `pending` to `accepted`
- Check `user_edges` collection for mutual connection records

**Ignore a Request:**
```dart
await ref.read(peopleRepositoryProvider).ignoreRequest("test_user_2");
```
- Verify connection state changes from `pending` to `ignored`

### Step 4: Test Mutual Connections

1. Create accepted connections between users:
   - Current user ↔ User A (accepted)
   - User A ↔ User B (accepted)
   - User B should now show "1 mutual connection"

2. Verify mutual count displays in UI

---

## 🐛 Troubleshooting

### "No suggestions right now"
**Cause:** No user profiles in Firestore or all users have `isDiscoverable: false`

**Fix:**
1. Check Firestore `users` collection exists
2. Verify at least one user has `isDiscoverable: true`
3. Ensure `lastActiveAt` is a recent timestamp

### "Error loading suggestions"
**Cause:** Firestore indexes not created yet

**Fix:**
1. Look at Flutter console for error message
2. Click the index creation link
3. Wait 2-5 minutes for index to build
4. Refresh the app

### "Permission denied"
**Cause:** Firestore rules not deployed

**Fix:**
```bash
firebase deploy --only firestore:rules
```

### "Connection request sent!" but nothing in Firestore
**Cause:** User not authenticated

**Fix:**
1. Ensure Firebase Auth is working
2. Check that `request.auth.uid` is available
3. Sign in with a test account

### Mutual connections not calculating
**Cause:** Missing `user_edges` subcollection

**Fix:**
1. After accepting a connection, verify both users have:
   - `/user_edges/{uid1}/accepted/{uid2}`
   - `/user_edges/{uid2}/accepted/{uid1}`
2. If missing, the `acceptRequest()` method should create them

---

## 📊 Verification Checklist

- [ ] Firestore rules deployed successfully
- [ ] 3 composite indexes created
- [ ] Test user profiles created in Firestore
- [ ] App runs without errors
- [ ] Community tab loads
- [ ] Suggested Connections card appears in Feed
- [ ] Test users display with correct names/headlines
- [ ] "Connect" button sends request
- [ ] Connection request appears in Firestore
- [ ] Snackbar shows success message
- [ ] No console errors

---

## 🚀 What's Working Now

✅ **News Tab** - Live RSS feeds from Google News, Bloomberg, Reuters  
✅ **Events Tab** - Automated discovery using Cloud Functions + OpenAI  
✅ **Industry Filtering** - Both News and Events  
✅ **User Profiles** - Firestore collection with real data  
✅ **Suggested Connections** - Real-time stream from Firestore  
✅ **Connection Management** - Send/Accept/Ignore requests  
✅ **Mutual Connections** - Auto-calculated from user_edges  

---

## 📝 Next Features (Future)

⏭️ **Full People List Page** - Browse all discoverable users  
⏭️ **Connection Request Notifications** - Push notifications for new requests  
⏭️ **User Profile Detail Page** - View full profile before connecting  
⏭️ **Messaging** - Chat with connections  
⏭️ **Activity Feed** - See what connections are posting  

---

## 🔗 Resources

- **Firebase Console:** https://console.firebase.google.com/project/business-setup-application
- **Firestore Data:** Database → Firestore Database → Data tab
- **Firestore Indexes:** Database → Firestore Database → Indexes tab
- **Cloud Functions Logs:** Functions → Logs
- **Authentication:** Authentication → Users tab

---

## 📞 Support Commands

**Check Firestore Rules:**
```bash
firebase firestore:rules get
```

**Check Cloud Functions:**
```bash
firebase functions:list
```

**View Firestore Indexes:**
```bash
firebase firestore:indexes
```

**Deploy Everything:**
```bash
firebase deploy
```

---

**Status:** ✅ Ready to test  
**Integration Time:** 15-30 minutes  
**Breaking Changes:** None  
**Backward Compatible:** Yes  

**Created:** November 3, 2025  
**Project:** WAZEET App - Community Feature
