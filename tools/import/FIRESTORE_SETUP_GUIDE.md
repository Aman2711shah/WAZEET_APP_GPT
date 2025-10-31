# Firestore Setup and Import Guide

## ⚠️ Issue: Firestore Database Not Initialized

The import script is failing with "5 NOT_FOUND" error because **Firestore database hasn't been created** in your Firebase project yet.

## 📝 Step-by-Step Setup

### Step 1: Create Firestore Database (REQUIRED)

1. Go to [Firebase Console](https://console.firebase.google.com)
2. Select your project: **business-setup-application**
3. Click on **"Firestore Database"** in the left sidebar
4. Click **"Create database"** button
5. Choose mode:
   - **Production mode** (recommended for live app)
   - **Test mode** (if you want to test first)
6. Select location: Choose closest to UAE (e.g., `asia-south1` or `europe-west1`)
7. Click **"Enable"**
8. Wait for database creation (takes 1-2 minutes)

### Step 2: Run the Import Script

Once Firestore is created, run the import:

```bash
cd /Users/amanshah/WAZEET_APP_GPT/tools/import
node seed-array.js
```

### Step 3: Configure for Different Collections

The script is currently set up for **Activity List**:
- Source: `activity_list.json` (1,674 activities)
- Collection: `Activity list`

To import **Freezone Packages** instead, edit `seed-array.js`:

```javascript
const SOURCE_FILE = './excel-to-json.json';   // Freezone packages
const COLLECTION = 'freezone_packages';        // Collection name
```

## 📊 Available Data Files

1. **activity_list.json** (1,674 records)
   - Activity Master Numbers
   - ISIC Codes
   - Activity Names (English & Arabic)
   - Sectors, License Types, etc.

2. **excel-to-json.json** (1,524 records)
   - Freezone Packages
   - Pricing, Visas, Shareholders
   - Package details by freezone

## 🔧 Troubleshooting

### If you still get "NOT_FOUND" error:
1. Verify Firestore is created in Firebase Console
2. Check service account has Firestore permissions
3. Make sure you're using the correct project ID

### To update Firebase Rules after import:
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /{document=**} {
      allow read: if true;  // Public read
      allow write: if request.auth != null;  // Auth required for write
    }
  }
}
```

## ✅ Expected Output

```
Importing 1674 records into "Activity list"...
✔ Imported 450/1674
✔ Imported 900/1674
✔ Imported 1350/1674
✔ Imported 1674/1674
🎉 All done!
```

## 📂 File Structure

```
tools/import/
├── seed-array.js              # Import script
├── activity_list.json         # Activity data (1,674 records)
├── excel-to-json.json         # Freezone packages (1,524 records)
├── serviceAccountKey.json     # Firebase credentials
├── package.json               # Node dependencies
└── node_modules/              # Installed packages
```

## 🚀 Next Steps After Import

1. Verify data in Firebase Console > Firestore Database
2. Update Firestore security rules
3. Test queries from your Flutter app
4. Set up indexes if needed for complex queries
