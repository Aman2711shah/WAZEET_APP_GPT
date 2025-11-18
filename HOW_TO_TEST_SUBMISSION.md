# 🧪 How to Test Application Submission

## 📋 Prerequisites

1. **Make sure you're signed in to the app**
   - If not signed in, you'll be prompted to sign in when you try to submit
   - Use any test account (email/password, Google, or Apple sign-in)

2. **Have the app running**
   ```bash
   flutter run -d chrome
   # OR
   flutter run -d <your-device>
   ```

---

## 🎯 Method 1: Submit via Package Selection (Recommended)

### **Step-by-Step:**

1. **Navigate to Company Setup Flow**
   - From home page, find "Company Setup" or similar navigation
   - Start the setup wizard

2. **Complete the Wizard:**
   
   **Step 1: Business Activities**
   - Select any activities (e.g., "Trading", "Consulting")
   - Click Next

   **Step 2: Shareholders**
   - Click "Add Shareholder"
   - Enter test data:
     - Name: "Test Shareholder"
     - Nationality: "United Arab Emirates"
     - Date of Birth: Any date
   - Save shareholder
   - Click Next

   **Step 3: Visa Requirements**
   - Set Employment Visas: 2
   - Set Investor Visas: 1
   - Click Next

   **Step 4: Emirate Selection**
   - Select any emirate (e.g., "Dubai")
   - Click Next

   **Step 5: Office & Jurisdiction**
   - Office Type: Select "Flexi Desk" or "Private Office"
   - Jurisdiction: Select "Freezone" or "Mainland"
   - Click Next

3. **View Package Recommendations**
   - On the Summary page, click **"View Package Recommendations"**
   - Wait for packages to load from Firestore

4. **Select a Package**
   - Browse the recommended packages (sorted by price)
   - Find one you like (the first one is usually marked "BEST VALUE")
   - Click **"Select This Package"** button

5. **Confirm Selection**
   - Review the confirmation dialog showing:
     - Freezone name
     - Product name
     - Total cost
   - Click **"Confirm Selection"**

6. **Get Your Request ID**
   - Success dialog appears with green checkmark ✓
   - **IMPORTANT:** Copy the Request ID shown (looks like: `2hf8d9a0s8df7`)
   - You have two options:
     - Click "Close" to go back
     - Click "Track Application" to see status immediately

---

## 🎯 Method 2: Submit Custom Quote Request

### **Step-by-Step:**

1. **Complete Steps 1-5 from Method 1** (same setup wizard)

2. **Request Custom Quote**
   - On the Summary page, click **"Request Custom Quote"** button
   - (This is below the "View Package Recommendations" button)

3. **Review Your Requirements**
   - Confirmation dialog shows all your selections:
     - Activities count
     - Shareholders count
     - Visas count
     - Emirate
     - Office type
     - Jurisdiction
   - Click **"Submit Request"**

4. **Get Your Request ID**
   - Success dialog appears with green checkmark ✓
   - **IMPORTANT:** Copy the Request ID shown
   - Two options:
     - Click "Close" to go home
     - Click "Track Request" to see status immediately

---

## 🔍 How to Check Your Submission

### **Option A: Via Applications Page (In-App)**

1. **Navigate to Applications/Tracking Page**
   - Look for "Track Applications" or "My Applications" in the menu
   - Or go directly to the Applications page

2. **Enter Your Request ID**
   - Paste the Request ID you copied earlier
   - Click "Track" or "Search"

3. **View Status**
   - You'll see:
     - Service Name
     - Status (should be "pending")
     - Submission date
     - Details of your request

### **Option B: Via Firestore Console (Direct Database Check)**

1. **Open Firebase Console**
   - Go to: https://console.firebase.google.com/
   - Select your project: `business-setup-application`

2. **Navigate to Firestore**
   - In left menu, click "Firestore Database"
   - Click "Data" tab

3. **Find Your Submission**
   - Look for collection: `service_requests`
   - Click to expand
   - Find your Request ID in the list
   - Click on it to see all the data

4. **Verify Data Saved**
   
   **For Package Selection, you should see:**
   ```javascript
   {
     serviceName: "Company Formation"
     serviceType: "IFZA - 3 Visa License" (example)
     tier: "standard"
     userId: "your_user_id"
     userEmail: "your_email"
     userName: "Your Name"
     status: "pending"
     createdAt: Timestamp
     packageDetails: {
       freezone: "IFZA"
       product: "3 Visa License"
       jurisdiction: "Freezone"
       totalCost: 45000.0
       visaEligibility: 3
       activitiesAllowed: 7
       costBreakdown: {...}
     }
   }
   ```

   **For Custom Quote, you should see:**
   ```javascript
   {
     serviceName: "Company Formation - Custom Quote"
     serviceType: "Custom Package"
     tier: "custom"
     userId: "your_user_id"
     userEmail: "your_email"
     status: "pending"
     createdAt: Timestamp
     companySetupData: {
       businessActivities: ["Trading", "Consulting"]
       shareholdersCount: 1
       shareholders: [{...}]
       totalVisas: 3
       employmentVisas: 2
       investorVisas: 1
       emirate: "Dubai"
       officeSpaceType: "Flexi Desk"
       jurisdictionType: "Freezone"
     }
   }
   ```

### **Option C: Via Admin Dashboard (If You Have Admin Access)**

1. **Login as Admin**
   - Sign in with an admin account

2. **Go to Admin Requests Page**
   - Navigate to Admin panel
   - Click "Service Requests" or similar

3. **View All Submissions**
   - See list of all pending requests
   - Find yours by Request ID or email
   - Click to view details

---

## ✅ What to Verify

After submitting, check that:

- [ ] Request ID was generated and shown to you
- [ ] Success message appeared with green checkmark
- [ ] Data appears in Firestore `service_requests` collection
- [ ] Your userId and email are correctly saved
- [ ] Status is "pending"
- [ ] Timestamp is correct (current time)
- [ ] For package selection: packageDetails contains correct data
- [ ] For custom quote: companySetupData contains your selections

---

## 🐛 Troubleshooting

### **"Please sign in to submit an application"**
- You're not authenticated
- Sign in with any method (email/password, Google, Apple)
- Try submission again

### **"Please complete all required fields"**
- You missed Office Type or Jurisdiction selection
- Go back in the wizard
- Complete those fields
- Try again

### **"Error submitting application"**
- Check your internet connection
- Check browser console for errors (F12 → Console tab)
- Verify Firestore is accessible
- Try again

### **Request ID not showing**
- This shouldn't happen, but if it does:
- Check Firestore console directly
- Look for most recent entry in `service_requests`
- The document ID is your Request ID

### **Can't find Applications page**
- Navigate using the URL structure in your app
- Or check home menu for tracking/applications link
- Alternatively, use Firestore console method above

---

## 📊 Quick Test Script

Copy and use this test data for quick testing:

**Test Shareholder:**
- Name: `John Doe`
- Nationality: `United Arab Emirates`
- DOB: `1990-01-15`

**Business Setup:**
- Activities: `Trading`, `Consulting` (select 2)
- Shareholders: 1 (add John Doe above)
- Employment Visas: 2
- Investor Visas: 1
- Total Visas: 3
- Emirate: `Dubai`
- Office Type: `Flexi Desk`
- Jurisdiction: `Freezone`

**Expected Result:**
- Multiple packages shown
- First package likely IFZA or similar
- Cost around 35,000 - 50,000 AED
- Can submit successfully

---

## 🎓 Pro Tips

1. **Save Request IDs**: Keep a list of test Request IDs for reference
2. **Test Both Methods**: Try both package selection and custom quote
3. **Test Error Cases**: Try submitting without signing in to see error handling
4. **Check Admin View**: If you have admin access, verify requests appear there
5. **Test Tracking**: Use the tracking feature to find submissions by ID

---

## 📸 Screenshot Checklist

Take screenshots of:
1. Package recommendations page with "Select This Package" button
2. Confirmation dialog with package details
3. Success dialog with Request ID
4. Firestore console showing the saved data
5. Applications tracking page showing your request

---

## 🔗 Related Documentation

- Full implementation details: `COMPANY_SETUP_SUBMISSION.md`
- Quick reference: `SUBMISSION_FEATURE_QUICK_START.md`
- Admin processing guide: See "For Admins" section in quick start

---

## ✨ Next Steps After Testing

Once you verify submissions work:

1. **Production Testing**
   - Test on all platforms (web, iOS, Android)
   - Test with different user accounts
   - Test with various package combinations

2. **Admin Training**
   - Show admin team how to view requests
   - Explain status update process
   - Set up notification system

3. **User Communication**
   - Email templates for submission confirmation
   - WhatsApp message templates
   - Status update notifications

4. **Payment Integration**
   - Connect selected packages to payment flow
   - Test Stripe integration
   - Verify HubSpot sync on payment

---

**Ready to test? Start with Method 1 (Package Selection) - it's the most common user flow!** 🚀
