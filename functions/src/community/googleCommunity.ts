import * as functions from "firebase-functions";
import * as logger from "firebase-functions/logger";
import * as admin from "firebase-admin";
import fetch from "node-fetch";
import { CSE_KEY, CSE_CX, validateCSEConfig, CACHE_TTL, RATE_LIMIT } from "../config";

/**
 * Cache and rate limiting helpers
 */
const db = admin.firestore();
const CACHE_COLLECTION = "community_cache";
const RATE_LIMIT_COLLECTION = "community_rate_limits";

interface CacheEntry {
    key: string;
    data: any;
    expiresAt: admin.firestore.Timestamp;
    createdAt: admin.firestore.Timestamp;
}

/**
 * Get cached data if valid
 */
async function getCache(key: string): Promise<any | null> {
    try {
        const doc = await db.collection(CACHE_COLLECTION).doc(key).get();
        if (!doc.exists) return null;

        const data = doc.data() as CacheEntry;
        const now = admin.firestore.Timestamp.now();

        if (data.expiresAt.toMillis() > now.toMillis()) {
            logger.info(`Cache HIT for key: ${key}`);
            return data.data;
        }

        logger.info(`Cache EXPIRED for key: ${key}`);
        return null;
    } catch (err) {
        logger.error("Cache read error", err);
        return null;
    }
}

/**
 * Set cache data with TTL
 */
async function setCache(key: string, data: any, ttlMs: number): Promise<void> {
    try {
        const now = admin.firestore.Timestamp.now();
        const expiresAt = admin.firestore.Timestamp.fromMillis(
            now.toMillis() + ttlMs
        );

        await db
            .collection(CACHE_COLLECTION)
            .doc(key)
            .set({
                key,
                data,
                expiresAt,
                createdAt: now,
            });

        logger.info(`Cache SET for key: ${key}, TTL: ${ttlMs}ms`);
    } catch (err) {
        logger.error("Cache write error", err);
    }
}

/**
 * Check rate limit for user/IP
 */
async function checkRateLimit(userId: string, endpoint: string): Promise<boolean> {
    try {
        const key = `${userId}:${endpoint}`;
        const doc = await db.collection(RATE_LIMIT_COLLECTION).doc(key).get();

        const now = Date.now();
        const windowStart = now - RATE_LIMIT.WINDOW_MS;

        if (!doc.exists) {
            await db
                .collection(RATE_LIMIT_COLLECTION)
                .doc(key)
                .set({
                    calls: [now],
                    lastReset: now,
                });
            return true;
        }

        const data = doc.data() as { calls: number[]; lastReset: number };
        const recentCalls = data.calls.filter((timestamp) => timestamp > windowStart);

        if (recentCalls.length >= RATE_LIMIT.MAX_CALLS_PER_HOUR) {
            logger.warn(`Rate limit exceeded for ${key}`);
            return false;
        }

        recentCalls.push(now);
        await db
            .collection(RATE_LIMIT_COLLECTION)
            .doc(key)
            .update({
                calls: recentCalls,
                lastReset: now,
            });

        return true;
    } catch (err) {
        logger.error("Rate limit check error", err);
        return true; // Allow on error
    }
}

/**
 * Fetch from Google CSE API
 */
async function searchGoogleCSE(query: string, numResults = 10): Promise<any[]> {
    validateCSEConfig();

    const url = new URL("https://www.googleapis.com/customsearch/v1");
    url.searchParams.set("key", CSE_KEY!);
    url.searchParams.set("cx", CSE_CX!);
    url.searchParams.set("q", query);
    url.searchParams.set("num", numResults.toString());

    logger.info(`CSE Query: ${query}`);

    try {
        const response = await fetch(url.toString());

        if (!response.ok) {
            const errorText = await response.text();
            logger.error(`CSE API error: ${response.status} - ${errorText}`);
            throw new Error(`Google CSE API error: ${response.statusText}`);
        }

        const data = await response.json();
        return data.items || [];
    } catch (err: any) {
        logger.error("CSE fetch error", err);
        throw new Error("Failed to fetch from Google Custom Search");
    }
}

/**
 * Extract hashtags from text
 */
function extractHashtags(text: string): string[] {
    const regex = /(?:^|\s)#([A-Za-z0-9_]{3,30})/g;
    const hashtags: string[] = [];
    let match;

    while ((match = regex.exec(text)) !== null) {
        hashtags.push(match[1]);
    }

    return hashtags;
}

/**
 * Callable Function: Fetch trending hashtags
 */
export const communityFetchHashtags = functions.https.onCall(
    async (data, context) => {
        try {
            // Authentication check
            if (!context.auth) {
                throw new functions.https.HttpsError(
                    "unauthenticated",
                    "User must be authenticated"
                );
            }

            const userId = context.auth.uid;
            const endpoint = "hashtags";

            // Rate limiting
            const allowed = await checkRateLimit(userId, endpoint);
            if (!allowed) {
                throw new functions.https.HttpsError(
                    "resource-exhausted",
                    "Rate limit exceeded. Please try again later."
                );
            }

            // Check cache
            const cacheKey = "hashtags:uae:v1";
            const cached = await getCache(cacheKey);
            if (cached) {
                return { hashtags: cached, fromCache: true };
            }

            // Build search query for UAE business hashtags
            const query =
                'site:twitter.com OR site:linkedin.com "#" (UAE OR Dubai OR "Abu Dhabi") (startup OR business OR SME OR visa OR "trade license" OR entrepreneur OR freezone)';

            // Fetch from Google CSE
            const results = await searchGoogleCSE(query, 10);

            // Extract and count hashtags
            const hashtagCounts = new Map<string, number>();

            results.forEach((item) => {
                const text = `${item.title || ""} ${item.snippet || ""}`;
                const tags = extractHashtags(text);

                tags.forEach((tag) => {
                    const normalizedTag = tag.toLowerCase();
                    hashtagCounts.set(
                        normalizedTag,
                        (hashtagCounts.get(normalizedTag) || 0) + 1
                    );
                });
            });

            // Sort by count and take top 20
            const sortedHashtags = Array.from(hashtagCounts.entries())
                .sort((a, b) => b[1] - a[1])
                .slice(0, 20)
                .map(([tag, count]) => ({
                    tag: `#${tag.charAt(0).toUpperCase() + tag.slice(1)}`,
                    count,
                }));

            // Cache results
            await setCache(cacheKey, sortedHashtags, CACHE_TTL.HASHTAGS);

            return { hashtags: sortedHashtags, fromCache: false };
        } catch (err: any) {
            logger.error("communityFetchHashtags error", err);

            if (err instanceof functions.https.HttpsError) {
                throw err;
            }

            throw new functions.https.HttpsError(
                "internal",
                "Failed to fetch trending hashtags"
            );
        }
    }
);

/**
 * Callable Function: Fetch business news
 */
export const communityFetchNews = functions.https.onCall(async (data, context) => {
    try {
        // Authentication check
        if (!context.auth) {
            throw new functions.https.HttpsError(
                "unauthenticated",
                "User must be authenticated"
            );
        }

        const userId = context.auth.uid;
        const endpoint = "news";
        const industry = data?.industry || "all";

        // Rate limiting
        const allowed = await checkRateLimit(userId, endpoint);
        if (!allowed) {
            throw new functions.https.HttpsError(
                "resource-exhausted",
                "Rate limit exceeded. Please try again later."
            );
        }

        // Check cache
        const cacheKey = `news:${industry}:v1`;
        const cached = await getCache(cacheKey);
        if (cached) {
            return { news: cached, fromCache: true };
        }

        // Build search query
        const industryTerm = industry !== "all" ? `${industry} ` : "";
        const query = `${industryTerm}business UAE (site:gulfnews.com OR site:khaleejtimes.com OR site:thenationalnews.com OR site:arabianbusiness.com) after:7d`;

        // Fetch from Google CSE
        const results = await searchGoogleCSE(query, 10);

        // Format news items
        const newsItems = results.map((item) => ({
            title: item.title || "Untitled",
            source: extractDomain(item.link || ""),
            url: item.link || "",
            snippet: item.snippet || "",
            publishedAt: item.pagemap?.metatags?.[0]?.["article:published_time"] || null,
        }));

        // Cache results
        await setCache(cacheKey, newsItems, CACHE_TTL.NEWS);

        return { news: newsItems, fromCache: false };
    } catch (err: any) {
        logger.error("communityFetchNews error", err);

        if (err instanceof functions.https.HttpsError) {
            throw err;
        }

        throw new functions.https.HttpsError(
            "internal",
            "Failed to fetch business news"
        );
    }
});

/**
 * Callable Function: Fetch upcoming events
 */
export const communityFetchEvents = functions.https.onCall(
    async (data, context) => {
        try {
            // Authentication check
            if (!context.auth) {
                throw new functions.https.HttpsError(
                    "unauthenticated",
                    "User must be authenticated"
                );
            }

            const userId = context.auth.uid;
            const endpoint = "events";
            const industry = data?.industry || "all";

            // Rate limiting
            const allowed = await checkRateLimit(userId, endpoint);
            if (!allowed) {
                throw new functions.https.HttpsError(
                    "resource-exhausted",
                    "Rate limit exceeded. Please try again later."
                );
            }

            // Check cache
            const cacheKey = `events:${industry}:v1`;
            const cached = await getCache(cacheKey);
            if (cached) {
                return { events: cached, fromCache: true };
            }

            // Build search query
            const industryTerm = industry !== "all" ? `${industry} ` : "";
            const query = `${industryTerm}business event conference expo meetup (Dubai OR "Abu Dhabi" OR Sharjah) UAE (date OR "this month" OR "next month" OR 2025)`;

            // Fetch from Google CSE
            const results = await searchGoogleCSE(query, 10);

            // Format event items
            const eventItems = results.map((item) => {
                const snippet = item.snippet || "";
                const title = item.title || "Untitled Event";

                return {
                    title,
                    url: item.link || "",
                    organizer: extractOrganizer(snippet),
                    whenStart: extractDate(snippet),
                    whenEnd: null,
                    venue: extractVenue(snippet),
                    city: extractCity(snippet, title),
                    industry: industry !== "all" ? industry : null,
                };
            });

            // Cache results
            await setCache(cacheKey, eventItems, CACHE_TTL.EVENTS);

            return { events: eventItems, fromCache: false };
        } catch (err: any) {
            logger.error("communityFetchEvents error", err);

            if (err instanceof functions.https.HttpsError) {
                throw err;
            }

            throw new functions.https.HttpsError(
                "internal",
                "Failed to fetch upcoming events"
            );
        }
    }
);

/**
 * Helper: Extract domain from URL
 */
function extractDomain(url: string): string {
    try {
        const domain = new URL(url).hostname;
        return domain.replace("www.", "");
    } catch {
        return "Unknown Source";
    }
}

/**
 * Helper: Extract organizer from snippet
 */
function extractOrganizer(snippet: string): string {
    const orgPatterns = [
        /organized by ([^.,]+)/i,
        /hosted by ([^.,]+)/i,
        /presented by ([^.,]+)/i,
    ];

    for (const pattern of orgPatterns) {
        const match = snippet.match(pattern);
        if (match) {
            return match[1].trim();
        }
    }

    return "TBA";
}

/**
 * Helper: Extract date from snippet (simple parsing)
 */
function extractDate(snippet: string): string | null {
    // Look for date patterns like "December 15, 2025" or "15 Dec 2025"
    const datePatterns = [
        /\b(\d{1,2}\s+(?:Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec)[a-z]*\s+\d{4})\b/i,
        /\b((?:Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec)[a-z]*\s+\d{1,2},?\s+\d{4})\b/i,
        /\b(\d{4}-\d{2}-\d{2})\b/,
    ];

    for (const pattern of datePatterns) {
        const match = snippet.match(pattern);
        if (match) {
            return match[1];
        }
    }

    return null;
}

/**
 * Helper: Extract venue from snippet
 */
function extractVenue(snippet: string): string | null {
    const venuePatterns = [
        /at ([^.,]+ Center)/i,
        /at ([^.,]+ Hotel)/i,
        /venue: ([^.,]+)/i,
        /@ ([^.,]+)/,
    ];

    for (const pattern of venuePatterns) {
        const match = snippet.match(pattern);
        if (match) {
            return match[1].trim();
        }
    }

    return null;
}

/**
 * Helper: Extract city from snippet or title
 */
function extractCity(snippet: string, title: string): string | null {
    const text = `${title} ${snippet}`;
    const cities = ["Dubai", "Abu Dhabi", "Sharjah", "Ajman", "Ras Al Khaimah"];

    for (const city of cities) {
        if (text.includes(city)) {
            return city;
        }
    }

    return "UAE";
}
