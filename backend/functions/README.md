# Cloud Functions for Service Applications

Optional serverless functions for Firebase hosting and scheduled tasks.

## Setup

1. Init Firebase Functions (skip if already initialized):
   ```bash
   firebase init functions
   ```

2. Install dependencies in `functions/`:
   ```bash
   cd functions
   npm install
   ```

3. Deploy:
   ```bash
   firebase deploy --only functions
   ```

## Available Functions

### 1. `cleanupExpiredSignedUrls` (Scheduled)
- **Trigger**: Cloud Scheduler (cron: daily at 2am)
- **Purpose**: Re-generate signed URLs for documents older than 6 years to prevent expiry
- **Usage**: Automatically runs; no manual invocation needed

### 2. `onApplicationCreated` (Firestore Trigger)
- **Trigger**: When a new document is created in `service_applications`
- **Purpose**: Send notification email, log analytics, etc.
- **Usage**: Automatically triggered on write

## Notes

- Signed URLs generated for 7 years; this function refreshes them before expiry
- Adjust cron schedule in `functions/src/index.ts` as needed
- Ensure Firebase project has Firestore and Cloud Scheduler enabled
