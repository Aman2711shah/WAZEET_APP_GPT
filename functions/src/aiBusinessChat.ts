import 'dotenv/config';
import * as functions from "firebase-functions";
import * as logger from "firebase-functions/logger";
import * as admin from "firebase-admin";
import OpenAI from "openai";

// =======================
// Utility: Env validation
// =======================
const requireEnv = (v?: string, name?: string): string => {
    if (!v) {
        throw new Error(`${name ?? 'ENV'} not configured`);
    }
    return v;
};

// =======================
// Utility: Redact secrets from logs
// =======================
const redactSecrets = (text: string): string => {
    return text.replace(/sk-[a-zA-Z0-9]{20,}/g, '***REDACTED***');
};

// Initialize OpenAI client with secure key handling
// Uses .env.local for emulators, functions.config() for deployed
const getOpenAIKey = (): string => {
    const key = process.env.OPENAI_API_KEY || functions.config().openai?.key;
    return requireEnv(key, 'OPENAI_API_KEY');
};

const OPENAI_KEY = getOpenAIKey();
const openaiClient = new OpenAI({
    apiKey: OPENAI_KEY,
});

// =======================
// Rate Limiting (in-memory per-uid)
// =======================
interface RateLimitEntry {
    count: number;
    resetAt: number;
}

const rateLimitMap = new Map<string, RateLimitEntry>();
const RATE_LIMIT_WINDOW_MS = 1000; // 1 second
const RATE_LIMIT_BURST = 3; // Allow burst of 3

const checkRateLimit = (userId: string): boolean => {
    const now = Date.now();
    const entry = rateLimitMap.get(userId);

    if (!entry || now > entry.resetAt) {
        // Reset or create new entry
        rateLimitMap.set(userId, {
            count: 1,
            resetAt: now + RATE_LIMIT_WINDOW_MS,
        });
        return true;
    }

    if (entry.count < RATE_LIMIT_BURST) {
        entry.count++;
        return true;
    }

    return false; // Rate limit exceeded
};

// Cleanup old rate limit entries every 5 minutes
setInterval(() => {
    const now = Date.now();
    for (const [userId, entry] of rateLimitMap.entries()) {
        if (now > entry.resetAt + 60000) {
            rateLimitMap.delete(userId);
        }
    }
}, 5 * 60 * 1000);

// Tool definitions for function calling
const tools: OpenAI.Chat.ChatCompletionTool[] = [
    {
        type: "function",
        function: {
            name: "recommend_freezones",
            description: "Return top freezones for given business constraints and requirements",
            parameters: {
                type: "object",
                properties: {
                    activity: {
                        type: "string",
                        description: "Business activity type (e.g., e-commerce, trading, consultancy)"
                    },
                    visas: {
                        type: "number",
                        description: "Number of visas required"
                    },
                    budget: {
                        type: "string",
                        enum: ["low", "medium", "high"],
                        description: "Budget range"
                    },
                    emirate: {
                        type: "string",
                        description: "Preferred emirate (optional)"
                    }
                },
                required: ["activity"]
            }
        }
    },
    {
        type: "function",
        function: {
            name: "estimate_cost",
            description: "Rough cost estimate for a specific freezone setup",
            parameters: {
                type: "object",
                properties: {
                    freezone_id: {
                        type: "string",
                        description: "Freezone ID (e.g., RAKEZ, AFZ, SAIF_ZONE)"
                    },
                    visas: {
                        type: "number",
                        description: "Number of visas needed"
                    },
                    tenure: {
                        type: "number",
                        description: "License tenure in years (default 1)"
                    }
                },
                required: ["freezone_id"]
            }
        }
    },
    {
        type: "function",
        function: {
            name: "next_questions",
            description: "Ask follow-up clarifying questions to better understand user needs",
            parameters: {
                type: "object",
                properties: {}
            }
        }
    }
];

// System prompt for UAE business setup context
const SYSTEM_PROMPT = `You are "AI Business Expert" for WAZEET, a UAE business setup platform. Help users choose optimal UAE business setup options.

Prioritize factual info from our tools and Firestore dataset (freezones, packages, visa counts, tenure).

Always:
- Ask 1–2 clarifying questions before final recommendations if inputs are incomplete.
- When confident, call tools \`recommend_freezones\` then \`estimate_cost\` for top 3 picks.
- Return a concise summary + bullet points + a clean list of normalized freezone names/ids.
- Provide actionable next steps and required documents.
- Avoid legal/financial guarantees; include safe disclaimers when uncertain.

Freezone naming conventions:
- RAK Free Trade Zone → RAKEZ
- Ajman Free Zone → AFZ (ajman_free_zone)
- Sharjah Airport International Free Zone → SAIF_ZONE (saif_zone)
- Dubai Multi Commodities Centre → DMCC
- International Free Zone Authority → IFZA
- Meydan Free Zone → meydan_freezone
- Jebel Ali Free Zone → JAFZA (jafza)
- Dubai Airport Free Zone → DAFZ (dafza)
- Dubai Silicon Oasis → DSO (dubai_silicon_oasis)
- Dubai International Financial Centre → DIFC (difc)
- Abu Dhabi Global Market → ADGM (adgm)
- KEZAD → kezad
- Masdar City Free Zone → masdar_city
- Sharjah Media City → SHAMS (shams)
- Fujairah Free Zone Authority → FFZA (fujairah_free_zone)
- Umm Al Quwain Free Trade Zone → UAQ (uaq_free_trade_zone)

When providing recommendations, always use the canonical IDs in parentheses.`;

/**
 * HTTPS Callable function for AI Business Expert Chat with streaming support
 * 
 * Request: {
 *   messages: Array<{role: string, content: string}>,
 *   userId: string,
 *   filters?: {activity?, visas?, budget?, emirate?}
 * }
 * 
 * Response: Server-Sent Events (SSE) stream with chunks
 */
export const aiBusinessChat = functions
    .runWith({
        timeoutSeconds: 60,
        memory: "512MB",
    })
    .https.onRequest(async (req, res) => {
        // CORS headers
        res.set("Access-Control-Allow-Origin", "*");
        res.set("Access-Control-Allow-Methods", "POST, OPTIONS");
        res.set("Access-Control-Allow-Headers", "Content-Type, Authorization");

        if (req.method === "OPTIONS") {
            res.status(204).send("");
            return;
        }

        if (req.method !== "POST") {
            res.status(405).json({ error: "Method not allowed" });
            return;
        }

        try {
            // =======================
            // Auth: Verify Firebase Auth token (401 if missing)
            // =======================
            const authHeader = req.headers.authorization;
            if (!authHeader || !authHeader.startsWith("Bearer ")) {
                res.status(401).json({ error: "Unauthorized: Missing or invalid token" });
                return;
            }

            const idToken = authHeader.split("Bearer ")[1];
            let decodedToken;
            try {
                decodedToken = await admin.auth().verifyIdToken(idToken);
            } catch (error) {
                logger.error("Token verification failed", redactSecrets(String(error)));
                res.status(401).json({ error: "Unauthorized: Invalid token" });
                return;
            }

            const userId = decodedToken.uid;

            // =======================
            // Rate Limit: Check per-uid (429 if exceeded)
            // =======================
            if (!checkRateLimit(userId)) {
                logger.warn("Rate limit exceeded", { userId: userId.substring(0, 8) });
                res.status(429).json({
                    error: "Too many requests. Please wait a moment before trying again.",
                    retryAfter: RATE_LIMIT_WINDOW_MS / 1000,
                });
                return;
            }

            const { messages, filters } = req.body;

            if (!Array.isArray(messages) || messages.length === 0) {
                res.status(400).json({ error: "Invalid request: messages required" });
                return;
            }

            // =======================
            // SSE: Setup streaming headers
            // =======================
            res.setHeader("Content-Type", "text/event-stream");
            res.setHeader("Cache-Control", "no-cache");
            res.setHeader("Connection", "keep-alive");
            res.setHeader("X-Accel-Buffering", "no"); // Disable nginx buffering

            // Send initial heartbeat
            res.write(": heartbeat\n\n");
            res.flushHeaders();

            // Build messages with system prompt
            const chatMessages: OpenAI.Chat.ChatCompletionMessageParam[] = [
                { role: "system", content: SYSTEM_PROMPT },
                ...messages.map((msg: any) => ({
                    role: msg.role as "user" | "assistant" | "system",
                    content: msg.content
                }))
            ];

            // Add filters to context if provided
            if (filters) {
                const filterContext = `User context: activity=${filters.activity || "not specified"}, visas=${filters.visas || "not specified"}, budget=${filters.budget || "not specified"}, emirate=${filters.emirate || "not specified"}`;
                chatMessages.push({ role: "system", content: filterContext });
            }

            // Track tool calls
            let toolCallsCount = 0;
            const maxToolCalls = 2; // Prevent infinite loops

            // Stream the response
            const stream = await openaiClient.chat.completions.create({
                model: "gpt-4o-mini",
                messages: chatMessages,
                tools: tools,
                tool_choice: "auto",
                stream: true,
                temperature: 0.7,
                max_tokens: 1000,
            });

            let fullContent = "";
            let toolCallBuffer: any = null;

            for await (const chunk of stream) {
                const delta = chunk.choices[0]?.delta;

                if (delta?.content) {
                    fullContent += delta.content;
                    // Send content chunk
                    res.write(`data: ${JSON.stringify({ type: "content", content: delta.content })}\n\n`);
                }

                // Handle tool calls
                if (delta?.tool_calls && toolCallsCount < maxToolCalls) {
                    for (const toolCall of delta.tool_calls) {
                        if (toolCall.function?.name) {
                            toolCallBuffer = {
                                id: toolCall.id,
                                name: toolCall.function.name,
                                arguments: toolCall.function.arguments || ""
                            };
                        } else if (toolCall.function?.arguments) {
                            toolCallBuffer.arguments += toolCall.function.arguments;
                        }
                    }
                }

                // Execute tool call when complete
                if (chunk.choices[0]?.finish_reason === "tool_calls" && toolCallBuffer) {
                    toolCallsCount++;
                    const toolResult = await executeToolCall(toolCallBuffer, userId);

                    // Send tool result to client
                    res.write(`data: ${JSON.stringify({
                        type: "tool_call",
                        tool: toolCallBuffer.name,
                        result: toolResult
                    })}\n\n`);

                    // Continue conversation with tool result
                    chatMessages.push({
                        role: "assistant",
                        content: null as any,
                        tool_calls: [{
                            id: toolCallBuffer.id,
                            type: "function" as const,
                            function: {
                                name: toolCallBuffer.name,
                                arguments: toolCallBuffer.arguments
                            }
                        }]
                    });
                    chatMessages.push({
                        role: "tool",
                        tool_call_id: toolCallBuffer.id,
                        content: JSON.stringify(toolResult)
                    });

                    // Get next response from model
                    const followUpStream = await openaiClient.chat.completions.create({
                        model: "gpt-4o-mini",
                        messages: chatMessages,
                        stream: true,
                        temperature: 0.7,
                        max_tokens: 1000,
                    });

                    for await (const followUpChunk of followUpStream) {
                        const followUpDelta = followUpChunk.choices[0]?.delta;
                        if (followUpDelta?.content) {
                            fullContent += followUpDelta.content;
                            res.write(`data: ${JSON.stringify({ type: "content", content: followUpDelta.content })}\n\n`);
                        }
                    }

                    toolCallBuffer = null;
                }
            }

            // Send completion
            res.write(`data: ${JSON.stringify({ type: "done", fullContent })}\n\n`);
            res.end();

            // Log conversation for analytics (without PII or secrets)
            logger.info("AI chat completed", {
                userId: userId.substring(0, 8) + "...", // Truncate for privacy
                messageCount: messages.length,
                toolCallsCount,
                responseLength: fullContent.length
            });

        } catch (error: any) {
            // Log error with redaction (never log API keys or request bodies)
            logger.error("aiBusinessChat error", {
                message: redactSecrets(error?.message || String(error)),
                status: error?.status,
            });

            // =======================
            // Error handling: Clean SSE closure
            // =======================
            try {
                // Handle OpenAI rate limiting
                if (error?.status === 429) {
                    res.write(`data: ${JSON.stringify({
                        type: "error",
                        error: "OpenAI rate limit reached. Please try again in a moment."
                    })}\n\n`);
                } else if (error?.code === 'ETIMEDOUT' || error?.code === 'ECONNRESET') {
                    res.write(`data: ${JSON.stringify({
                        type: "error",
                        error: "Connection timeout. Please try again."
                    })}\n\n`);
                } else {
                    res.write(`data: ${JSON.stringify({
                        type: "error",
                        error: "An error occurred. Please try again."
                    })}\n\n`);
                }
            } catch (writeError) {
                // Response already closed, ignore
                logger.warn("Failed to write error to response", {
                    error: redactSecrets(String(writeError))
                });
            } finally {
                res.end();
            }
        }
    });

/**
 * Execute tool calls and fetch data from Firestore
 */
async function executeToolCall(toolCall: any, userId: string): Promise<any> {
    const db = admin.firestore();
    const args = JSON.parse(toolCall.arguments);

    // Log without sensitive data
    logger.info("Executing tool call", {
        tool: toolCall.name,
        userId: userId.substring(0, 8),
        argsKeys: Object.keys(args),
    });

    switch (toolCall.name) {
        case "recommend_freezones": {
            const { activity, visas, budget, emirate } = args;

            // Query Firestore for matching freezones
            let query = db.collection("freezones").limit(10);

            // Apply filters based on activity
            if (activity) {
                const activityLower = activity.toLowerCase();
                // This is a simplified filter - in production, use more sophisticated matching
                query = query.where("industries", "array-contains-any", [activity, activityLower]);
            }

            const snapshot = await query.get();
            const freezones = snapshot.docs.map(doc => ({
                id: doc.id,
                name: doc.data().name,
                abbreviation: doc.data().abbreviation,
                emirate: doc.data().emirate,
                costs: doc.data().costs,
                keyAdvantages: doc.data().key_advantages || [],
                industries: doc.data().industries || []
            }));

            // Score and rank freezones
            const ranked = freezones
                .map(fz => {
                    let score = 0;

                    // Budget scoring
                    if (budget && fz.costs?.setup) {
                        const setupCost = typeof fz.costs.setup === 'string' ?
                            parseInt(fz.costs.setup.match(/\d+/)?.[0] || "50000") : 50000;

                        if (budget === "low" && setupCost < 20000) score += 3;
                        else if (budget === "medium" && setupCost >= 20000 && setupCost < 50000) score += 3;
                        else if (budget === "high" && setupCost >= 50000) score += 3;
                    }

                    // Emirate preference
                    if (emirate && fz.emirate?.toLowerCase().includes(emirate.toLowerCase())) {
                        score += 2;
                    }

                    // Activity match (already filtered, so boost score)
                    if (activity) score += 2;

                    return { ...fz, score };
                })
                .sort((a, b) => b.score - a.score)
                .slice(0, 3);

            return {
                recommendations: ranked.map(fz => ({
                    id: fz.id,
                    name: fz.name,
                    abbreviation: fz.abbreviation,
                    emirate: fz.emirate,
                    reason: fz.keyAdvantages.slice(0, 2).join("; ") || "Good fit for your requirements"
                })),
                filters: { activity, visas, budget, emirate }
            };
        }

        case "estimate_cost": {
            const { freezone_id, visas = 1, tenure = 1 } = args;

            // Fetch freezone from Firestore
            const doc = await db.collection("freezones").doc(freezone_id.toLowerCase()).get();

            if (!doc.exists) {
                return {
                    error: "Freezone not found",
                    freezone_id
                };
            }

            const data = doc.data()!;
            const costs = data.costs || {};

            // Calculate rough estimate
            let setupCost = 15000; // Default
            if (costs.setup) {
                if (typeof costs.setup === 'string') {
                    const match = costs.setup.match(/\d+/);
                    setupCost = match ? parseInt(match[0]) : 15000;
                }
            }

            const visaCost = visas * 3000; // Rough estimate per visa
            const annualRenewal = setupCost * 0.7; // Rough estimate
            const totalFirstYear = setupCost + visaCost;
            const totalOverTenure = setupCost + visaCost + (annualRenewal * (tenure - 1));

            return {
                freezone: data.name,
                costs: {
                    setup: `AED ${setupCost.toLocaleString()}`,
                    visas: `AED ${visaCost.toLocaleString()} (${visas} visa${visas > 1 ? 's' : ''})`,
                    annualRenewal: `AED ${annualRenewal.toLocaleString()}`,
                    totalFirstYear: `AED ${totalFirstYear.toLocaleString()}`,
                    totalOverTenure: `AED ${totalOverTenure.toLocaleString()} (${tenure} year${tenure > 1 ? 's' : ''})`
                },
                inclusions: data.key_advantages?.slice(0, 3) || ["License", "Office space", "Visa processing"],
                disclaimer: "These are rough estimates. Actual costs vary based on specific requirements."
            };
        }

        case "next_questions": {
            return {
                questions: [
                    "What is your approximate budget range for the setup?",
                    "Which emirate do you prefer (Dubai, Abu Dhabi, RAK, etc.)?",
                    "Do you need office space or would a virtual office work?"
                ]
            };
        }

        default:
            return { error: "Unknown tool" };
    }
}
