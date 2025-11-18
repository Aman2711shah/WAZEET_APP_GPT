import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';

admin.initializeApp();

const db = admin.firestore();
const storage = admin.storage();

/**
 * Scheduled function: Refresh signed URLs for documents nearing expiry
 * Runs daily at 2am UTC via Cloud Scheduler
 */
export const cleanupExpiredSignedUrls = functions.pubsub
    .schedule('0 2 * * *') // cron: every day at 2am
    .timeZone('UTC')
    .onRun(async (context) => {
        const now = new Date();
        const sixYearsAgo = new Date(now.getTime() - 1000 * 60 * 60 * 24 * 365 * 6);

        console.log(`Starting signed URL cleanup for documents older than ${sixYearsAgo.toISOString()}`);

        const snapshot = await db
            .collection('service_applications')
            .where('createdAt', '<=', sixYearsAgo)
            .get();

        if (snapshot.empty) {
            console.log('No documents found needing URL refresh.');
            return null;
        }

        const batch = db.batch();
        let refreshCount = 0;

        for (const doc of snapshot.docs) {
            const data = doc.data();
            const documents = data.documents || [];

            const refreshedDocs = await Promise.all(
                documents.map(async (docMeta: any) => {
                    try {
                        const bucket = storage.bucket();
                        const file = bucket.file(docMeta.storagePath);
                        // Re-generate signed URL for 7 years from now
                        const [newSignedUrl] = await file.getSignedUrl({
                            action: 'read',
                            expires: new Date(now.getTime() + 1000 * 60 * 60 * 24 * 365 * 7),
                        });
                        return { ...docMeta, downloadURL: newSignedUrl };
                    } catch (err: any) {
                        console.error(`Failed to refresh URL for ${docMeta.storagePath}:`, err.message);
                        return docMeta; // keep old URL if refresh fails
                    }
                })
            );

            batch.update(doc.ref, { documents: refreshedDocs, updatedAt: admin.firestore.FieldValue.serverTimestamp() });
            refreshCount++;
        }

        await batch.commit();
        console.log(`Refreshed signed URLs for ${refreshCount} application(s).`);
        return null;
    });

/**
 * Firestore trigger: On new service application creation
 * Example: Send notification, log analytics, integrate with CRM
 */
export const onApplicationCreated = functions.firestore
    .document('service_applications/{applicationId}')
    .onCreate(async (snapshot, context) => {
        const data = snapshot.data();
        const applicationId = context.params.applicationId;

        console.log(`New service application created: ${applicationId}`);
        console.log(`Service: ${data.selectedService}, Email: ${data.email}`);

        // Example: Send email notification, update CRM, log to analytics, etc.
        // await sendEmailNotification(data.email, applicationId);

        return null;
    });
