import express from 'express';
import multer from 'multer';
import mime from 'mime-types';
import { saveServiceApplicationToFirebase } from '../services/serviceApplicationService.js';
import type { ServiceApplicationPayload } from '../types/serviceApplication.js';

const router = express.Router();

// Multer setup: memory storage so we can upload buffers directly
const upload = multer({
    storage: multer.memoryStorage(),
    limits: { fileSize: 10 * 1024 * 1024, files: 20 }, // 10 MB, up to 20 docs
    fileFilter: (_req, file, cb) => {
        const allowed = new Set([
            'application/pdf',
            'image/jpeg',
            'image/png',
            'application/msword',
            'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
        ]);
        if (allowed.has(file.mimetype)) cb(null, true);
        else cb(new Error('Unsupported file type: ' + file.mimetype));
    },
});

router.post('/application', upload.array('documents'), async (req, res) => {
    try {
        const body = req.body as Record<string, any>;

        // Required validation
        const required = ['fullName', 'email', 'selectedService'];
        for (const key of required) {
            if (!body[key]) {
                return res.status(400).json({
                    success: false,
                    message: `Missing required field: ${key}`,
                });
            }
        }

        const payload: ServiceApplicationPayload = {
            applicationId: body.applicationId,
            fullName: String(body.fullName),
            email: String(body.email),
            phone: body.phone,
            whatsappNumber: body.whatsappNumber,
            nationality: body.nationality,
            currentCountry: body.currentCountry,
            residentInUAE: String(body.residentInUAE).toLowerCase() === 'true',
            selectedService: String(body.selectedService),
            selectedFreezone: body.selectedFreezone,
            licenseType: body.licenseType,
            businessActivity: body.businessActivity,
            visaCount: body.visaCount ? Number(body.visaCount) : undefined,
            packageName: body.packageName,
            packagePrice: body.packagePrice ? Number(body.packagePrice) : undefined,
            tenureYears: body.tenureYears ? Number(body.tenureYears) : undefined,
            leadSource: body.leadSource,
            notes: body.notes,
        };

        const files = (req.files as Express.Multer.File[] | undefined) || [];
        // Map to simplified MulterFile used by our service
        const simpleFiles = files.map((f) => ({
            originalname: f.originalname,
            buffer: f.buffer,
            mimetype: f.mimetype,
            size: f.size,
        }));

        const { firestoreDocId, documents, applicationId } =
            await saveServiceApplicationToFirebase(payload, simpleFiles);

        return res.status(201).json({
            success: true,
            message: 'Service application stored in Firebase.',
            applicationId,
            firestoreDocId,
            documents: documents.map((d) => ({
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
});

export default router;
