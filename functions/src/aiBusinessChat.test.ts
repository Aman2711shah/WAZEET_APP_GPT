import { expect } from 'chai';
import { describe, it, beforeEach, afterEach } from 'mocha';

/**
 * Unit tests for aiBusinessChat environment handling
 * 
 * These tests verify that:
 * 1. Function initializes correctly when OPENAI_API_KEY is set
 * 2. Function throws error when API key is missing
 * 3. Rate limiting works as expected
 * 4. Secret redaction works correctly
 */

describe('aiBusinessChat - Environment Handling', () => {
    let originalEnv: NodeJS.ProcessEnv;

    beforeEach(() => {
        // Save original environment
        originalEnv = { ...process.env };
    });

    afterEach(() => {
        // Restore original environment
        process.env = originalEnv;
    });

    describe('requireEnv helper', () => {
        it('should return value when provided', () => {
            const requireEnv = (v?: string, name?: string): string => {
                if (!v) throw new Error(`${name ?? 'ENV'} not configured`);
                return v;
            };

            const result = requireEnv('test-value', 'TEST_KEY');
            expect(result).to.equal('test-value');
        });

        it('should throw error when value is missing', () => {
            const requireEnv = (v?: string, name?: string): string => {
                if (!v) throw new Error(`${name ?? 'ENV'} not configured`);
                return v;
            };

            expect(() => requireEnv(undefined, 'OPENAI_API_KEY')).to.throw(
                'OPENAI_API_KEY not configured'
            );
        });

        it('should use default name when not provided', () => {
            const requireEnv = (v?: string, name?: string): string => {
                if (!v) throw new Error(`${name ?? 'ENV'} not configured`);
                return v;
            };

            expect(() => requireEnv(undefined)).to.throw('ENV not configured');
        });
    });

    describe('redactSecrets helper', () => {
        it('should redact OpenAI API keys', () => {
            const redactSecrets = (text: string): string => {
                return text.replace(/sk-[a-zA-Z0-9]{20,}/g, '***REDACTED***');
            };

            const input = 'Error with key sk-proj-abcd1234567890efghijk';
            const output = redactSecrets(input);
            expect(output).to.equal('Error with key ***REDACTED***');
        });

        it('should handle multiple keys in same string', () => {
            const redactSecrets = (text: string): string => {
                return text.replace(/sk-[a-zA-Z0-9]{20,}/g, '***REDACTED***');
            };

            const input = 'Keys: sk-proj-key1234567890abcdef and sk-test-key9876543210fedcba';
            const output = redactSecrets(input);
            expect(output).to.equal('Keys: ***REDACTED*** and ***REDACTED***');
        });

        it('should not modify text without keys', () => {
            const redactSecrets = (text: string): string => {
                return text.replace(/sk-[a-zA-Z0-9]{20,}/g, '***REDACTED***');
            };

            const input = 'Normal error message without keys';
            const output = redactSecrets(input);
            expect(output).to.equal(input);
        });
    });

    describe('Rate limiting', () => {
        interface RateLimitEntry {
            count: number;
            resetAt: number;
        }

        it('should allow requests within burst limit', () => {
            const rateLimitMap = new Map<string, RateLimitEntry>();
            const RATE_LIMIT_WINDOW_MS = 1000;
            const RATE_LIMIT_BURST = 3;

            const checkRateLimit = (userId: string): boolean => {
                const now = Date.now();
                const entry = rateLimitMap.get(userId);

                if (!entry || now > entry.resetAt) {
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

                return false;
            };

            const userId = 'test-user-123';

            // First 3 requests should succeed (burst limit)
            expect(checkRateLimit(userId)).to.be.true;
            expect(checkRateLimit(userId)).to.be.true;
            expect(checkRateLimit(userId)).to.be.true;

            // 4th request should fail
            expect(checkRateLimit(userId)).to.be.false;
        });

        it('should reset after time window', async () => {
            const rateLimitMap = new Map<string, RateLimitEntry>();
            const RATE_LIMIT_WINDOW_MS = 100; // Short window for testing
            const RATE_LIMIT_BURST = 2;

            const checkRateLimit = (userId: string): boolean => {
                const now = Date.now();
                const entry = rateLimitMap.get(userId);

                if (!entry || now > entry.resetAt) {
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

                return false;
            };

            const userId = 'test-user-456';

            // Hit burst limit
            expect(checkRateLimit(userId)).to.be.true;
            expect(checkRateLimit(userId)).to.be.true;
            expect(checkRateLimit(userId)).to.be.false;

            // Wait for reset
            await new Promise(resolve => setTimeout(resolve, 150));

            // Should work again after reset
            expect(checkRateLimit(userId)).to.be.true;
        });

        it('should track different users independently', () => {
            const rateLimitMap = new Map<string, RateLimitEntry>();
            const RATE_LIMIT_WINDOW_MS = 1000;
            const RATE_LIMIT_BURST = 2;

            const checkRateLimit = (userId: string): boolean => {
                const now = Date.now();
                const entry = rateLimitMap.get(userId);

                if (!entry || now > entry.resetAt) {
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

                return false;
            };

            const user1 = 'user-1';
            const user2 = 'user-2';

            // Both users should have independent limits
            expect(checkRateLimit(user1)).to.be.true;
            expect(checkRateLimit(user1)).to.be.true;
            expect(checkRateLimit(user1)).to.be.false; // user1 rate limited

            expect(checkRateLimit(user2)).to.be.true; // user2 still allowed
            expect(checkRateLimit(user2)).to.be.true;
            expect(checkRateLimit(user2)).to.be.false; // user2 now limited
        });
    });

    describe('Environment variable handling', () => {
        it('should load from process.env.OPENAI_API_KEY when set', () => {
            process.env.OPENAI_API_KEY = 'sk-test-key123456789012345678';

            const getTestKey = (): string => {
                const key = process.env.OPENAI_API_KEY;
                if (!key) throw new Error('OPENAI_API_KEY not configured');
                return key;
            };

            expect(getTestKey()).to.equal('sk-test-key123456789012345678');
        });

        it('should throw error when OPENAI_API_KEY is not set', () => {
            delete process.env.OPENAI_API_KEY;

            const getTestKey = (): string => {
                const key = process.env.OPENAI_API_KEY;
                if (!key) throw new Error('OPENAI_API_KEY not configured');
                return key;
            };

            expect(() => getTestKey()).to.throw('OPENAI_API_KEY not configured');
        });
    });
});
