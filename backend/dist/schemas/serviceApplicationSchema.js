import { z } from 'zod';
/**
 * Zod schema for validating service application request body
 * Matches ServiceApplicationPayload interface
 */
export const serviceApplicationSchema = z.object({
    applicationId: z.string().optional(),
    fullName: z.string().min(1, 'Full name is required'),
    email: z.string().email('Invalid email format'),
    phone: z.string().optional(),
    whatsappNumber: z.string().optional(),
    nationality: z.string().optional(),
    currentCountry: z.string().optional(),
    residentInUAE: z
        .string()
        .transform((val) => val.toLowerCase() === 'true')
        .pipe(z.boolean())
        .optional(),
    selectedService: z.string().min(1, 'Selected service is required'),
    selectedFreezone: z.string().optional(),
    licenseType: z.string().optional(),
    businessActivity: z.string().optional(),
    visaCount: z
        .string()
        .transform((val) => (val ? Number(val) : undefined))
        .pipe(z.number().int().nonnegative().optional())
        .optional(),
    packageName: z.string().optional(),
    packagePrice: z
        .string()
        .transform((val) => (val ? Number(val) : undefined))
        .pipe(z.number().nonnegative().optional())
        .optional(),
    tenureYears: z
        .string()
        .transform((val) => (val ? Number(val) : undefined))
        .pipe(z.number().int().positive().optional())
        .optional(),
    leadSource: z.string().optional(),
    notes: z.string().optional(),
});
