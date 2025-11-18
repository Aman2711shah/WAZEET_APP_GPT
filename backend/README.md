# WAZEET Backend (Service Applications)

Express + TypeScript backend that stores Service tab applications in Firebase (Firestore + Storage).

## Features
- POST `/api/service/application` accepts `multipart/form-data`
- Saves application fields to Firestore (`service_applications` collection)
- Uploads documents to Firebase Storage and stores signed download URLs in Firestore
- **Security enhancements**:
  - Rate limiting (global + per-endpoint)
  - Optional API key authentication
  - Optional JWT authentication
  - Request body validation with Zod
- **Per-file documentType** from frontend (optional parallel array)
- **Cloud Functions** for signed URL refresh and application triggers

## Setup
1. Create `.env` from `.env.example` and fill values from your Firebase service account:

```
FIREBASE_PROJECT_ID=...
FIREBASE_CLIENT_EMAIL=...
FIREBASE_PRIVATE_KEY="-----BEGIN PRIVATE KEY-----\n...\n-----END PRIVATE KEY-----\n"
FIREBASE_STORAGE_BUCKET=your-project-id.appspot.com
PORT=3000

# Optional security
API_KEY=your-secret-api-key
JWT_SECRET=your-jwt-secret
```

> Important: keep the `\n` newlines in the private key (or use a single line key with escaped newlines).

2. Install dependencies and start locally:

```bash
npm install
npm run dev
```

3. Test upload (example with curl):

```bash
curl -X POST http://localhost:3000/api/service/application \
  -H "x-api-key: your-secret-api-key" \
  -F "fullName=Jane Doe" \
  -F "email=jane@example.com" \
  -F "applicationId=APP-123" \
  -F "selectedService=Company Setup" \
  -F "visaCount=2" \
  -F "documents=@/path/passport.pdf" \
  -F "documentTypes=passport" \
  -F "documents=@/path/visa.png" \
  -F "documentTypes=visa"
```

## Security Features

### Rate Limiting
- **Global**: 100 requests per 15 minutes per IP
- **Application endpoint**: 10 submissions per hour per IP
- Configured in `src/middleware/rateLimiter.ts`

### API Key Authentication
- Set `API_KEY` env var to enable
- Client must send `x-api-key: <your-key>` header
- Middleware: `src/middleware/authMiddleware.ts`

### JWT Authentication
- Set `JWT_SECRET` env var
- Use `jwtAuth` middleware for token verification
- Client sends `Authorization: Bearer <token>` header
- Example: Replace `apiKeyAuth` with `jwtAuth` in route

### Request Validation
- Zod schema validates all request body fields
- Returns 400 with field-level errors on validation failure
- Schema: `src/schemas/serviceApplicationSchema.ts`

## Per-File Document Type

Frontend can provide document types via parallel array:

```bash
-F "documents=@passport.pdf" \
-F "documentTypes=passport" \
-F "documents=@visa.png" \
-F "documentTypes=visa"
```

Or comma-separated:
```bash
-F "documentTypes=passport,visa,noc"
```

If not provided, backend infers type from filename (passport, visa, noc, emirates-id).

## Data Model
- Collection: `service_applications`
- Document id: `applicationId` (if provided) or generated UUID
- Field `documents[]` contains metadata including `downloadURL` and `storagePath`

## Cloud Functions (Optional)

Located in `backend/functions/`:

1. **cleanupExpiredSignedUrls**: Scheduled daily to refresh signed URLs nearing 7-year expiry
2. **onApplicationCreated**: Firestore trigger for new applications (notifications, CRM integration)

Setup:
```bash
cd functions
npm install
firebase deploy --only functions
```

See `functions/README.md` for details.

## Notes
- File size limited to 10 MB each (configurable in router)
- Allowed types: pdf, jpeg, png, doc, docx
- Signed URLs are generated for long-lived read access (7 years)
- Multer upgraded to v2.x for better security and performance
