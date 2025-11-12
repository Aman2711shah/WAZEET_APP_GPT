const functions = require("firebase-functions");
const admin = require("firebase-admin");
const Stripe = require("stripe");
const OpenAI = require("openai");

admin.initializeApp();

/**
 * Create a Stripe PaymentIntent for processing payments
 * 
 * @param {Object} data - Request data
 * @param {number} data.amount - Amount in AED (will be converted to fils)
 * @param {string} data.applicationId - Application ID for tracking
 * @param {('standard'|'premium')} [data.tier] - Optional service tier for metadata/pricing
 * @param {Object} context - Firebase Functions context
 * @returns {Object} - Contains clientSecret for Stripe PaymentSheet
 */
exports.createPaymentIntent = functions
    .region('us-central1')
    .https.onCall(async (data, context) => {
        // Verify user is authenticated
        if (!context.auth) {
            throw new functions.https.HttpsError(
                'unauthenticated',
                'Sign in required to create payment'
            );
        }

        try {
            // Resolve Stripe secret from environment or Firebase functions config
            const stripeSecret = process.env.STRIPE_SECRET || (functions.config().stripe && functions.config().stripe.secret);
            // Guard missing Stripe env vars early for clearer error to client
            if (!stripeSecret) {
                console.error('STRIPE_SECRET env var missing');
                throw new functions.https.HttpsError(
                    'failed-precondition',
                    'Payment configuration incomplete'
                );
            }
            const stripe = new Stripe(stripeSecret);

            // Convert AED to fils (100 fils = 1 AED)
            const amountAED = Math.round(Number(data.amount) * 100);
            const applicationId = data.applicationId || '';
            const tier = (data.tier || '').toString().toLowerCase();

            // Validate amount
            if (amountAED < 100) {
                throw new functions.https.HttpsError(
                    'invalid-argument',
                    'Amount must be at least 1 AED'
                );
            }

            let intent;
            try {
                intent = await stripe.paymentIntents.create({
                    amount: amountAED,
                    currency: 'aed',
                    automatic_payment_methods: { enabled: true },
                    metadata: {
                        uid: context.auth.uid,
                        applicationId: applicationId,
                        userEmail: context.auth.token.email || '',
                        serviceTier: tier || 'standard',
                    },
                });
            } catch (piError) {
                console.error('Stripe PaymentIntent API error:', {
                    message: piError.message,
                    type: piError.type,
                    code: piError.code,
                });
                throw new functions.https.HttpsError(
                    'internal',
                    'Stripe payment initialization failed'
                );
            }

            // Log payment intent creation
            console.log(`PaymentIntent created: ${intent.id} for user ${context.auth.uid}`);

            return {
                clientSecret: intent.client_secret,
                paymentIntentId: intent.id,
            };
        } catch (error) {
            if (error instanceof functions.https.HttpsError) {
                throw error; // already wrapped with user-friendly message
            }
            console.error('Unhandled payment creation error:', error);
            throw new functions.https.HttpsError(
                'internal',
                'Failed to create payment intent'
            );
        }
    });

/**
 * Webhook endpoint for Stripe events (optional, for advanced use)
 * Handles payment confirmations and updates
 */
exports.handleStripeWebhook = functions
    .region('us-central1')
    .https.onRequest(async (req, res) => {
        const stripeSecret = process.env.STRIPE_SECRET || (functions.config().stripe && functions.config().stripe.secret);
        const stripe = new Stripe(stripeSecret);
        const webhookSecret = process.env.STRIPE_WEBHOOK_SECRET || (functions.config().stripe && functions.config().stripe.webhook_secret);

        let event;

        try {
            const sig = req.headers['stripe-signature'];
            event = stripe.webhooks.constructEvent(req.rawBody, sig, webhookSecret);
        } catch (err) {
            console.error('Webhook signature verification failed:', err.message);
            return res.status(400).send(`Webhook Error: ${err.message}`);
        }

        // Handle the event
        switch (event.type) {
            case 'payment_intent.succeeded':
                const paymentIntent = event.data.object;
                console.log('PaymentIntent succeeded:', paymentIntent.id);

                // Update Firestore application status
                if (paymentIntent.metadata.applicationId) {
                    await admin.firestore()
                        .collection('applications')
                        .doc(paymentIntent.metadata.applicationId)
                        .update({
                            status: 'paid',
                            payment_id: paymentIntent.id,
                            paid_at: admin.firestore.FieldValue.serverTimestamp(),
                        });
                }
                break;

            case 'payment_intent.payment_failed':
                const failedIntent = event.data.object;
                console.log('PaymentIntent failed:', failedIntent.id);
                break;

            default:
                console.log(`Unhandled event type ${event.type}`);
        }

        res.json({ received: true });
    });

/**
 * AI Chat endpoint using OpenAI API
 * Handles chat completions for UAE company setup assistance
 * 
 * @param {Object} data - Request data
 * @param {Array} data.messages - Array of chat messages {role, content}
 * @param {Object} context - Firebase Functions context
 * @returns {Object} - Contains response text from AI
 */
exports.aiChat = functions
    .region('us-central1')
    .https.onCall(async (data, context) => {
        try {
            // Validate request
            if (!data.messages || !Array.isArray(data.messages)) {
                throw new functions.https.HttpsError(
                    'invalid-argument',
                    'Messages array is required'
                );
            }

            // Optional: Require authentication
            // Uncomment to enforce user authentication:
            // if (!context.auth) {
            //     throw new functions.https.HttpsError(
            //         'unauthenticated',
            //         'Sign in required to use AI chat'
            //     );
            // }

            // Initialize OpenAI client
            const openai = new OpenAI({
                apiKey: process.env.OPENAI_API_KEY,
            });

            const SYSTEM_PROMPT =
                'You are a helpful assistant for UAE company setup, free zones, licensing, ' +
                'costs, and documentation. Answer concisely, state assumptions, and suggest ' +
                'next steps when uncertain.';

            // Build messages with system prompt
            const messages = [
                { role: 'system', content: SYSTEM_PROMPT },
                ...data.messages,
            ];

            // Call OpenAI API
            const model = process.env.OPENAI_MODEL || 'gpt-4o-mini';
            const completion = await openai.chat.completions.create({
                model: model,
                messages: messages,
                temperature: 0.3,
                max_tokens: 1000,
                stream: false,
            });

            const responseText = completion.choices?.[0]?.message?.content ?? '';

            // Log usage for monitoring
            console.log(`AI Chat - User: ${context.auth?.uid || 'anonymous'}, ` +
                `Model: ${model}, Tokens: ${completion.usage?.total_tokens || 0}`);

            return {
                text: responseText,
                model: model,
                usage: completion.usage,
            };
        } catch (error) {
            console.error('AI Chat Error:', error);

            // Return user-friendly error
            throw new functions.https.HttpsError(
                'internal',
                'Failed to get AI response',
                { detail: error.message }
            );
        }
    });
