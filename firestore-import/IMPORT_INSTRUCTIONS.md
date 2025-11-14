# Quick Import Instructions

##  Method: Firebase Console Manual Import

1. Go to Firebase Console: https://console.firebase.google.com/
2. Select project: `wazeet-business-setup`
3. Go to Firestore Database
4. If `freezonePackages` collection doesn't exist:
   - Click "Start collection"
   - Name it: `freezonePackages`

5. For EACH package below, click "Add document":
   - Let Firebase auto-generate the Document ID
   - Copy each field from the data below

---

## COPY-PASTE DATA (62 packages total)

### IFZA Packages (16 total)

**Package 1:**
```
freezone: IFZA
product: 0 Visa License
license_cost_including_quota_fee: 12900
office_facility_requirements: Co-Working/Flexi-Desk
no_of_activities_allowed_under_license: 7 Mix & Match
visa_eligibility: 0
visa_cost_investor: 0
visa_cost_manager: 0
visa_cost_employment: 0
immigration_establishment_card: 0
e_channel_registration: 0
medical_cost: 0
eid_cost: 0
jurisdiction: Freezone
```

**Package 2:**
```
freezone: IFZA
product: 1 Visa License
license_cost_including_quota_fee: 14900
office_facility_requirements: Co-Working/Flexi-Desk
no_of_activities_allowed_under_license: 7 Mix & Match
visa_eligibility: 1
visa_cost_investor: 4750
visa_cost_manager: 3750
visa_cost_employment: 3750
immigration_establishment_card: 1620
e_channel_registration: 0
medical_cost: 450
eid_cost: 390
jurisdiction: Freezone
```

... Continue for all 16 IFZA packages...

---

## RECOMMENDED: Use Node.js Script Instead

Since manual entry of 62 documents is tedious, I recommend using the Node.js import script:

1. Download Firebase Admin SDK service account key:
   - Firebase Console > Project Settings > Service Accounts
   - Click "Generate new private key"
   - Save as `serviceAccountKey.json` in project root

2. Run the import script:
```bash
cd /Users/amanshah/WAZEET_APP_GPT
npm install firebase-admin
node import-packages-to-firestore.js
```

This will import all 62 packages automatically in about 30 seconds.

Let me know which method you prefer and I'll help you complete the import!
