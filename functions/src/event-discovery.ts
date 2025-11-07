/* eslint-disable */
import * as logger from "firebase-functions/logger";
import OpenAI from "openai";
import { HttpsError } from "firebase-functions/v2/https";

// Types for event discovery
interface DiscoveredEvent {
    eventName: string;
    description: string;
    date: string;
    location: string;
    category: string;
    websiteUrl: string;
    organizer: string;
    attendees?: number;
}

/**
 * Retry configuration
 */
const RETRY_CONFIG = {
    maxRetries: 3,
    baseDelay: 1000, // 1 second
    maxDelay: 10000, // 10 seconds
    backoffMultiplier: 2,
};

/**
 * Sleep utility for retry delays
 */
function sleep(ms: number): Promise<void> {
    return new Promise(resolve => setTimeout(resolve, ms));
}

/**
 * Calculate exponential backoff delay
 */
function getRetryDelay(attempt: number): number {
    const delay = Math.min(
        RETRY_CONFIG.baseDelay * Math.pow(RETRY_CONFIG.backoffMultiplier, attempt),
        RETRY_CONFIG.maxDelay
    );
    // Add jitter (±20%)
    const jitter = delay * 0.2 * (Math.random() * 2 - 1);
    return Math.floor(delay + jitter);
}

/**
 * Retry wrapper for async operations with exponential backoff
 */
async function retryWithBackoff<T>(
    operation: () => Promise<T>,
    operationName: string
): Promise<T> {
    let lastError: Error | null = null;

    for (let attempt = 0; attempt <= RETRY_CONFIG.maxRetries; attempt++) {
        try {
            logger.info(`${operationName}: Attempt ${attempt + 1}/${RETRY_CONFIG.maxRetries + 1}`);
            return await operation();
        } catch (error: any) {
            lastError = error;

            // Don't retry on certain errors
            if (
                error?.status === 401 || // Unauthorized
                error?.status === 403 || // Forbidden
                error?.status === 400    // Bad Request
            ) {
                logger.error(`${operationName}: Non-retryable error (${error.status})`, error);
                throw error;
            }

            // If this was the last attempt, throw
            if (attempt === RETRY_CONFIG.maxRetries) {
                logger.error(`${operationName}: All ${RETRY_CONFIG.maxRetries + 1} attempts failed`);
                break;
            }

            // Calculate delay and log
            const delay = getRetryDelay(attempt);
            logger.warn(
                `${operationName}: Attempt ${attempt + 1} failed. ` +
                `Retrying in ${delay}ms... Error: ${error?.message}`
            );

            await sleep(delay);
        }
    }

    // All retries exhausted
    throw new HttpsError(
        "unavailable",
        `${operationName} failed after ${RETRY_CONFIG.maxRetries + 1} attempts: ${lastError?.message}`,
        lastError
    );
}

/**
 * Call OpenAI API to discover events with retry logic
 */
export async function discoverEventsWithOpenAI(
    searchQuery: string = "Dubai business networking events"
): Promise<DiscoveredEvent[]> {
    const apiKey = process.env.OPENAI_API_KEY;

    if (!apiKey) {
        throw new HttpsError(
            "failed-precondition",
            "OPENAI_API_KEY environment variable not set"
        );
    }

    const openai = new OpenAI({ apiKey });

    const prompt = `You are an event discovery assistant for business professionals in Dubai.
  
Task: Find real, upcoming business events in Dubai based on this query: "${searchQuery}"

Requirements:
- Events must be in the next 3 months
- Focus on: networking, workshops, conferences, competitions, trade shows
- Only include events with verifiable dates and locations
- Provide realistic event information

Return exactly 5-10 events as a JSON array with this structure:
[
  {
    "eventName": "Event Name",
    "description": "Brief description (100-200 chars)",
    "date": "YYYY-MM-DD",
    "location": "Venue name, Dubai",
    "category": "Networking|Workshop|Conference|Competition|Other",
    "websiteUrl": "https://example.com",
    "organizer": "Organization name"
  }
]

Important: Return ONLY the JSON array, no markdown, no extra text.`;

    try {
        // Wrap the OpenAI call in retry logic
        const response = await retryWithBackoff(
            async () => {
                return await openai.chat.completions.create({
                    model: "gpt-4o-mini",
                    messages: [
                        {
                            role: "system",
                            content: "You are a helpful event discovery assistant. Always respond with valid JSON arrays only."
                        },
                        {
                            role: "user",
                            content: prompt
                        }
                    ],
                    temperature: 0.7,
                    max_tokens: 2000,
                    response_format: { type: "json_object" }
                });
            },
            "OpenAI API call"
        );

        const content = response.choices[0]?.message?.content;

        if (!content) {
            throw new Error("No content in OpenAI response");
        }

        logger.info("OpenAI response received successfully");

        // Parse the JSON response
        let events: DiscoveredEvent[];
        try {
            const parsed = JSON.parse(content);
            // Handle both array and object with events array
            events = Array.isArray(parsed) ? parsed : (parsed.events || []);
        } catch (parseError) {
            logger.error("Failed to parse OpenAI response as JSON", { content, parseError });
            throw new HttpsError(
                "internal",
                "Invalid JSON response from OpenAI"
            );
        }

        // Validate and clean events
        const validEvents = events.filter(event => {
            return (
                event.eventName &&
                event.description &&
                event.date &&
                event.location &&
                event.category
            );
        });

        logger.info(`Successfully discovered ${validEvents.length} valid events`);

        return validEvents;

    } catch (error: any) {
        logger.error("Event discovery failed", error);
        throw error;
    }
}

/**
 * Validate event data before saving to Firestore
 */
export function validateEvent(event: DiscoveredEvent): boolean {
    try {
        // Check required fields
        if (!event.eventName || !event.description || !event.date) {
            return false;
        }

        // Validate date format (YYYY-MM-DD)
        const dateRegex = /^\d{4}-\d{2}-\d{2}$/;
        if (!dateRegex.test(event.date)) {
            return false;
        }

        // Check date is in the future
        const eventDate = new Date(event.date);
        const today = new Date();
        today.setHours(0, 0, 0, 0);

        if (eventDate < today) {
            return false;
        }

        // Validate category
        const validCategories = ['Networking', 'Workshop', 'Conference', 'Competition', 'Other'];
        if (!validCategories.includes(event.category)) {
            return false;
        }

        return true;
    } catch (error) {
        logger.warn("Event validation error", { event, error });
        return false;
    }
}
