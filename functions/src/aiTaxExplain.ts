/* eslint-disable */
import * as functions from "firebase-functions";
import * as admin from "firebase-admin";
import * as logger from "firebase-functions/logger";
import OpenAI from "openai";

const db = admin.firestore();

function getApiKey(): string {
    const key = process.env.OPENAI_API_KEY || (functions.config().openai?.api_key as string | undefined);
    if (!key) {
        throw new functions.https.HttpsError(
            "failed-precondition",
            "OpenAI API key not configured. Set env OPENAI_API_KEY or functions config openai.api_key"
        );
    }
    return key;
}

async function checkRateLimit(uid: string): Promise<void> {
    // Simple per-user per-hour rate limit using Firestore
    const now = admin.firestore.Timestamp.now();
    const windowStartMs = now.toMillis() - 60 * 60 * 1000; // 1 hour
    const ref = db.collection("rate_limits").doc(uid).collection("aiTaxExplain");

    const snap = await ref
        .where("timestamp", ">=", admin.firestore.Timestamp.fromMillis(windowStartMs))
        .get();

    const MAX_CALLS = 10;
    if (snap.size >= MAX_CALLS) {
        throw new functions.https.HttpsError("resource-exhausted", "Rate limit exceeded. Try again later.");
    }
    // record this call
    await ref.add({ timestamp: now });
}

function validatePayload(data: any): { type: "vat" | "corporate"; input: any; result: any } {
    const type = data?.type;
    if (type !== "vat" && type !== "corporate") {
        throw new functions.https.HttpsError("invalid-argument", "type must be 'vat' or 'corporate'");
    }
    if (typeof data?.input !== "object" || typeof data?.result !== "object") {
        throw new functions.https.HttpsError("invalid-argument", "input and result are required objects");
    }
    return { type, input: data.input, result: data.result };
}

export const aiTaxExplain = functions.https.onCall(async (data, context) => {
    try {
        if (!context.auth) {
            throw new functions.https.HttpsError("unauthenticated", "User must be authenticated");
        }

        await checkRateLimit(context.auth.uid);

        const { type, input, result } = validatePayload(data);

        const apiKey = getApiKey();
        const openai = new OpenAI({ apiKey });

        const sys =
            "You are a helpful UAE tax assistant. Explain calculations clearly and briefly. " +
            "Use AED currency, concise steps, and include a short non-legal-advice disclaimer.";

        const user = JSON.stringify({ type, input, result });

        // Use small token footprint, aim for ~150-250 words
        const chat = await openai.chat.completions.create({
            model: "gpt-4o-mini",
            messages: [
                { role: "system", content: sys },
                {
                    role: "user",
                    content:
                        "Explain this UAE " +
                        (type === "vat" ? "VAT" : "Corporate Tax") +
                        " calculation for a business owner in 4-7 bullets and 1 tip. JSON: " +
                        user,
                },
            ],
            temperature: 0.2,
            max_tokens: 500,
        });

        const text = chat.choices?.[0]?.message?.content?.trim() || "Explanation unavailable.";

        return { ok: true, text };
    } catch (err: any) {
        logger.error("aiTaxExplain error", err);
        if (err instanceof functions.https.HttpsError) throw err;
        throw new functions.https.HttpsError("internal", err?.message || "Unknown error");
    }
});
