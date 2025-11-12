# Business Activities Update Guide

## 📋 Overview

The business activities in the Company Setup flow are loaded from JSON files. You can update them in multiple ways.

## 🎯 Method 1: Using Custom Activities File (RECOMMENDED - Currently Active)

### File Location
`assets/images/custom-activities.json`

### Current Configuration
The app is now configured to use the custom activities file (simplified structure).

### JSON Structure
```json
[
  {
    "industry": "Industry Category Name",
    "business_activities": [
      {
        "Activity Name": "Activity Name Here",
        "Description": "Short description of what this activity involves"
      }
    ]
  }
]
```

### How to Add/Edit Activities

1. **Open the file:** `assets/images/custom-activities.json`

2. **Add a new activity to existing industry:**
```json
{
  "industry": "Technology",
  "business_activities": [
    {
      "Activity Name": "Blockchain Development",
      "Description": "Blockchain and cryptocurrency platform development"
    }
  ]
}
```

3. **Add a new industry with activities:**
```json
{
  "industry": "Real Estate",
  "business_activities": [
    {
      "Activity Name": "Property Management",
      "Description": "Managing residential and commercial properties"
    },
    {
      "Activity Name": "Real Estate Brokerage",
      "Description": "Buying, selling, and leasing property services"
    }
  ]
}
```

4. **Save the file**

5. **Rebuild the app:**
```bash
flutter clean
flutter pub get
flutter build apk --release
```

---

## 🗂️ Method 2: Using the Complete Database

### File Location
`assets/images/excel-to-json.industry-grouped.json`

### When to Use
- You need access to all 23,000+ activities
- You want complete ISIC codes and Arabic translations
- For production with comprehensive activity lists

### How to Switch Back

Edit `lib/company_setup_flow.dart` line 486:
```dart
_activitiesFuture = loadAllActivitiesWithDescriptions(
  'assets/images/excel-to-json.industry-grouped.json',  // Full database
);
```

### Extended JSON Structure
```json
{
  "industry": "Industry Name",
  "industry_arabic": "Arabic Name",
  "business_activities": [
    {
      "Activity Master Number": "AM-06675",
      "ISIC Code": "5590002",
      "Activity Name": "Activity Name",
      "Activity Name (Arabic)": "النشاط التجاري",
      "Description": "English description",
      "Description (Arabic)": "وصف عربي",
      "Allowed Facility Type": "Office,Land",
      "Brand: Brand Name": "AMC",
      "Main License Type": "Business License",
      "Sector": "Sector Name",
      "Documents required": "Required documents"
    }
  ]
}
```

---

## 🚀 Quick Add Activities (Common Examples)

### Technology & IT
```json
{
  "Activity Name": "AI/ML Development",
  "Description": "Artificial Intelligence and Machine Learning solutions development"
},
{
  "Activity Name": "Cybersecurity Services",
  "Description": "Network security, penetration testing, and security consulting"
},
{
  "Activity Name": "Mobile App Development",
  "Description": "iOS and Android mobile application development"
}
```

### E-commerce & Retail
```json
{
  "Activity Name": "Marketplace Platform",
  "Description": "Operating online marketplace connecting buyers and sellers"
},
{
  "Activity Name": "Subscription Services",
  "Description": "Recurring subscription-based product or service delivery"
}
```

### Professional Services
```json
{
  "Activity Name": "Financial Advisory",
  "Description": "Financial planning and investment advisory services"
},
{
  "Activity Name": "HR Consulting",
  "Description": "Human resources advisory and recruitment services"
},
{
  "Activity Name": "Legal Consulting",
  "Description": "Legal advisory and documentation services"
}
```

### Creative & Media
```json
{
  "Activity Name": "Video Production",
  "Description": "Professional video creation and editing services"
},
{
  "Activity Name": "Graphic Design",
  "Description": "Branding, logo design, and visual identity services"
},
{
  "Activity Name": "Photography Services",
  "Description": "Commercial and event photography"
}
```

---

## 🔧 After Making Changes

### For Development Testing
```bash
# Hot reload (if app is running)
# Press 'r' in terminal where Flutter is running

# Or restart
flutter run -d chrome
```

### For Production APK
```bash
# Clean build cache
flutter clean

# Get dependencies
flutter pub get

# Build APK
flutter build apk --release

# APK will be at: build/app/outputs/flutter-apk/app-release.apk
```

---

## 📝 Tips

1. **Keep descriptions concise** (1-2 lines) - they show in collapsed view
2. **Use clear activity names** - users will search by these
3. **Group related activities** under same industry
4. **Test search functionality** after adding new activities
5. **Backup original file** before major changes

---

## 🐛 Troubleshooting

### Activities not showing up?
1. Check JSON syntax (use JSON validator)
2. Ensure file is saved
3. Run `flutter clean` and rebuild
4. Check console for parsing errors

### App crashing on Activities screen?
1. Validate JSON format
2. Ensure all required fields exist:
   - "Activity Name"
   - "Description"
3. Check for special characters/encoding issues

### Search not working?
- Keywords are searched in both activity name and description
- Use 2-4 keywords for best results
- Check spelling in JSON file

---

## 📞 Current Setup Summary

✅ **Active File:** `custom-activities.json`  
✅ **Total Activities:** ~10 examples (you can add more)  
✅ **Industries:** Technology, E-commerce, Consulting, Marketing  
✅ **Search:** Multi-keyword search enabled  
✅ **Accordion UI:** Expand/collapse working  

To add more activities, simply edit `assets/images/custom-activities.json` and rebuild!
