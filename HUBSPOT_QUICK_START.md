# HubSpot Integration - Quick Start Guide

## 🚀 Quick Setup (5 minutes)

Follow these steps to integrate HubSpot CRM with your WAZEET app:

### Step 1: Configure HubSpot API Key

```bash
# Set your HubSpot API key in Firebase Functions
cd functions

# Production environment
firebase functions:config:set hubspot.api_key="na2-0ba1-00ad-49fb-ae8d-ee4e0feff3cb"

# Local development (create .env file)
echo 'HUBSPOT_API_KEY=na2-0ba1-00ad-49fb-ae8d-ee4e0feff3cb' >> .env
```

### Step 2: Deploy Functions

```bash
# Install dependencies
npm install

# Build TypeScript
npm run build

# Deploy to Firebase
firebase deploy --only functions:onPaymentCreated,functions:syncPaymentToHubSpotManual,functions:testHubSpotConnection
```

### Step 3: Test the Integration

#### Option A: Test Connection (Recommended First)

```dart
// In your Flutter app (e.g., in a test button)
import 'package:cloud_functions/cloud_functions.dart';

Future<void> testHubSpotConnection() async {
  try {
    final callable = FirebaseFunctions.instanceFor(region: 'me-central1')
        .httpsCallable('testHubSpotConnection');
    
    final result = await callable.call({});
    
    if (result.data['success']) {
      print('✅ HubSpot connected!');
      print('Test contact ID: ${result.data['contactId']}');
    } else {
      print('❌ Connection failed: ${result.data['error']}');
    }
  } catch (e) {
    print('Error: $e');
  }
}
```

#### Option B: Complete a Test Payment

1. Run your app
2. Select any service
3. Complete a payment
4. Check your HubSpot contacts to see the new lead!

### Step 4: Verify in HubSpot

1. Log in to HubSpot: https://app.hubspot.com
2. Go to **Contacts** → **Contacts**
3. Look for the test contact (test@wazeet.com or your real user)
4. Go to **Sales** → **Deals**
5. Verify the deal was created and associated with the contact

---

## 📋 What Happens Automatically

Every time a user completes a payment:

1. ✅ **Contact Created/Updated** in HubSpot with:
   - User's email, name, phone
   - Company name (if provided)
   - Service details
   - Payment amount and date

2. ✅ **Deal Created** with:
   - Deal name: "Service Name - Company/Email"
   - Amount: Payment amount
   - Stage: Closed Won (payment completed)
   - Associated with the contact

3. ✅ **Documents Logged** as a note:
   - Links to all uploaded documents
   - Upload timestamp
   - Document count

4. ✅ **Firestore Updated** with:
   - HubSpot contact ID
   - HubSpot deal ID
   - Sync timestamp

---

## 🔧 Advanced Configuration

### Custom Properties in HubSpot

For best results, create these custom properties in HubSpot:

**Contact Properties:**
- `service_purchased` - Single-line text
- `service_category` - Single-line text
- `amount_paid` - Single-line text
- `payment_date` - Date
- `application_id` - Single-line text
- `document_count` - Number
- `lead_source` - Single-line text (set to "WAZEET Mobile App")

**Deal Properties:**
- `service_type` - Single-line text
- `payment_status` - Dropdown (paid, pending, failed)
- `application_id` - Single-line text

### Manual Sync for Failed Payments

If a sync fails, retry manually:

```dart
Future<void> retrySyncToHubSpot(String paymentId) async {
  final callable = FirebaseFunctions.instanceFor(region: 'me-central1')
      .httpsCallable('syncPaymentToHubSpotManual');
  
  final result = await callable.call({'paymentId': paymentId});
  
  print('Contact ID: ${result.data['contactId']}');
  print('Deal ID: ${result.data['dealId']}');
}
```

---

## 📊 Monitoring

### View Sync Logs

```bash
# All HubSpot-related logs
firebase functions:log --only onPaymentCreated

# Recent errors
firebase functions:log --only onPaymentCreated | grep ERROR
```

### Check Firestore

Query payments to see which have been synced:

```javascript
// In Firebase Console or your app
db.collection('payments')
  .where('hubspot_synced_at', '!=', null)
  .get()
```

---

## 🐛 Troubleshooting

### "HubSpot API key not configured"
```bash
# Re-set the API key
firebase functions:config:set hubspot.api_key="YOUR_KEY_HERE"

# Redeploy
firebase deploy --only functions
```

### "No email found for user"
Ensure users have valid email addresses in their profile:
```dart
// When creating user profile
await FirebaseFirestore.instance.collection('users').doc(uid).set({
  'email': user.email,  // ← Must be present
  'displayName': user.displayName,
  // ... other fields
});
```

### Sync Not Happening
1. Check function logs: `firebase functions:log`
2. Verify payment document has `user_id` field
3. Ensure payment status is `'paid'`
4. Check application document exists with service details

---

## ✅ Checklist

- [ ] HubSpot API key configured in Firebase
- [ ] Functions deployed successfully
- [ ] Test connection successful
- [ ] Test payment creates HubSpot contact
- [ ] Test payment creates HubSpot deal
- [ ] Documents appear in HubSpot notes
- [ ] Custom properties created in HubSpot (optional)
- [ ] Monitoring set up

---

## 🎯 Next Steps

1. **Customize Deal Pipeline**: Set up specific pipelines for different service types
2. **Email Workflows**: Create HubSpot workflows to auto-email leads
3. **Reporting**: Build dashboards in HubSpot for sales analytics
4. **Team Notifications**: Set up Slack/email notifications for new leads
5. **Lead Scoring**: Configure lead scoring based on service value

---

## 📞 Support

- Email: support@wazeet.com
- Phone: +971559986386
- HubSpot API Docs: https://developers.hubspot.com/docs/api/overview

---

**🎉 That's it! Your HubSpot integration is ready!**
