/**
 * Firebase Cloud Function: AI Chat Endpoint
 * 
 * This function handles AI chat requests from the Flutter app
 * and communicates with OpenAI's Chat Completions API.
 * 
 * IMPORTANT: Never expose your OpenAI API key in the client app.
 * Always handle API calls server-side.
 */

const functions = require('firebase-functions');
const OpenAI = require('openai');

// Initialize OpenAI client with API key from environment
const openai = new OpenAI({
    apiKey: process.env.OPENAI_API_KEY, // Set this in Firebase Functions config
});

const SYSTEM_PROMPT =
    'You are a helpful assistant for UAE company setup, free zones, licensing, ' +
    'costs, and documentation. Answer concisely, state assumptions, and suggest ' +
    'next steps when uncertain.';

exports.aiChat = functions.https.onCall(async (data, context) => {
    try {
        // Validate request
        if (!data.messages || !Array.isArray(data.messages)) {
            throw new functions.https.HttpsError(
                'invalid-argument',
                'Messages array is required'
            );
        }

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

/**
 * SETUP INSTRUCTIONS:
 * 
 * 1. Install dependencies in your functions directory:
 *    cd functions
 *    npm install openai
 * 
 * 2. Set your OpenAI API key in Firebase Functions config:
 *    firebase functions:config:set openai.api_key="sk-..."
 * 
 * 3. (Optional) Set a custom model:
 *    firebase functions:config:set openai.model="gpt-4"
 * 
 * 4. Deploy the function:
 *    firebase deploy --only functions:aiChat
 * 
 * 5. Update your Flutter app to call this function using:
 *    final callable = FirebaseFunctions.instance.httpsCallable('aiChat');
 *    final result = await callable.call({'messages': [...]});
 * 
 * SECURITY NOTES:
 * - This function is callable by authenticated and unauthenticated users
 * - Consider adding authentication checks: if (!context.auth) throw error
 * - Consider rate limiting to prevent abuse
 * - Monitor usage and costs in OpenAI dashboard
 * - Set reasonable max_tokens to control costs
 */

/**
 * Example usage from Flutter:
 * 
 * ```dart
 * final callable = FirebaseFunctions.instance.httpsCallable('aiChat');
 * final result = await callable.call({
 *   'messages': [
 *     {'role': 'user', 'content': 'What is DMCC?'},
 *   ],
 * });
 * final response = result.data['text'];
 * ```
 */
