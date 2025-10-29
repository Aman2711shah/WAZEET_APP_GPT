const functions = require("firebase-functions");
const admin = require("firebase-admin");
const Stripe = require("stripe");

admin.initializeApp();

/**
 * Create a Stripe PaymentIntent for processing payments
 * 
 * @param {Object} data - Request data
 * @param {number} data.amount - Amount in AED (will be converted to fils)
 * @param {string} data.applicationId - Application ID for tracking
 * @param {Object} context - Firebase Functions context
 * @returns {Object} - Contains clientSecret for Stripe PaymentSheet
 */
exports.createPaymentIntent = functions
    .region('me-central1')
    .https.onCall(async (data, context) => {
        // Verify user is authenticated
        if (!context.auth) {
            throw new functions.https.HttpsError(
                'unauthenticated',
                'Sign in required to create payment'
            );
        }

        try {
            // Initialize Stripe with secret key from environment
            const stripe = new Stripe(process.env.STRIPE_SECRET);

            // Convert AED to fils (100 fils = 1 AED)
            const amountAED = Math.round(Number(data.amount) * 100);
            const applicationId = data.applicationId || '';

            // Validate amount
            if (amountAED < 100) {
                throw new functions.https.HttpsError(
                    'invalid-argument',
                    'Amount must be at least 1 AED'
                );
            }

            // Create PaymentIntent
            const intent = await stripe.paymentIntents.create({
                amount: amountAED,
                currency: 'aed',
                automatic_payment_methods: { enabled: true },
                metadata: {
                    uid: context.auth.uid,
                    applicationId: applicationId,
                    userEmail: context.auth.token.email || '',
                },
            });

            // Log payment intent creation
            console.log(`PaymentIntent created: ${intent.id} for user ${context.auth.uid}`);

            return {
                clientSecret: intent.client_secret,
                paymentIntentId: intent.id,
            };
        } catch (error) {
            console.error('Stripe payment intent creation error:', error);
            throw new functions.https.HttpsError(
                'internal',
                'Failed to create payment intent: ' + error.message
            );
        }
    });

/**
 * Webhook endpoint for Stripe events (optional, for advanced use)
 * Handles payment confirmations and updates
 */
exports.handleStripeWebhook = functions
    .region('me-central1')
    .https.onRequest(async (req, res) => {
        const stripe = new Stripe(process.env.STRIPE_SECRET);
        const webhookSecret = process.env.STRIPE_WEBHOOK_SECRET;

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
