import jwt from 'jsonwebtoken';
const API_KEY_HEADER = 'x-api-key';
const JWT_SECRET = process.env.JWT_SECRET || 'REPLACE_WITH_STRONG_SECRET_IN_PRODUCTION';
/**
 * Simple API key middleware (optional)
 * Check if request includes valid API key in headers
 * Set API_KEY env var to enable
 */
export function apiKeyAuth(req, res, next) {
    const expectedKey = process.env.API_KEY;
    if (!expectedKey) {
        // API key auth not configured, skip
        return next();
    }
    const providedKey = req.headers[API_KEY_HEADER];
    if (providedKey !== expectedKey) {
        res.status(401).json({ success: false, message: 'Unauthorized: Invalid API key' });
        return;
    }
    next();
}
/**
 * JWT authentication middleware (optional)
 * Verifies Bearer token from Authorization header
 * Attaches decoded user payload to req.user
 */
export function jwtAuth(req, res, next) {
    const authHeader = req.headers.authorization;
    if (!authHeader || !authHeader.startsWith('Bearer ')) {
        res.status(401).json({ success: false, message: 'Unauthorized: Missing or invalid token' });
        return;
    }
    const token = authHeader.slice(7); // remove 'Bearer '
    try {
        const decoded = jwt.verify(token, JWT_SECRET);
        req.user = decoded; // attach user info to request
        next();
    }
    catch (err) {
        res.status(401).json({
            success: false,
            message: 'Unauthorized: Token verification failed',
            details: err?.message,
        });
    }
}
/**
 * Utility to sign a JWT for testing or client generation
 * Example payload: { userId: '123', email: 'user@example.com' }
 */
export function signJWT(payload, expiresIn = '24h') {
    return jwt.sign(payload, JWT_SECRET, { expiresIn });
}
