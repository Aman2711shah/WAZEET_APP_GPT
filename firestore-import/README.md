# Firestore Package Data Import

## Quick Import Using Firebase Console (Recommended)

The easiest way to import the package data is to add it directly through the Firebase Console.

### Steps:

1. **Go to Firebase Console**
   - Open https://console.firebase.google.com/
   - Select your project: `wazeet-business-setup`
   - Go to Firestore Database

2. **Create Collection**
   - Click "Start collection"
   - Collection ID: `freezonePackages`

3. **Add Documents**
   - For each package below, click "Add document"
   - Auto-generate Document ID
   - Add all fields with their values

## Package Data to Import

### Collection Name: `freezonePackages`

I've prepared all the data for you. You have 4 freezones with a total of 62 packages:

- **IFZA**: 16 packages
- **MEYDAN**: 16 packages  
- **RAKEZ**: 16 packages
- **SHAMS**: 16 packages

### Quick Import Script (Alternative)

If you prefer to use a script, I can help you with these options:

#### Option 1: Using Firebase CLI (Recommended for bulk import)
```bash
# Install Firebase Tools
npm install -g firebase-tools

# Login to Firebase
firebase login

# Use the import script
node firestore-import/import-all-packages.js
```

#### Option 2: Manual Console Import
Follow the Firebase Console steps above and copy-paste each JSON object as a new document.

## Fields in Each Package Document

Each package document should have these fields:

- `freezone` (string): e.g., "IFZA", "MEYDAN", "RAKEZ", "SHAMS"
- `product` (string): e.g., "1 Visa License"
- `license_cost_including_quota_fee` (number)
- `office_facility_requirements` (string): "Co-Working/Flexi-Desk" or "Physical Office"
- `no_of_activities_allowed_under_license` (string)
- `visa_eligibility` (number)
- `visa_cost_investor` (number)
- `visa_cost_manager` (number)
- `visa_cost_employment` (number)
- `immigration_establishment_card` (number)
- `e_channel_registration` (number)
- `medical_cost` (number)
- `eid_cost` (number)
- `jurisdiction` (string): "Freezone"

## Verify Import

After importing, verify by running a test query in your Flutter app:
1. Select business activity
2. Choose office type and jurisdiction
3. The app should display recommended packages sorted by price

## Need Help?

If you encounter any issues:
1. Check that all fields are properly typed (numbers as numbers, not strings)
2. Ensure the collection name is exactly `freezonePackages`  
3. Verify the jurisdiction and office_facility_requirements match what your app expects

---

**Total Packages**: 62
**Last Updated**: November 14, 2025
