import type { Timestamp } from 'firebase-admin/firestore';

export interface ServiceApplicationPayload {
    applicationId?: string;
    fullName: string;
    email: string;
    phone?: string;
    whatsappNumber?: string;
    nationality?: string;
    currentCountry?: string;
    residentInUAE?: boolean;
    selectedService: string;
    selectedFreezone?: string;
    licenseType?: string;
    businessActivity?: string;
    visaCount?: number;
    packageName?: string;
    packagePrice?: number;
    tenureYears?: number;
    leadSource?: string;
    notes?: string;
}

export interface SavedDocumentInfo {
    documentType: string | null;
    originalName: string;
    storagePath: string;
    downloadURL: string;
    mimeType: string;
    sizeBytes: number;
    uploadedAt: Timestamp;
}
