/**
 * HubSpot CRM Integration Service
 * 
 * This service handles creating contacts and deals in HubSpot CRM
 * when users complete payments for services.
 */

import * as logger from "firebase-functions/logger";
import axios from "axios";
import { HUBSPOT_API_KEY } from "../config";

// HubSpot API Configuration
const HUBSPOT_API_BASE = "https://api.hubapi.com";

/**
 * HubSpot Contact Properties
 */
interface HubSpotContact {
    email: string;
    firstname?: string;
    lastname?: string;
    phone?: string;
    company?: string;
    website?: string;
    // Custom properties
    service_purchased?: string;
    service_category?: string;
    amount_paid?: string;
    payment_date?: string;
    application_id?: string;
    document_count?: string;
    lead_source?: string;
}

/**
 * HubSpot Deal Properties
 */
interface HubSpotDeal {
    dealname: string;
    amount: string;
    dealstage: string;
    pipeline: string;
    closedate?: string;
    // Custom properties
    service_type?: string;
    payment_status?: string;
    application_id?: string;
}

/**
 * User data from WAZEET app
 */
export interface WazeetUserData {
    userId: string;
    email: string;
    displayName?: string;
    phoneNumber?: string;
    companyName?: string;
    serviceName: string;
    serviceCategory: string;
    amount: number;
    currency: string;
    applicationId: string;
    documentUrls?: string[];
    additionalInfo?: Record<string, any>;
}

/**
 * Create or update a contact in HubSpot
 */
export async function createOrUpdateHubSpotContact(
    userData: WazeetUserData
): Promise<string> {
    try {
        if (!HUBSPOT_API_KEY) {
            throw new Error("HubSpot API key not configured");
        }

        // Split display name into first and last name
        const nameParts = (userData.displayName || "").trim().split(" ");
        const firstname = nameParts[0] || "";
        const lastname = nameParts.slice(1).join(" ") || "";

        // Prepare contact properties
        const contactProperties: HubSpotContact = {
            email: userData.email,
            firstname,
            lastname,
            phone: userData.phoneNumber || "",
            company: userData.companyName || "",
            service_purchased: userData.serviceName,
            service_category: userData.serviceCategory,
            amount_paid: `${userData.amount} ${userData.currency}`,
            payment_date: new Date().toISOString(),
            application_id: userData.applicationId,
            document_count: (userData.documentUrls?.length || 0).toString(),
            lead_source: "WAZEET Mobile App",
        };

        // Create/update contact using email as unique identifier
        const response = await axios.post(
            `${HUBSPOT_API_BASE}/crm/v3/objects/contacts`,
            {
                properties: contactProperties,
            },
            {
                headers: {
                    Authorization: `Bearer ${HUBSPOT_API_KEY}`,
                    "Content-Type": "application/json",
                },
            }
        );

        const contactId = response.data.id;
        logger.info("HubSpot contact created/updated", {
            contactId,
            email: userData.email,
        });

        return contactId;
    } catch (error: any) {
        // If contact already exists, update it
        if (error.response?.status === 409) {
            return await updateExistingContact(userData);
        }

        logger.error("Error creating HubSpot contact", {
            error: error.message,
            response: error.response?.data,
        });
        throw error;
    }
}

/**
 * Update existing contact by email
 */
async function updateExistingContact(
    userData: WazeetUserData
): Promise<string> {
    try {
        // First, search for the contact by email
        const searchResponse = await axios.post(
            `${HUBSPOT_API_BASE}/crm/v3/objects/contacts/search`,
            {
                filterGroups: [
                    {
                        filters: [
                            {
                                propertyName: "email",
                                operator: "EQ",
                                value: userData.email,
                            },
                        ],
                    },
                ],
            },
            {
                headers: {
                    Authorization: `Bearer ${HUBSPOT_API_KEY}`,
                    "Content-Type": "application/json",
                },
            }
        );

        if (searchResponse.data.results.length === 0) {
            throw new Error("Contact not found for update");
        }

        const contactId = searchResponse.data.results[0].id;

        // Split display name
        const nameParts = (userData.displayName || "").trim().split(" ");
        const firstname = nameParts[0] || "";
        const lastname = nameParts.slice(1).join(" ") || "";

        // Update the contact
        const contactProperties: Partial<HubSpotContact> = {
            firstname,
            lastname,
            phone: userData.phoneNumber || "",
            company: userData.companyName || "",
            service_purchased: userData.serviceName,
            service_category: userData.serviceCategory,
            amount_paid: `${userData.amount} ${userData.currency}`,
            payment_date: new Date().toISOString(),
            application_id: userData.applicationId,
            document_count: (userData.documentUrls?.length || 0).toString(),
        };

        await axios.patch(
            `${HUBSPOT_API_BASE}/crm/v3/objects/contacts/${contactId}`,
            {
                properties: contactProperties,
            },
            {
                headers: {
                    Authorization: `Bearer ${HUBSPOT_API_KEY}`,
                    "Content-Type": "application/json",
                },
            }
        );

        logger.info("HubSpot contact updated", { contactId, email: userData.email });
        return contactId;
    } catch (error: any) {
        logger.error("Error updating HubSpot contact", {
            error: error.message,
            response: error.response?.data,
        });
        throw error;
    }
}

/**
 * Create a deal in HubSpot and associate it with a contact
 */
export async function createHubSpotDeal(
    contactId: string,
    userData: WazeetUserData
): Promise<string> {
    try {
        if (!HUBSPOT_API_KEY) {
            throw new Error("HubSpot API key not configured");
        }

        // Prepare deal properties
        const dealProperties: HubSpotDeal = {
            dealname: `${userData.serviceName} - ${userData.companyName || userData.email}`,
            amount: userData.amount.toString(),
            dealstage: "closedwon", // Since payment is completed
            pipeline: "default", // Use your HubSpot pipeline ID
            closedate: new Date().toISOString().split("T")[0],
            service_type: userData.serviceName,
            payment_status: "paid",
            application_id: userData.applicationId,
        };

        // Create deal
        const dealResponse = await axios.post(
            `${HUBSPOT_API_BASE}/crm/v3/objects/deals`,
            {
                properties: dealProperties,
            },
            {
                headers: {
                    Authorization: `Bearer ${HUBSPOT_API_KEY}`,
                    "Content-Type": "application/json",
                },
            }
        );

        const dealId = dealResponse.data.id;
        logger.info("HubSpot deal created", { dealId, contactId });

        // Associate deal with contact
        await associateDealWithContact(dealId, contactId);

        return dealId;
    } catch (error: any) {
        logger.error("Error creating HubSpot deal", {
            error: error.message,
            response: error.response?.data,
        });
        throw error;
    }
}

/**
 * Associate a deal with a contact
 */
async function associateDealWithContact(
    dealId: string,
    contactId: string
): Promise<void> {
    try {
        await axios.put(
            `${HUBSPOT_API_BASE}/crm/v3/objects/deals/${dealId}/associations/contacts/${contactId}/3`,
            {},
            {
                headers: {
                    Authorization: `Bearer ${HUBSPOT_API_KEY}`,
                    "Content-Type": "application/json",
                },
            }
        );

        logger.info("Deal associated with contact", { dealId, contactId });
    } catch (error: any) {
        logger.error("Error associating deal with contact", {
            error: error.message,
            response: error.response?.data,
        });
        throw error;
    }
}

/**
 * Add a note to a contact about the documents uploaded
 */
export async function addDocumentNoteToContact(
    contactId: string,
    documentUrls: string[]
): Promise<void> {
    try {
        if (!HUBSPOT_API_KEY || !documentUrls || documentUrls.length === 0) {
            return;
        }

        const noteContent = `
Documents uploaded by user:
${documentUrls.map((url, index) => `${index + 1}. ${url}`).join("\n")}

Total documents: ${documentUrls.length}
Upload date: ${new Date().toISOString()}
        `.trim();

        // Create an engagement (note) associated with the contact
        await axios.post(
            `${HUBSPOT_API_BASE}/crm/v3/objects/notes`,
            {
                properties: {
                    hs_note_body: noteContent,
                    hs_timestamp: new Date().getTime().toString(),
                },
                associations: [
                    {
                        to: {
                            id: contactId,
                        },
                        types: [
                            {
                                associationCategory: "HUBSPOT_DEFINED",
                                associationTypeId: 202, // Note to Contact association
                            },
                        ],
                    },
                ],
            },
            {
                headers: {
                    Authorization: `Bearer ${HUBSPOT_API_KEY}`,
                    "Content-Type": "application/json",
                },
            }
        );

        logger.info("Document note added to contact", {
            contactId,
            documentCount: documentUrls.length,
        });
    } catch (error: any) {
        logger.error("Error adding document note", {
            error: error.message,
            response: error.response?.data,
        });
        // Don't throw - note creation is not critical
    }
}

/**
 * Main function to sync payment data to HubSpot
 * This should be called after a successful payment
 */
export async function syncPaymentToHubSpot(
    userData: WazeetUserData
): Promise<{ contactId: string; dealId: string }> {
    try {
        logger.info("Starting HubSpot sync", {
            email: userData.email,
            applicationId: userData.applicationId,
        });

        // Step 1: Create or update contact
        const contactId = await createOrUpdateHubSpotContact(userData);

        // Step 2: Create deal
        const dealId = await createHubSpotDeal(contactId, userData);

        // Step 3: Add document note if documents were uploaded
        if (userData.documentUrls && userData.documentUrls.length > 0) {
            await addDocumentNoteToContact(contactId, userData.documentUrls);
        }

        logger.info("HubSpot sync completed successfully", {
            contactId,
            dealId,
            email: userData.email,
        });

        return { contactId, dealId };
    } catch (error: any) {
        logger.error("HubSpot sync failed", {
            error: error.message,
            email: userData.email,
            applicationId: userData.applicationId,
        });
        throw error;
    }
}
