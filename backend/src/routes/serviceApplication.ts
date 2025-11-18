import express from 'express';
import multer from 'multer';
import { saveServiceApplicationToFirebase } from '../services/serviceApplicationService.js';
import { serviceApplicationSchema } from '../schemas/serviceApplicationSchema.js';
import { applicationLimiter } from '../middleware/rateLimiter.js';
import { apiKeyAuth } from '../middleware/authMiddleware.js';
import type { ServiceApplicationPayload } from '../types/serviceApplication.js';

const router = express.Router();

// Multer setup: memory storage so we can upload buffers directly
// Note: multer v2.x no longer supports fileFilter in constructor; moved to field-level
const upload = multer({
    storage: multer.memoryStorage(),
    limits: { fileSize: 10 * 1024 * 1024 }, // 10 MB per file
});

// Accept documents[] array with optional documentType[] parallel array
const uploadMiddleware = upload.fields([
    { name: 'documents', maxCount: 20 },
    { name: 'documentTypes', maxCount: 20 }, // optional parallel array
]);

router.post(
    '/application',
    applicationLimiter,
    apiKeyAuth, // optional: enable API key auth if API_KEY env is set
    uploadMiddleware,
    async (req, res) => {
        try {
            // Validate with zod
            const validationResult = serviceApplicationSchema.safeParse(req.body);
            if (!validationResult.success) {
                return res.status(400).json({
                    success: false,
                    message: 'Validation error',
                    errors: validationResult.error.flatten().fieldErrors,
                });
            }

            const payload: ServiceApplicationPayload = validationResult.data as any;

            // Extract files and documentTypes
            const filesMap = req.files as { [fieldname: string]: Express.Multer.File[] } | undefined;
            const uploadedFiles = filesMap?.documents || [];
            const documentTypesRaw = req.body.documentTypes; // could be array or single string

            // Parse documentTypes into array (handle comma-separated or array)
            let documentTypes: (string | null)[] = [];
            if (Array.isArray(documentTypesRaw)) {
                documentTypes = documentTypesRaw.map((t) => (t && String(t).trim() !== '' ? String(t) : null));
            } else if (typeof documentTypesRaw === 'string' && documentTypesRaw.trim() !== '') {
                documentTypes = documentTypesRaw.split(',').map((t) => (t.trim() !== '' ? t.trim() : null));
            }

            // Validate allowed MIME types
            const allowedMimeTypes = new Set([
                'application/pdf',
                'image/jpeg',
                'image/png',
                'application/msword',
                'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
            ]);

            for (const file of uploadedFiles) {
                if (!allowedMimeTypes.has(file.mimetype)) {
                    return res.status(400).json({
                        success: false,
                        message: `Unsupported file type: ${file.mimetype}`,
                    });
                }
            }

            // Build array of files with documentType
            const filesWithTypes = uploadedFiles.map((f, index) => ({
                originalname: f.originalname,
                buffer: f.buffer,
                mimetype: f.mimetype,
                size: f.size,
                documentType: documentTypes[index] || null,
            }));

            const { firestoreDocId, documents, applicationId } = await saveServiceApplicationToFirebase(
                payload,
                filesWithTypes
            );

            return res.status(201).json({
                success: true,
                message: 'Service application stored in Firebase.',
                applicationId,
                firestoreDocId,
                documents: documents.map((d) => ({
                    documentType: d.documentType,
                    originalName: d.originalName,
                    downloadURL: d.downloadURL,
                    storagePath: d.storagePath,
                    sizeBytes: d.sizeBytes,
                })),
            });
        } catch (err: any) {
            console.error('Error storing service application:', err?.message || err);
            return res.status(500).json({
                success: false,
                message: 'Failed to store service application.',
                errorCode: err?.code || undefined,
                details: err?.message || 'Unknown error',
            });
        }
    }
);

export default router;
