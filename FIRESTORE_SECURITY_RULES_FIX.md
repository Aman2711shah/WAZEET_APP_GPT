# Firestore Security Rules Setup

## ⚠️ Current Issue: Permission Denied

The Freezone Finder feature is getting "permission-denied" errors when trying to read from Firestore collections.

## 🔧 Fix: Update Firestore Security Rules

### Step 1: Go to Firebase Console

1. Open [Firebase Console](https://console.firebase.google.com)
2. Select your project: **business-setup-application**
3. Click **"Firestore Database"** in the left sidebar
4. Click the **"Rules"** tab at the top

### Step 2: Update Security Rules

Replace the existing rules with this configuration:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    
    // Allow public READ access to Activity list
    match /Activity list/{document=**} {
      allow read: if true;  // Public read access
      allow write: if request.auth != null;  // Only authenticated users can write
    }
    
    // Allow public READ access to freezone_packages
    match /freezone_packages/{document=**} {
      allow read: if true;  // Public read access
      allow write: if request.auth != null;  // Only authenticated users can write
    }
    
    // Allow public READ access to freezone collection
    match /freezone/{document=**} {
      allow read: if true;
      allow write: if request.auth != null;
    }
    
    // Protected collections - require authentication
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    
    match /applications/{document=**} {
      allow read, write: if request.auth != null;
    }
    
    // Default: deny all other access
    match /{document=**} {
      allow read, write: if false;
    }
  }
}
```

### Step 3: Publish Rules

1. Click **"Publish"** button
2. Confirm the changes

## 🔍 What This Does

### Public Read Access (allow read: if true):
- ✅ `Activity list` - Anyone can search activities
- ✅ `freezone_packages` - Anyone can browse packages
- ✅ `freezone` - Anyone can view freezone data

### Protected Write Access (allow write: if request.auth != null):
- 🔒 Only authenticated users can create/update/delete documents
- Prevents unauthorized data modification

### User Data Protection:
- 🔐 Users can only access their own data in `/users/{userId}`
- 🔐 Applications require authentication

## ✅ After Applying Rules

1. Refresh your Flutter app
2. Try the Freezone Finder again
3. Activity search should work without errors
4. Package search should return results

## 🚨 Security Best Practices

### For Production:
Consider adding rate limiting and more specific rules:

```javascript
match /Activity list/{document=**} {
  allow read: if true;  // Or add: request.time < timestamp.date(2026, 1, 1);
  allow write: if request.auth != null 
    && request.auth.token.admin == true;  // Only admins can write
}
```

### For Development:
Current rules are fine for testing and demo purposes.

## 📊 Testing Rules

You can test rules in Firebase Console:
1. Go to Rules tab
2. Click "Rules Playground"
3. Test read/write operations
4. Verify access patterns

## 🔄 Alternative: Test Mode (Temporary)

If you want to test quickly, you can temporarily use test mode:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /{document=**} {
      allow read, write: if true;  // WARNING: Only for testing!
    }
  }
}
```

⚠️ **WARNING**: Test mode allows anyone to read/write ALL data. Only use during development and remember to change before going live!

## ✨ Expected Behavior After Fix

- ✅ Activity search works instantly
- ✅ No permission errors
- ✅ Packages load successfully
- ✅ Smooth user experience
