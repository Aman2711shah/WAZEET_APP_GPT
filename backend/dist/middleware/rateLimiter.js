import rateLimit from 'express-rate-limit';
/**
 * Global rate limiter for all requests
 * Adjust windowMs and max based on your expected load
 */
export const globalLimiter = rateLimit({
    windowMs: 15 * 60 * 1000, // 15 minutes
    max: 100, // limit each IP to 100 requests per windowMs
    standardHeaders: true,
    legacyHeaders: false,
    message: 'Too many requests from this IP, please try again later.',
});
/**
 * Strict rate limiter for service application submissions
 * Prevents abuse on file upload endpoints
 */
export const applicationLimiter = rateLimit({
    windowMs: 60 * 60 * 1000, // 1 hour
    max: 10, // limit each IP to 10 submissions per hour
    standardHeaders: true,
    legacyHeaders: false,
    message: 'Too many service applications submitted, please try again in an hour.',
    skipSuccessfulRequests: false,
});
