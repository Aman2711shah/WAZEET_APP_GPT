# HubSpot Integration - Quick Test Guide

## ✅ Deployment Status

**Deployed Functions (us-central1):**
- ✅ `testHubSpotConnection` - Test your HubSpot API key
- ✅ `syncPaymentToHubSpotManual` - Manually sync a payment to HubSpot
- ⏳ `onPaymentCreated` - Automatic sync (pending eventarc permissions)

## 🧪 Test the Integration

### Option 1: Test from Mobile App (Recommended)

1. **Run the Flutter app:**
   ```bash
   flutter run
   ```

2. **Navigate to Account Settings:**
   - Open the app
   - Go to Profile → Account Settings
   - You'll see a "HubSpot CRM Integration" test card at the top

3. **Click "Test Connection":**
   - This will call the `testHubSpotConnection` Cloud Function
   - It creates a test contact with email `test@wazeet.com`
   - You'll see a success message with the Contact ID

4. **Verify in HubSpot:**
   - Go to https://app.hubspot.com/contacts
   - Search for `test@wazeet.com`
   - You should see the test contact created!

### Option 2: Test via Firebase Console

1. **Open Firebase Console:**
   ```bash
   open https://console.firebase.google.com/project/business-setup-application/functions
   ```

2. **Find the `testHubSpotConnection` function**

3. **Click "..." → Test function**

4. **Use this test payload:**
   ```json
   {}
   ```

5. **Click "Run the function"** and check the response

### Option 3: Test via Command Line

```bash
cd functions
firebase functions:call testHubSpotConnection --data '{}'
```

## 📊 Check the Results

### Firebase Logs
```bash
firebase functions:log --only testHubSpotConnection --limit 10
```

### HubSpot Portal
1. Go to https://app.hubspot.com/contacts
2. Search for contacts created in the last hour
3. Look for test@wazeet.com or real user emails

## 🔄 Manual Sync Test

If you want to manually sync an existing payment:

1. **Get a payment ID from Firestore:**
   - Open Firebase Console → Firestore → `payments` collection
   - Copy a document ID

2. **Call the manual sync function:**
   ```typescript
   // From your Flutter app:
   final callable = FirebaseFunctions.instanceFor(region: 'us-central1')
       .httpsCallable('syncPaymentToHubSpotManual');
   
   final result = await callable.call({
     'paymentId': 'your-payment-id-here',
   });
   ```

## 🐛 Troubleshooting

### If test fails with "Failed to fetch"
- Check Firebase Functions logs: `firebase functions:log`
- Verify API key is set: `firebase functions:config:get`
- Check HubSpot API key is valid in your HubSpot account settings

### If contact not appearing in HubSpot
- Check the function response for the contactId
- Go to HubSpot → Contacts → All Contacts
- Use the search bar to find by email or Contact ID

### If you see "eventarc" errors
- This is expected for `onPaymentCreated` trigger
- The manual sync functions work fine
- We'll fix the automatic trigger permissions later

## ✅ Success Criteria

You know the integration is working when:
1. ✅ Test button shows "HubSpot Connected!"
2. ✅ You see a Contact ID in the response
3. ✅ Contact appears in HubSpot portal
4. ✅ Contact has correct email and phone number

## 🎯 Next Steps

Once testing is successful:
1. Fix eventarc permissions to enable automatic sync
2. Test with a real payment flow
3. Verify documents are attached as notes
4. Check deals are created correctly

## 📞 HubSpot Credentials Used

- **API Key:** `na2-0ba1-00ad-49fb-ae8d-ee4e0feff3cb`
- **Environment:** Production (Firebase Functions config + .env)
- **Region:** us-central1

---

**Need help?** Check the Firebase Functions logs or HubSpot API documentation.
