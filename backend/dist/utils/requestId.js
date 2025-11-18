/**
 * Request ID generation helper
 * Format: req_{YYYYMMDDTHHmmss}_{8charRand}
 * Example: req_20251118T142530_A9f3dK2Q
 */
export function generateRequestId(date = new Date()) {
    // Use UTC for consistency
    const year = date.getUTCFullYear();
    const month = String(date.getUTCMonth() + 1).padStart(2, '0');
    const day = String(date.getUTCDate()).padStart(2, '0');
    const hours = String(date.getUTCHours()).padStart(2, '0');
    const minutes = String(date.getUTCMinutes()).padStart(2, '0');
    const seconds = String(date.getUTCSeconds()).padStart(2, '0');
    const timestamp = `${year}${month}${day}T${hours}${minutes}${seconds}`;
    const rand = randomSegment(8);
    return `req_${timestamp}_${rand}`;
}
function randomSegment(length) {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
    let out = '';
    // Use crypto if available (Node 15+) fallback to Math.random
    const useCrypto = typeof crypto !== 'undefined' && typeof crypto.getRandomValues === 'function';
    if (useCrypto) {
        const array = new Uint32Array(length);
        crypto.getRandomValues(array);
        for (let i = 0; i < length; i++)
            out += chars[array[i] % chars.length];
    }
    else {
        for (let i = 0; i < length; i++)
            out += chars[Math.floor(Math.random() * chars.length)];
    }
    return out;
}
/** Simple validation helper */
export function isRequestId(id) {
    return /^req_\d{8}T\d{6}_[A-Za-z0-9]{8}$/.test(id);
}
// Example (remove or comment out in prod):
// console.log(generateRequestId());
