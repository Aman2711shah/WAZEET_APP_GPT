import * as functions from "firebase-functions";

/**
 * Configuration helper for Google Custom Search Engine
 * Set these values using:
 * firebase functions:config:set google.search_api_key="YOUR_KEY" google.search_cx="YOUR_CX"
 */

export const CSE_KEY = functions.config().google?.search_api_key;
export const CSE_CX = functions.config().google?.search_cx;

if (!CSE_KEY || !CSE_CX) {
    console.warn(
        "⚠️  Google CSE not configured. Set with: firebase functions:config:set google.search_api_key=KEY google.search_cx=CX"
    );
}

/**
 * Configuration helper for HubSpot CRM Integration
 * Set this value using:
 * firebase functions:config:set hubspot.api_key="YOUR_KEY"
 * For local development, use .env file with HUBSPOT_API_KEY
 */

export const HUBSPOT_API_KEY =
    process.env.HUBSPOT_API_KEY ||
    functions.config().hubspot?.api_key;

if (!HUBSPOT_API_KEY) {
    console.warn(
        "⚠️  HubSpot API key not configured. Set with: firebase functions:config:set hubspot.api_key=YOUR_KEY"
    );
}

/**
 * Validates that CSE configuration is available
 * @throws Error if configuration is missing
 */
export function validateCSEConfig(): void {
    if (!CSE_KEY || !CSE_CX) {
        throw new Error(
            "Google CSE not configured. Please set google.search_api_key and google.search_cx"
        );
    }
}

/**
 * Cache TTL configurations
 */
export const CACHE_TTL = {
    HASHTAGS: 4 * 60 * 60 * 1000, // 4 hours in milliseconds
    NEWS: 4 * 60 * 60 * 1000, // 4 hours
    EVENTS: 4 * 60 * 60 * 1000, // 4 hours
};

/**
 * Rate limiting configuration
 */
export const RATE_LIMIT = {
    MAX_CALLS_PER_HOUR: 20,
    WINDOW_MS: 60 * 60 * 1000, // 1 hour
};

/**
 * Supported industries for filtering
 */
export const INDUSTRIES = [
    "All Industries",
    "E-commerce",
    "FinTech",
    "Real Estate",
    "Logistics",
    "Tourism",
    "Web3",
    "Healthcare",
    "Education",
    "Food & Beverage",
] as const;

export type Industry = (typeof INDUSTRIES)[number];
