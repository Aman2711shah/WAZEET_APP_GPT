# Quick Import Guide - Freezone Packages to Firestore

## Step 1: Get Firebase Service Account Key

1. Go to Firebase Console: https://console.firebase.google.com/
2. Select your project: `wazeet-business-setup`
3. Click ⚙️ (Settings) > Project Settings
4. Go to "Service Accounts" tab
5. Click "Generate new private key"
6. Save the downloaded JSON file as `serviceAccountKey.json` in your project root:
   `/Users/amanshah/WAZEET_APP_GPT/serviceAccountKey.json`

## Step 2: Install Dependencies

```bash
cd /Users/amanshah/WAZEET_APP_GPT
npm install firebase-admin
```

## Step 3: Run Import Script

```bash
node import-packages-to-firestore.js
```

## Expected Output:

```
Data loaded. Ready to import...
Total packages to import: 16

🚀 Starting import...

✅ IFZA - 0 Visa License
✅ IFZA - 1 Visa License
✅ IFZA - 2 Visa License
...
✅ IFZA - 15 Visa License

=== Import Complete ===
✅ Success: 16
❌ Errors: 0
📦 Total: 16

✨ All done!
```

## Step 4: Verify Import

1. Go to Firebase Console > Firestore Database
2. You should see collection `freezonePackages` with 16 documents
3. Each document should have all fields properly populated

## Troubleshooting:

- **Error: Cannot find module 'firebase-admin'**
  - Run: `npm install firebase-admin`

- **Error: serviceAccountKey.json not found**
  - Make sure you downloaded the key and placed it in the correct location

- **Error: Permission denied**
  - Make sure your service account has Firestore write permissions

---

**Note:** This script currently imports only IFZA packages (16 total). I can create separate scripts for MEYDAN, RAKEZ, and SHAMS, or combine them all into one script. Let me know your preference!
