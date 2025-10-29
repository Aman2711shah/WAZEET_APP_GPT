# File Upload & Admin System Guide

## Overview
A complete document upload system has been implemented for the WAZEET app, allowing clients to upload PDF and image files (JPEG, PNG) to Firebase Storage, which admins can then review and manage.

## Features Implemented

### 1. Client-Side File Upload
- **Location**: `lib/ui/pages/sub_service_detail_page.dart`
- **Supported Formats**: PDF, JPG, JPEG, PNG
- **Max File Size**: 10MB
- **File Picker Integration**: Uses `file_picker ^8.0.3` package

#### How It Works:
1. Client navigates to any service detail page
2. Clicks "Proceed with Premium Tier" or "Proceed with Standard Tier"
3. A modal appears showing required documents for that service tier
4. For each document:
   - Click "Upload" button
   - Select file from device
   - File is validated (size and type)
   - Progress indicator shows during upload
   - Green checkmark appears when successful
   - File name is displayed
   - Option to delete and re-upload
5. Once all documents are uploaded, "Submit Request" button becomes enabled
6. Submission saves to Firestore with all document URLs

#### Firebase Storage Structure:
```
service_documents/
  ├── {serviceId}/
  │   ├── {timestamp_filename1.pdf}
  │   ├── {timestamp_filename2.jpg}
  │   └── ...
```

### 2. Admin Panel
- **Location**: `lib/ui/pages/admin_requests_page.dart`
- **Access**: Navigate to Profile/More page → "Service Requests" (Admin section)

#### Admin Features:
- **Real-time Updates**: StreamBuilder automatically shows new submissions
- **Request Details**:
  - Service name and type
  - Selected tier (Premium/Standard)
  - Cost in AED
  - Timeline estimate
  - Status badge (Pending/Approved/Rejected/Processing)
  
- **Document Management**:
  - View all uploaded documents
  - Click any document to open in new tab
  - File type indicators (PDF icon for PDFs, image icon for images)
  
- **Status Management**:
  - Approve button (green)
  - Reject button (red)
  - Status updates are saved to Firestore
  - Color-coded status badges

#### Firestore Collection Structure:
```javascript
service_requests/
  ├── {requestId}/
  │   ├── serviceName: "Company Formation"
  │   ├── serviceType: "Mainland LLC"
  │   ├── tier: "Premium"
  │   ├── cost: 15000
  │   ├── timeline: "7-10 business days"
  │   ├── userId: "demo_user"
  │   ├── userName: "User Name"
  │   ├── userEmail: "user@example.com"
  │   ├── status: "pending"
  │   ├── createdAt: Timestamp
  │   └── documents: {
  │       "Trade License": "https://firebasestorage.../doc1.pdf",
  │       "Emirates ID": "https://firebasestorage.../doc2.jpg",
  │       ...
  │   }
```

## Testing Instructions

### Test Client Upload:
1. Open app in Chrome
2. Navigate to Services → Select any category → Select a service
3. Click "Proceed with Premium Tier"
4. Upload test documents (PDF or JPEG files under 10MB)
5. Watch for:
   - Upload progress spinner
   - Green checkmark on success
   - File name display
   - Submit button enabled when all uploaded
6. Click "Submit Request"
7. Check for success message

### Test Admin Panel:
1. Navigate to Profile/More page
2. Click "Service Requests" in Admin section
3. Verify uploaded request appears
4. Click to expand request details
5. Click on document names to view files
6. Test Approve/Reject buttons
7. Verify status badge changes

## Firebase Setup Required

### 1. Firebase Storage Rules:
```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    match /service_documents/{allPaths=**} {
      allow read: if request.auth != null;
      allow write: if request.auth != null 
                   && request.resource.size < 10 * 1024 * 1024;
    }
  }
}
```

### 2. Firestore Rules:
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /service_requests/{requestId} {
      allow read: if request.auth != null;
      allow create: if request.auth != null;
      allow update: if request.auth != null; // For admin status updates
    }
  }
}
```

## Future Enhancements

### Recommended Improvements:
1. **Authentication**: Replace `demo_user` with actual Firebase Auth user ID
2. **Email Notifications**: Send email to admin when new request submitted
3. **Push Notifications**: Notify client when request status changes
4. **File Preview**: Show PDF/image preview before upload
5. **Admin Filters**: Filter requests by status, date, service type
6. **Search**: Search requests by client name or service
7. **Export**: Download request details as PDF report
8. **Comments**: Allow admin to add notes to requests
9. **File Versioning**: Track document revisions
10. **Analytics**: Dashboard showing request metrics

## Troubleshooting

### Common Issues:

1. **"File too large" error**
   - Ensure file is under 10MB
   - Compress images before upload

2. **Upload fails silently**
   - Check Firebase Storage permissions
   - Verify Firebase project is properly configured
   - Check browser console for errors

3. **Admin panel shows no requests**
   - Verify Firestore collection name is `service_requests`
   - Check Firestore security rules
   - Ensure requests were successfully submitted

4. **Documents don't open**
   - Check Firebase Storage security rules
   - Verify download URLs are valid
   - Check if files were actually uploaded to Storage

## Code Files Modified/Created

### Created:
- `lib/ui/pages/admin_requests_page.dart` - Admin panel for viewing requests

### Modified:
- `lib/ui/pages/sub_service_detail_page.dart` - Added complete file upload functionality
- `lib/ui/pages/profile_page.dart` - Added admin panel navigation

## Security Notes

⚠️ **Important**: 
- Current implementation uses `demo_user` placeholder
- In production, implement proper Firebase Authentication
- Add role-based access control for admin panel
- Validate file types server-side (currently client-side only)
- Consider adding virus scanning for uploaded files
- Implement rate limiting to prevent abuse

## Package Dependencies

Already included in `pubspec.yaml`:
- `file_picker: ^8.0.3` - File selection
- `firebase_storage: ^12.3.6` - File storage
- `cloud_firestore: ^5.5.2` - Database

No additional packages needed!
