/* eslint-disable */
import * as admin from "firebase-admin";
import * as logger from "firebase-functions/logger";
import { onCall, HttpsError } from "firebase-functions/v2/https";
import OpenAI from "openai";

// Ensure admin is initialized by index.ts
const db = admin.firestore();

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
        throw new HttpsError("resource-exhausted", "Rate limit exceeded. Try again later.");
    }
    // record this call
    await ref.add({ timestamp: now });
}

export const aiTaxExplain = onCall({
    secrets: ["OPENAI_API_KEY"],
    region: "us-central1",
    maxInstances: 10,
}, async (request) => {
    try {
        const auth = request.auth;
        if (!auth) {
            throw new HttpsError("unauthenticated", "User must be authenticated");
        }

        await checkRateLimit(auth.uid);

        const data = request.data || {};
        const { mode, inputs, results, locale = "en", currency = "AED" } = data;
        if (!mode || !inputs || !results) {
            throw new HttpsError("invalid-argument", "Missing mode, inputs, or results");
        }

        const openai = new OpenAI({ apiKey: process.env.OPENAI_API_KEY });

        const sysPrompt = `You are a UAE tax assistant.\nExplain the ${mode === "vat" ? "VAT (Value Added Tax)" : "Corporate Tax"} calculation clearly using the provided numbers. Show each step and formula, mention thresholds and rates where relevant, and end with a short summary. Respond in ${locale} and keep it under 180 words. Use ${currency} for currency values.`;

        const completion = await openai.chat.completions.create({
            model: "gpt-4o-mini",
            messages: [
                { role: "system", content: sysPrompt },
                { role: "user", content: JSON.stringify({ mode, inputs, results }) },
            ],
            temperature: 0.4,
        });

        const explanation = completion.choices?.[0]?.message?.content?.trim();
        return {
            explanation: explanation || "Sorry, I couldn’t generate an explanation. Please try again later.",
        };
    } catch (err: any) {
        logger.error("AI Explain Error", err);
        if (err instanceof HttpsError) throw err;
        throw new HttpsError("internal", err?.message || "Unexpected error");
    }
});
