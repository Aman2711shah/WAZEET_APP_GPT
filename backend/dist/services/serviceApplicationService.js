import admin, { firestore, storageBucket } from '../firebase.js';
import { generateRequestId } from '../utils/requestId.js';
import path from 'node:path';
import 'multer';
function sanitizeFilename(name) {
    return name
        .normalize('NFKD')
        .replace(/[\u0300-\u036f]/g, '') // strip accents
        .replace(/[^a-zA-Z0-9._-]+/g, '-') // keep safe chars
        .replace(/-{2,}/g, '-')
        .replace(/^[-.]+|[-.]+$/g, '')
        .toLowerCase();
}
function inferDocumentType(originalName) {
    const lower = originalName.toLowerCase();
    if (lower.includes('passport'))
        return 'passport';
    if (lower.includes('visa'))
        return 'visa';
    if (lower.includes('noc'))
        return 'noc';
    if (lower.includes('emirates'))
        return 'emirates-id';
    return null;
}
export async function saveServiceApplicationToFirebase(payload, files) {
    // Prefer incoming applicationId; otherwise generate standardized request ID
    const appId = payload.applicationId && payload.applicationId.trim() !== ''
        ? payload.applicationId.trim()
        : generateRequestId();
    const now = new Date();
    const uploadedDocs = [];
    // Upload files (if any) to Firebase Storage and collect metadata
    for (const file of files || []) {
        const safeName = sanitizeFilename(file.originalname || 'document');
        const timestamp = Date.now();
        const storagePath = path.posix.join('service_applications', appId, `${timestamp}-${safeName}`);
        const gcsFile = storageBucket.file(storagePath);
        // Save from buffer (multer memory storage)
        await gcsFile.save(file.buffer, {
            metadata: {
                contentType: file.mimetype,
            },
            resumable: false,
            validation: 'crc32c',
        });
        // Generate a signed URL for download (valid for 7 years approx.)
        const [signedUrl] = await gcsFile.getSignedUrl({
            action: 'read',
            // 7 years in the future
            expires: new Date(now.getTime() + 1000 * 60 * 60 * 24 * 365 * 7),
        });
        uploadedDocs.push({
            // Prefer explicit documentType from frontend; fallback to inference
            documentType: file.documentType || inferDocumentType(file.originalname),
            originalName: file.originalname,
            storagePath,
            downloadURL: signedUrl,
            mimeType: file.mimetype,
            sizeBytes: file.size,
            uploadedAt: admin.firestore.FieldValue.serverTimestamp(),
        });
    }
    const appDoc = {
        applicationId: appId,
        fullName: payload.fullName,
        email: payload.email,
        phone: payload.phone || '',
        whatsappNumber: payload.whatsappNumber || '',
        nationality: payload.nationality || '',
        currentCountry: payload.currentCountry || '',
        residentInUAE: Boolean(payload.residentInUAE),
        selectedService: payload.selectedService,
        selectedFreezone: payload.selectedFreezone || '',
        licenseType: payload.licenseType || '',
        businessActivity: payload.businessActivity || '',
        visaCount: payload.visaCount ?? null,
        packageName: payload.packageName || '',
        packagePrice: payload.packagePrice ?? null,
        tenureYears: payload.tenureYears ?? null,
        leadSource: payload.leadSource || '',
        notes: payload.notes || '',
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
        documents: uploadedDocs,
    };
    // Create or set document
    const col = firestore.collection('service_applications');
    const docRef = col.doc(appId);
    await docRef.set(appDoc, { merge: true });
    return { firestoreDocId: docRef.id, documents: uploadedDocs, applicationId: appId };
}
