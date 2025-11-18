import 'dotenv/config';
import admin from 'firebase-admin';
// Build credential from environment variables (no hard-coded secrets)
const projectId = process.env.FIREBASE_PROJECT_ID;
const clientEmail = process.env.FIREBASE_CLIENT_EMAIL;
let privateKey = process.env.FIREBASE_PRIVATE_KEY;
if (!projectId || !clientEmail || !privateKey) {
    throw new Error('Missing Firebase environment variables. Check FIREBASE_PROJECT_ID, FIREBASE_CLIENT_EMAIL, FIREBASE_PRIVATE_KEY');
}
// Fix escaped newlines if provided as single-line env var
privateKey = privateKey.replace(/\\n/g, '\n');
// Initialize Admin app only once (important for hot reload/dev)
if (admin.apps.length === 0) {
    admin.initializeApp({
        credential: admin.credential.cert({
            projectId,
            clientEmail,
            privateKey,
        }),
        storageBucket: process.env.FIREBASE_STORAGE_BUCKET,
    });
}
export const firestore = admin.firestore();
export const storage = admin.storage();
export const storageBucket = storage.bucket(process.env.FIREBASE_STORAGE_BUCKET);
export default admin;
