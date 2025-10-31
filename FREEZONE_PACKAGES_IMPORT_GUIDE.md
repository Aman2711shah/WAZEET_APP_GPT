# Freezone Packages Import Guide

This guide explains how to import the UAE Freezone pricing data from CSV into Firebase Firestore.

## Overview

The CSV file `UAE_Freezones_Pricing_All_17_Freezones.csv` contains pricing information for 17 freezones across the UAE. This data will be imported into the `freezonePackages` collection in Firestore.

## Data Structure

Each package document in Firestore will contain:

| Field | Type | Description |
|-------|------|-------------|
| `freezone` | String | Name of the freezone (e.g., "SHAMS", "RAKEZ") |
| `packageName` | String | Name of the package (e.g., "Media Package", "Coworking") |
| `noOfActivitiesAllowed` | String | Number/range of activities allowed |
| `noOfShareholdersAllowed` | String | Number of shareholders allowed |
| `noOfVisasIncluded` | Number | Number of visas included |
| `tenureYears` | Number | Package tenure in years |
| `priceAED` | Number | Base price in AED |
| `immigrationCardFee` | String | Immigration card fee details |
| `eChannelFee` | String | E-channel fee details |
| `visaCostAED` | String | Visa cost details |
| `medicalFee` | String | Medical fee details |
| `emiratesIDFee` | String | Emirates ID fee details |
| `changeOfStatusFee` | String | Change of status fee |
| `otherCostsNotes` | String | Additional costs and notes |
| `visaEligibility` | String | Visa eligibility information |
| `createdAt` | Timestamp | Auto-generated timestamp |
| `updatedAt` | Timestamp | Auto-generated timestamp |
| `isActive` | Boolean | Whether package is active (true) |

## Import Methods

### Method 1: Run Dart Script (Recommended)

The easiest way to import the data:

```bash
# Make sure the CSV file is in the correct location
# /Users/amanshah/Downloads/UAE_Freezones_Pricing_All_17_Freezones.csv

# Run the import script
dart run lib/scripts/import_freezone_packages.dart
```

The script will:
1. Initialize Firebase
2. Read the CSV file
3. Ask if you want to clear existing packages
4. Import all packages to Firestore
5. Show statistics of imported data

### Method 2: Use Flutter UI (Alternative)

You can also use the visual import page:

1. Add navigation to the import page in your app:
```dart
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => const ImportFreezonePackagesPage(),
  ),
);
```

2. Click "Import from CSV" button
3. Monitor the progress
4. View package counts by freezone

## Freezones Included

The CSV contains packages from 17 freezones:

1. **SHAMS** - Sharjah Media City
2. **RAK DAO** - Web3 and Digital Assets
3. **SRTIP Accelerator** - Sharjah Research Technology and Innovation Park
4. **ANCFZ** - Ajman Free Zone
5. **IFZA Dubai** - International Free Zone Authority
6. **Meydan Free Zone**
7. **RAKEZ** - Ras Al Khaimah Economic Zone
8. **UAQ FTZ** - Umm Al Quwain Free Trade Zone
9. **Dubai South**
10. **DMCC** - Dubai Multi Commodities Centre
11. **HFZA** - Hamriyah Free Zone
12. **SPC** - Sharjah Publishing City
13. **DIFC** - Dubai International Financial Centre
14. **ADGM** - Abu Dhabi Global Market
15. **KEZAD** - Khalifa Economic Zones Abu Dhabi
16. **SAIF** - Sharjah Airport International Free Zone
17. **Creative City Fujairah**

## Verification

After import, verify the data:

```dart
// Get all packages
final packages = await FirebaseFirestore.instance
    .collection('freezonePackages')
    .get();

print('Total packages: ${packages.docs.length}');

// Get packages by freezone
final shamsPack ages = await FirebaseFirestore.instance
    .collection('freezonePackages')
    .where('freezone', isEqualTo: 'SHAMS')
    .get();

print('SHAMS packages: ${shamsPackages.docs.length}');
```

## Troubleshooting

### CSV file not found
Make sure the CSV file is at:
```
/Users/amanshah/Downloads/UAE_Freezones_Pricing_All_17_Freezones.csv
```

### Firebase not initialized
Ensure Firebase is properly configured:
```bash
flutter pub get
flutterfire configure
```

### Import errors
- Check Firestore security rules allow writes
- Verify Firebase project is active
- Ensure you have internet connection

## Next Steps

After importing, you can:

1. **Query packages by freezone:**
```dart
final packages = await FirebaseFirestore.instance
    .collection('freezonePackages')
    .where('freezone', isEqualTo: 'SHAMS')
    .get();
```

2. **Filter by price range:**
```dart
final affordablePackages = await FirebaseFirestore.instance
    .collection('freezonePackages')
    .where('priceAED', isLessThanOrEqualTo: 15000)
    .orderBy('priceAED')
    .get();
```

3. **Search by number of visas:**
```dart
final packages = await FirebaseFirestore.instance
    .collection('freezonePackages')
    .where('noOfVisasIncluded', isGreaterThanOrEqualTo: 2)
    .get();
```

## Collection Security

Don't forget to update your Firestore security rules:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Freezone packages - read by all, write by admins only
    match /freezonePackages/{packageId} {
      allow read: if true;
      allow write: if request.auth != null && 
                      get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin';
    }
  }
}
```

## Notes

- Total packages in CSV: ~300+
- Import typically takes 30-60 seconds
- Each document gets a unique auto-generated ID
- Timestamps are automatically added
- All packages are marked as `isActive: true` by default
