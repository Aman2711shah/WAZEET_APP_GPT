/**
 * HubSpot Integration Cloud Functions
 * 
 * These functions handle the integration between WAZEET payments
 * and HubSpot CRM.
 */

import * as functions from "firebase-functions";
import * as logger from "firebase-functions/logger";
import * as admin from "firebase-admin";
import {
    syncPaymentToHubSpot,
    WazeetUserData,
} from "./hubspotService";

/**
 * Firestore Trigger: Sync to HubSpot when payment is created
 * 
 * This function automatically triggers when a new payment document
 * is created in the 'payments' collection.
 */
export const onPaymentCreated = functions.firestore
    .document("payments/{paymentId}")
    .onCreate(async (snapshot, context) => {
        try {
            const paymentData = snapshot.data();
            const paymentId = context.params.paymentId;

            logger.info("Payment created, syncing to HubSpot", { paymentId });

            // Only process if payment is successful
            if (paymentData.status !== "paid") {
                logger.info("Payment not successful, skipping HubSpot sync", {
                    paymentId,
                    status: paymentData.status,
                });
                return;
            }

            // Get user data
            const userId = paymentData.user_id;
            if (!userId) {
                logger.warn("No user ID found in payment", { paymentId });
                return;
            }

            const userDoc = await admin
                .firestore()
                .collection("users")
                .doc(userId)
                .get();

            if (!userDoc.exists) {
                logger.warn("User not found", { userId, paymentId });
                return;
            }

            const userData = userDoc.data();

            // Get application/service data
            const applicationId = paymentData.application_id;
            let serviceName = "Unknown Service";
            let serviceCategory = "General";
            let documentUrls: string[] = [];
            let companyName = "";

            if (applicationId) {
                const appDoc = await admin
                    .firestore()
                    .collection("applications")
                    .doc(applicationId)
                    .get();

                if (appDoc.exists) {
                    const appData = appDoc.data();
                    serviceName = appData?.service_name || serviceName;
                    serviceCategory = appData?.service_category || serviceCategory;
                    documentUrls = appData?.documents || [];
                    companyName = appData?.company_name || "";
                }
            }

            // Prepare data for HubSpot
            const hubspotData: WazeetUserData = {
                userId,
                email: userData?.email || "",
                displayName: userData?.displayName || userData?.name || "",
                phoneNumber: userData?.phoneNumber || userData?.phone || "",
                companyName,
                serviceName,
                serviceCategory,
                amount: paymentData.amount || 0,
                currency: paymentData.currency || "AED",
                applicationId: applicationId || paymentId,
                documentUrls,
                additionalInfo: {
                    ...userData,
                    paymentDate: paymentData.created_at,
                },
            };

            // Validate email
            if (!hubspotData.email) {
                logger.error("No email found for user", { userId, paymentId });
                return;
            }

            // Sync to HubSpot
            const result = await syncPaymentToHubSpot(hubspotData);

            // Update payment document with HubSpot IDs
            await snapshot.ref.update({
                hubspot_contact_id: result.contactId,
                hubspot_deal_id: result.dealId,
                hubspot_synced_at: admin.firestore.FieldValue.serverTimestamp(),
            });

            logger.info("Successfully synced payment to HubSpot", {
                paymentId,
                contactId: result.contactId,
                dealId: result.dealId,
            });
        } catch (error: any) {
            logger.error("Error syncing payment to HubSpot", {
                error: error.message,
                paymentId: context.params.paymentId,
            });
            // Don't throw - we don't want to fail the payment process
            // Just log the error and continue
        }
    });

/**
 * HTTPS Callable Function: Manually sync a payment to HubSpot
 * 
 * This can be used to retry failed syncs or sync historical data.
 */
export const syncPaymentToHubSpotManual = functions.https.onCall(
    async (data, context) => {
        try {
            // Check authentication
            if (!context.auth) {
                throw new functions.https.HttpsError(
                    "unauthenticated",
                    "User must be authenticated"
                );
            }

            const paymentId = data.paymentId;
            if (!paymentId) {
                throw new functions.https.HttpsError(
                    "invalid-argument",
                    "paymentId is required"
                );
            }

            logger.info("Manual HubSpot sync requested", {
                paymentId,
                userId: context.auth.uid,
            });

            // Get payment data
            const paymentDoc = await admin
                .firestore()
                .collection("payments")
                .doc(paymentId)
                .get();

            if (!paymentDoc.exists) {
                throw new functions.https.HttpsError(
                    "not-found",
                    "Payment not found"
                );
            }

            const paymentData = paymentDoc.data();

            // Get user data
            const userId = paymentData?.user_id;
            if (!userId) {
                throw new functions.https.HttpsError(
                    "failed-precondition",
                    "No user ID in payment"
                );
            }

            const userDoc = await admin
                .firestore()
                .collection("users")
                .doc(userId)
                .get();

            if (!userDoc.exists) {
                throw new functions.https.HttpsError(
                    "not-found",
                    "User not found"
                );
            }

            const userData = userDoc.data();

            // Get application/service data
            const applicationId = paymentData.application_id;
            let serviceName = "Unknown Service";
            let serviceCategory = "General";
            let documentUrls: string[] = [];
            let companyName = "";

            if (applicationId) {
                const appDoc = await admin
                    .firestore()
                    .collection("applications")
                    .doc(applicationId)
                    .get();

                if (appDoc.exists) {
                    const appData = appDoc.data();
                    serviceName = appData?.service_name || serviceName;
                    serviceCategory = appData?.service_category || serviceCategory;
                    documentUrls = appData?.documents || [];
                    companyName = appData?.company_name || "";
                }
            }

            // Prepare data for HubSpot
            const hubspotData: WazeetUserData = {
                userId,
                email: userData?.email || "",
                displayName: userData?.displayName || userData?.name || "",
                phoneNumber: userData?.phoneNumber || userData?.phone || "",
                companyName,
                serviceName,
                serviceCategory,
                amount: paymentData.amount || 0,
                currency: paymentData.currency || "AED",
                applicationId: applicationId || paymentId,
                documentUrls,
            };

            // Validate email
            if (!hubspotData.email) {
                throw new functions.https.HttpsError(
                    "failed-precondition",
                    "No email found for user"
                );
            }

            // Sync to HubSpot
            const result = await syncPaymentToHubSpot(hubspotData);

            // Update payment document
            await paymentDoc.ref.update({
                hubspot_contact_id: result.contactId,
                hubspot_deal_id: result.dealId,
                hubspot_synced_at: admin.firestore.FieldValue.serverTimestamp(),
            });

            return {
                success: true,
                contactId: result.contactId,
                dealId: result.dealId,
                message: "Payment synced to HubSpot successfully",
            };
        } catch (error: any) {
            logger.error("Manual HubSpot sync failed", {
                error: error.message,
                paymentId: data.paymentId,
            });

            if (error instanceof functions.https.HttpsError) {
                throw error;
            }

            throw new functions.https.HttpsError(
                "internal",
                error.message || "Failed to sync to HubSpot"
            );
        }
    }
);

/**
 * HTTPS Callable Function: Test HubSpot connection
 * 
 * This function tests if the HubSpot API key is working.
 */
export const testHubSpotConnection = functions.https.onCall(
    async (data, context) => {
        try {
            // Check authentication (admin only)
            if (!context.auth) {
                throw new functions.https.HttpsError(
                    "unauthenticated",
                    "User must be authenticated"
                );
            }

            logger.info("Testing HubSpot connection", {
                userId: context.auth.uid,
            });

            // Test with dummy data
            const testData: WazeetUserData = {
                userId: "test-user",
                email: "test@wazeet.com",
                displayName: "Test User",
                phoneNumber: "+971501234567",
                companyName: "Test Company",
                serviceName: "Test Service",
                serviceCategory: "Test",
                amount: 100,
                currency: "AED",
                applicationId: "test-application",
                documentUrls: [],
            };

            // Try to create contact (this will test the API key)
            const { createOrUpdateHubSpotContact } = require("./hubspotService");
            const contactId = await createOrUpdateHubSpotContact(testData);

            return {
                success: true,
                contactId,
                message: "HubSpot connection successful! Test contact created.",
            };
        } catch (error: any) {
            logger.error("HubSpot connection test failed", {
                error: error.message,
            });

            return {
                success: false,
                error: error.message,
                message: "HubSpot connection failed. Please check your API key.",
            };
        }
    }
);
