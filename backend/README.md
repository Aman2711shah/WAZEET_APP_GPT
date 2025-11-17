# WAZEET Backend (Service Applications)

Express + TypeScript backend that stores Service tab applications in Firebase (Firestore + Storage).

## Features
- POST `/api/service/application` accepts `multipart/form-data`
- Saves application fields to Firestore (`service_applications` collection)
- Uploads documents to Firebase Storage and stores signed download URLs in Firestore

## Setup
1. Create `.env` from `.env.example` and fill values from your Firebase service account:

```
FIREBASE_PROJECT_ID=...
FIREBASE_CLIENT_EMAIL=...
FIREBASE_PRIVATE_KEY="-----BEGIN PRIVATE KEY-----\n...\n-----END PRIVATE KEY-----\n"
FIREBASE_STORAGE_BUCKET=your-project-id.appspot.com
PORT=3000
```

> Important: keep the `\n` newlines in the private key (or use a single line key with escaped newlines).

2. Install dependencies and start locally:

```
npm install
npm run dev
```

3. Test upload (example with curl):

```
curl -X POST http://localhost:3000/api/service/application \
  -F "fullName=Jane Doe" \
  -F "email=jane@example.com" \
  -F "applicationId=APP-123" \
  -F "selectedService=Company Setup" \
  -F "visaCount=2" \
  -F "documents=@/path/passport.pdf" \
  -F "documents=@/path/visa.png"
```

## Data Model
- Collection: `service_applications`
- Document id: `applicationId` (if provided) or generated UUID
- Field `documents[]` contains metadata including `downloadURL` and `storagePath`

## Notes
- File size limited to 10 MB each (configurable in router)
- Allowed types: pdf, jpeg, png, doc, docx
- Signed URLs are generated for long-lived read access
