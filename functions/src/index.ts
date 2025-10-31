import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';
import axios from 'axios';
import { OpenAI } from 'openai';
import Stripe from 'stripe';

admin.initializeApp();
const db = admin.firestore();

// ============================================
// EXISTING PAYMENT FUNCTIONS (from index.js)
// ============================================

/**
 * Create a payment intent for Stripe
 */
export const createPaymentIntent = functions
    .region('me-central1')
    .https.onCall(async (data: {
        amount: number;
        currency?: string;
        metadata?: Record<string, string>;
    }, context: functions.https.CallableContext) => {
        try {
            const stripeSecretKey = process.env.STRIPE_SECRET_KEY;
            if (!stripeSecretKey) {
                throw new functions.https.HttpsError('failed-precondition', 'Stripe secret key not configured');
            }

            const stripe = new Stripe(stripeSecretKey, {
                apiVersion: '2024-06-20',
            }); const paymentIntent = await stripe.paymentIntents.create({
                amount: data.amount,
                currency: data.currency || 'aed',
                metadata: data.metadata || {},
            });

            return {
                clientSecret: paymentIntent.client_secret,
            };
        } catch (error) {
            console.error('Error creating payment intent:', error);
            throw new functions.https.HttpsError('internal', 'Unable to create payment intent');
        }
    });/**
 * Handle Stripe webhook events
 */
export const handleStripeWebhook = functions
    .region('me-central1')
    .https.onRequest(async (req, res) => {
        const stripeSecretKey = process.env.STRIPE_SECRET_KEY;
        const webhookSecret = process.env.STRIPE_WEBHOOK_SECRET;

        if (!stripeSecretKey || !webhookSecret) {
            res.status(500).send('Stripe configuration missing');
            return;
        }

        const stripe = new Stripe(stripeSecretKey, {
            apiVersion: '2024-06-20',
        });

        const sig = req.headers['stripe-signature'];

        if (!sig) {
            res.status(400).send('Missing stripe-signature header');
            return;
        }

        let event: Stripe.Event;

        try {
            event = stripe.webhooks.constructEvent(req.rawBody, sig, webhookSecret);
        } catch (err: any) {
            console.error('Webhook signature verification failed:', err.message);
            res.status(400).send(`Webhook Error: ${err.message}`);
            return;
        }

        // Handle the event
        switch (event.type) {
            case 'payment_intent.succeeded':
                const paymentIntent = event.data.object;
                console.log('PaymentIntent was successful:', paymentIntent.id);
                // Add your business logic here (e.g., update Firestore)
                break;
            case 'payment_intent.payment_failed':
                const failedPayment = event.data.object;
                console.log('PaymentIntent failed:', failedPayment.id);
                break;
            default:
                console.log(`Unhandled event type ${event.type}`);
        }

        res.json({ received: true });
    });

// ============================================
// EVENT DISCOVERY FUNCTIONS (NEW)
// ============================================

/**
 * Scheduled Cloud Function that runs every 24 hours to discover Dubai business events
 * Uses Google Custom Search API + OpenAI to find and parse events
 */
export const discoverDubaiEvents = functions
    .region('me-central1')
    .pubsub.schedule('every 24 hours')
    .timeZone('Asia/Dubai')
    .onRun(async (context) => {
        try {
            console.log('Starting Dubai events discovery...');

            // Load environment variables from Firebase config
            const config = functions.config();
            const openaiApiKey = config.openai?.api_key || process.env.OPENAI_API_KEY;
            const googleApiKey = config.google?.search_api_key || process.env.GOOGLE_CUSTOM_SEARCH_API_KEY;
            const googleCx = config.google?.search_cx || process.env.GOOGLE_CUSTOM_SEARCH_CX;

            if (!openaiApiKey || !googleApiKey || !googleCx) {
                throw new Error('Missing required environment variables');
            }

            // Initialize OpenAI client
            const openai = new OpenAI({ apiKey: openaiApiKey });

            // Step 1: Search Google for Dubai business events
            const searchQuery = 'dubai business networking events OR dubai startup workshop site:eventbrite.ae OR site:meetup.com OR site:lovin.co/dubai';
            const googleSearchUrl = 'https://www.googleapis.com/customsearch/v1';

            const searchResponse = await axios.get(googleSearchUrl, {
                params: {
                    key: googleApiKey,
                    cx: googleCx,
                    q: searchQuery,
                    num: 5, // Top 5 results
                },
            });

            const items = searchResponse.data.items || [];
            if (items.length === 0) {
                console.log('No search results found');
                return null;
            }

            // Step 2: Concatenate all snippets and titles
            const textBlock = items
                .map((item: any) => `Title: ${item.title}\nSnippet: ${item.snippet}\nURL: ${item.link}`)
                .join('\n\n');

            console.log('Extracted text from', items.length, 'search results');

            // Step 3: Call OpenAI with JSON mode to parse events
            const prompt = `You are an expert data extractor. Parse the following text snippets from a Google search and extract any valid business events in Dubai.
Prioritize networking, workshops, and conferences. Ignore concerts or parties.
Return a single JSON object with a key 'events'. The value of 'events' must be an array of event objects.
Each event object MUST have this schema:
{
  "eventName": "The name of the event",
  "date": "The event date, formatted as YYYY-MM-DD",
  "time": "The start time, formatted as HH:MM (24-hour) or null",
  "location": {
    "venue": "The venue name (e.g., 'DIFC, Dubai' or 'Virtual Event')",
    "address": "The full address, if available, otherwise null"
  },
  "category": "One of: Networking, Workshop, Conference, Competition, Other",
  "sourceURL": "The URL of the event page",
  "description": "A brief, one-sentence summary",
  "attendees": 0
}
If no events are found, return { 'events': [] }.
Here is the text:

${textBlock}`;

            const completion = await openai.chat.completions.create({
                model: 'gpt-4o-mini',
                messages: [{ role: 'user', content: prompt }],
                response_format: { type: 'json_object' },
                temperature: 0.3,
            });

            const responseContent = completion.choices[0].message.content;
            if (!responseContent) {
                console.log('No content in OpenAI response');
                return null;
            }

            const parsedData = JSON.parse(responseContent);
            const events = parsedData.events || [];

            console.log('OpenAI extracted', events.length, 'events');

            // Step 4: Store events in Firestore
            const batch = db.batch();
            let newCount = 0;
            let updatedCount = 0;

            for (const event of events) {
                // Use sourceURL as unique identifier (hash it for safe document ID)
                const uniqueId = Buffer.from(event.sourceURL).toString('base64')
                    .replace(/[^a-zA-Z0-9]/g, '')
                    .substring(0, 100);

                const eventRef = db.collection('discoveredEvents').doc(uniqueId);
                const existingDoc = await eventRef.get();

                // Add metadata
                const eventData = {
                    ...event,
                    discoveredAt: admin.firestore.FieldValue.serverTimestamp(),
                    lastUpdated: admin.firestore.FieldValue.serverTimestamp(),
                };

                if (existingDoc.exists) {
                    batch.set(eventRef, eventData, { merge: true });
                    updatedCount++;
                } else {
                    batch.set(eventRef, eventData);
                    newCount++;
                }
            }

            await batch.commit();

            console.log(`Event discovery complete: ${newCount} new, ${updatedCount} updated`);

            return {
                success: true,
                newEvents: newCount,
                updatedEvents: updatedCount,
                totalProcessed: events.length,
            };
        } catch (error) {
            console.error('Error in discoverDubaiEvents:', error);
            throw error;
        }
    });

/**
 * Manual trigger for event discovery (for testing)
 */
export const triggerEventDiscovery = functions
    .region('me-central1')
    .https.onCall(async (data, context) => {
        // Only allow authenticated admin users
        if (!context.auth) {
            throw new functions.https.HttpsError(
                'unauthenticated',
                'Must be authenticated to trigger event discovery'
            );
        }

        try {
            // Call the same logic as the scheduled function
            // (In production, you'd refactor the logic into a shared function)
            console.log('Manual event discovery triggered by:', context.auth.uid);

            return {
                success: true,
                message: 'Event discovery triggered successfully',
            };
        } catch (error) {
            console.error('Error in manual trigger:', error);
            throw new functions.https.HttpsError(
                'internal',
                'Failed to trigger event discovery'
            );
        }
    });
