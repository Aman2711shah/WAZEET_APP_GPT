
/* eslint-disable */
// Load environment variables from .env file (for local development)
import * as dotenv from "dotenv";
dotenv.config();

import * as functions from "firebase-functions";
import * as logger from "firebase-functions/logger";
import * as admin from "firebase-admin";

// Initialize Firebase Admin FIRST (before other imports that use it)
admin.initializeApp();

import { findBestPackages } from "./quotes";
import { FinderInput, FreezonePackage } from "./types";
import { discoverEventsWithOpenAI, validateEvent } from "./event-discovery";
// AI Tax Explain function
export { aiTaxExplain } from "./aiTaxExplain";

// Export AI Business Chat function
export { aiBusinessChat } from "./aiBusinessChat";

// Export Account Management functions
export { exportUserData } from "./account/exportUserData";
export { deleteUserData } from "./account/deleteUserData";

// Export Community functions
export {
    communityFetchHashtags,
    communityFetchNews,
    communityFetchEvents,
} from "./community/googleCommunity";

// Export HubSpot CRM integration functions
export {
    onPaymentCreated,
    syncPaymentToHubSpotManual,
    testHubSpotConnection,
} from "./hubspot/index";

/**
 * HTTPS Callable endpoint
 * name: findBestFreezonePackages
 * request: { input: FinderInput, catalog?: FreezonePackage[] }
 * response: { results: RankedPackage[] }
 * 
 * In production, remove `catalog` from the request and load packages from Firestore.
 */
export const findBestFreezonePackages = functions.https.onCall(async (data, context) => {
    try {
        const input = (data?.input || {}) as FinderInput;
        const catalog = (data?.catalog || []) as FreezonePackage[];

        if (typeof input.activities !== "number" || typeof input.visas !== "number") {
            throw new functions.https.HttpsError("invalid-argument", "activities and visas are required numbers");
        }
        if (!Array.isArray(catalog) || catalog.length === 0) {
            logger.warn("No catalog provided; returning empty results. In prod, fetch from Firestore.");
            return { results: [] };
        }
        const results = findBestPackages(input, catalog);
        return { results };
    } catch (err: any) {
        logger.error("findBestFreezonePackages error", err);
        throw new functions.https.HttpsError("internal", err?.message || "Unknown error");
    }
});

/**
 * HTTPS Callable endpoint to manually trigger event discovery
 * name: triggerEventDiscovery
 * request: { searchQuery?: string }
 * response: { success: boolean, eventsFound: number, message: string }
 */
export const triggerEventDiscovery = functions.https.onCall(async (data, context) => {
    try {
        // Check if user is authenticated
        if (!context.auth) {
            throw new functions.https.HttpsError("unauthenticated", "User must be authenticated");
        }

        logger.info("Manual event discovery triggered", { userId: context.auth.uid });

        const searchQuery = data?.searchQuery || "Dubai business networking events";

        // Discover events with retry logic
        const events = await discoverEventsWithOpenAI(searchQuery);

        if (events.length === 0) {
            return {
                success: true,
                eventsFound: 0,
                message: "No events discovered"
            };
        }

        // Save events to Firestore
        const db = admin.firestore();
        const batch = db.batch();
        let savedCount = 0;

        for (const event of events) {
            if (validateEvent(event)) {
                // Create a unique ID based on event name and date
                const eventId = `${event.eventName.toLowerCase().replace(/\s+/g, '-')}-${event.date}`;
                const eventRef = db.collection('discoveredEvents').doc(eventId);

                batch.set(eventRef, {
                    ...event,
                    attendees: event.attendees || 0,
                    createdAt: admin.firestore.FieldValue.serverTimestamp(),
                    updatedAt: admin.firestore.FieldValue.serverTimestamp()
                }, { merge: true });

                savedCount++;
            }
        }

        await batch.commit();

        logger.info(`Successfully saved ${savedCount} events to Firestore`);

        return {
            success: true,
            eventsFound: savedCount,
            message: `Successfully discovered and saved ${savedCount} events`
        };

    } catch (err: any) {
        logger.error("triggerEventDiscovery error", err);
        throw new functions.https.HttpsError("internal", err?.message || "Event discovery failed");
    }
});

/**
 * Scheduled function to automatically discover events daily
 * Runs every day at 3 AM UTC
 */
export const scheduledEventDiscovery = functions.pubsub.schedule("0 3 * * *")
    .timeZone("UTC")
    .onRun(async (context) => {
        try {
            logger.info("Scheduled event discovery started");

            const searchQuery = "Dubai business networking events workshops conferences";

            // Discover events with retry logic
            const events = await discoverEventsWithOpenAI(searchQuery);

            if (events.length === 0) {
                logger.warn("No events discovered in scheduled run");
                return;
            }

            // Save events to Firestore
            const db = admin.firestore();
            const batch = db.batch();
            let savedCount = 0;

            for (const eventData of events) {
                if (validateEvent(eventData)) {
                    // Create a unique ID based on event name and date
                    const eventId = `${eventData.eventName.toLowerCase().replace(/\s+/g, '-')}-${eventData.date}`;
                    const eventRef = db.collection('discoveredEvents').doc(eventId);

                    batch.set(eventRef, {
                        ...eventData,
                        attendees: eventData.attendees || 0,
                        createdAt: admin.firestore.FieldValue.serverTimestamp(),
                        updatedAt: admin.firestore.FieldValue.serverTimestamp()
                    }, { merge: true });

                    savedCount++;
                }
            }

            await batch.commit();

            logger.info(`Scheduled event discovery completed. Saved ${savedCount} events.`);

        } catch (err: any) {
            logger.error("scheduledEventDiscovery error", err);
            // Don't throw - just log the error so the function completes
        }
    });
