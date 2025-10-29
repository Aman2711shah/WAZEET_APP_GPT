# WAZEET App - Security & Payment Setup

## Firebase Security Rules

### Firestore Rules

Go to Firebase Console → Firestore → Rules and paste:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{db}/documents {
    function signedIn() { return request.auth != null; }

    // Public catalogs (read-only)
    match /{col=activities|freezones|services}/{doc} {
      allow read: if true;
      allow write: if false;
    }

    // User applications
    match /applications/{id} {
      allow create: if signedIn() && request.resource.data.user_id == request.auth.uid;
      allow read, update, delete: if signedIn() && resource.data.user_id == request.auth.uid;
      
      // Documents subcollection
      match /documents/{docId} {
        allow read, write: if signedIn() && 
          get(/databases/$(db)/documents/applications/$(id)).data.user_id == request.auth.uid;
      }
    }

    // Payments (user-created)
    match /payments/{id} {
      allow create: if signedIn();
      allow read: if signedIn();
      allow update, delete: if false;
    }

    // Posts (Community)
    match /posts/{id} {
      allow read: if true;
      allow create: if signedIn() && request.resource.data.uid == request.auth.uid;
      allow update, delete: if signedIn() && resource.data.uid == request.auth.uid;
    }

    // Users (optional)
    match /users/{uid} {
      allow read, write: if signedIn() && uid == request.auth.uid;
    }
  }
}
```

### Storage Rules

Go to Firebase Console → Storage → Rules and paste:

```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    function signedIn() { return request.auth != null; }

    match /applications/{applicationId}/{allPaths=**} {
      allow read, write: if signedIn() && 
        exists(/databases/(default)/documents/applications/$(applicationId)) &&
        get(/databases/(default)/documents/applications/$(applicationId)).data.user_id == request.auth.uid;
    }

    // Block everything else by default
    match /{path=**} {
      allow read, write: if false;
    }
  }
}
```

## Stripe Payment Setup

### 1. Initialize Firebase Functions

```bash
cd /Users/amanshah/WAZEET_APP_GPT
firebase init functions
```

Choose:
- JavaScript (or TypeScript if you prefer)
- Install dependencies: Yes

### 2. Install Stripe in Functions

```bash
cd functions
npm install stripe@^16.0.0
cd ..
```

### 3. Set Stripe Secret Key

Get your Stripe secret key from https://dashboard.stripe.com/apikeys

```bash
firebase functions:secrets:set STRIPE_SECRET
# Paste your secret key when prompted
```

### 4. Update functions/index.js

Replace the content with:

```javascript
const functions = require("firebase-functions");
const admin = require("firebase-admin");
const Stripe = require("stripe");

admin.initializeApp();

exports.createPaymentIntent = functions
  .region('me-central1')
  .https.onCall(async (data, context) => {
    if (!context.auth) {
      throw new functions.https.HttpsError('unauthenticated', 'Sign in required');
    }
    
    const stripe = new Stripe(process.env.STRIPE_SECRET);
    const amountAED = Math.round(Number(data.amount) * 100); // AED -> fils
    const applicationId = data.applicationId || '';

    try {
      const intent = await stripe.paymentIntents.create({
        amount: amountAED,
        currency: 'aed',
        automatic_payment_methods: { enabled: true },
        metadata: { uid: context.auth.uid, applicationId },
      });

      return { clientSecret: intent.client_secret };
    } catch (error) {
      console.error('Stripe error:', error);
      throw new functions.https.HttpsError('internal', 'Payment intent creation failed');
    }
  });
```

### 5. Deploy Functions

```bash
firebase deploy --only functions
```

### 6. Update Stripe Publishable Key

In `lib/main.dart`, replace the placeholder with your actual Stripe publishable key:

```dart
Stripe.publishableKey = 'pk_test_YOUR_ACTUAL_KEY_HERE';
```

Get it from: https://dashboard.stripe.com/apikeys

## Testing the Features

### Document Upload

1. Create a test application by clicking the "+" button in the Apps tab
2. Click the paper clip icon or "Documents" button
3. Click "Upload Document" and select a file
4. The file will be uploaded to Firebase Storage
5. View uploaded documents in the list

### Payments

1. Create a test application (or use existing one)
2. Click "Pay Now" button
3. Stripe payment sheet will open
4. Use test card: `4242 4242 4242 4242`
   - Expiry: Any future date
   - CVC: Any 3 digits
5. Complete payment
6. Payment record will be saved to Firestore

### Security Rules Testing

Try these to verify security:
- ✅ User can only see their own applications
- ✅ User can only upload to their own application folders
- ✅ User can only create posts with their own UID
- ✅ Anonymous users cannot create applications or posts
- ✅ Public services/activities are readable by all

## Dependencies Added

```yaml
dependencies:
  file_picker: ^8.0.3
  flutter_stripe: ^10.1.1
  cloud_functions: ^5.0.0
```

## Important Notes

1. **Stripe Test Mode**: Start with test keys, switch to live keys only when ready for production
2. **iOS Permissions**: Photo library access is already configured in Info.plist
3. **Web Support**: Document upload works on web using file bytes
4. **Error Handling**: All payment and upload operations include error handling with user feedback
5. **Firebase Region**: Cloud Functions are deployed to 'me-central1' (Middle East) for lower latency

## Next Steps

1. Deploy Firestore and Storage security rules
2. Set up Stripe account and get API keys
3. Deploy Cloud Functions
4. Test document uploads and payments
5. Monitor Firebase Console for activity and errors
