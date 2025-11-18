import 'dotenv/config';
import fetch from "node-fetch";
import * as functions from "firebase-functions";

interface ChatRequestBody {
    messages?: Array<Record<string, any>>;
    model?: string;
}

const OPENAI_API_URL = "https://api.openai.com/v1/chat/completions";

const getApiKey = (): string | undefined => {
    return process.env.OPENAI_API_KEY || functions.config().openai?.key;
};

export const chatAI = functions
    .region("us-central1")
    .https.onRequest(async (req, res) => {
        res.set("Access-Control-Allow-Origin", "*");
        res.set("Access-Control-Allow-Methods", "POST, OPTIONS");
        res.set("Access-Control-Allow-Headers", "Content-Type");

        if (req.method === "OPTIONS") {
            res.status(204).send("");
            return;
        }

        if (req.method !== "POST") {
            res.status(405).json({ error: "Only POST allowed." });
            return;
        }

        const apiKey = getApiKey();
        if (!apiKey) {
            console.error("OPENAI_API_KEY missing in functions config");
            res.status(500).json({
                error: "AI backend misconfigured (no API key)."
            });
            return;
        }

        try {
            const body = (req.body || {}) as ChatRequestBody;
            const { messages, model = "gpt-4.1-mini" } = body;

            if (!messages || !Array.isArray(messages)) {
                res.status(400).json({
                    error: "Body must contain messages: []"
                });
                return;
            }

            const response = await fetch(OPENAI_API_URL, {
                method: "POST",
                headers: {
                    Authorization: `Bearer ${apiKey}`,
                    "Content-Type": "application/json",
                },
                body: JSON.stringify({ model, messages })
            });

            const data = await response.json();

            if (!response.ok) {
                console.error("OpenAI error:", data);
                res.status(500).json({
                    error: "OpenAI request failed",
                    details: data,
                });
                return;
            }

            const content = data?.choices?.[0]?.message?.content || "";
            res.status(200).json({ message: content });
            return;
        } catch (err) {
            console.error("❌ chatAI error:", err);
            res.status(500).json({ error: "AI backend failed." });
        }
    });
