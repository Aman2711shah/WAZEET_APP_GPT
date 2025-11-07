#!/usr/bin/env node

/**
 * Smoke test for aiBusinessChat function
 * 
 * Usage:
 *   node scripts/smoke_chat.mjs
 * 
 * Environment:
 *   FUNCTION_URL - URL of the function (default: emulator)
 *   FIREBASE_TOKEN - Firebase auth token for testing
 */

import http from 'http';
import https from 'https';

const FUNCTION_URL = process.env.FUNCTION_URL ||
    'http://127.0.0.1:5001/business-setup-application/us-central1/aiBusinessChat';

const FIREBASE_TOKEN = process.env.FIREBASE_TOKEN || 'test-token';

console.log('🧪 Smoke Test: aiBusinessChat');
console.log('━'.repeat(50));
console.log(`📍 URL: ${FUNCTION_URL}`);
console.log('');

/**
 * Send a test message to the function
 */
async function testChat() {
    return new Promise((resolve, reject) => {
        const url = new URL(FUNCTION_URL);
        const client = url.protocol === 'https:' ? https : http;

        const payload = JSON.stringify({
            messages: [
                { role: 'user', content: 'I want to start an e-commerce business in Dubai' }
            ],
            userId: 'smoke-test-user-123',
            filters: {
                activity: 'e-commerce',
                budget: 'medium',
                emirate: 'Dubai'
            }
        });

        const options = {
            hostname: url.hostname,
            port: url.port || (url.protocol === 'https:' ? 443 : 80),
            path: url.pathname,
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
                'Authorization': `Bearer ${FIREBASE_TOKEN}`,
                'Accept': 'text/event-stream',
                'Content-Length': Buffer.byteLength(payload)
            }
        };

        console.log('📤 Sending request...');

        const req = client.request(options, (res) => {
            console.log(`📥 Status: ${res.statusCode}`);

            if (res.statusCode !== 200) {
                console.error('❌ Expected status 200');
                reject(new Error(`HTTP ${res.statusCode}`));
                return;
            }

            let buffer = '';
            let contentReceived = false;
            let toolCallReceived = false;
            let doneReceived = false;

            res.on('data', (chunk) => {
                buffer += chunk.toString();

                // Process complete SSE messages
                const lines = buffer.split('\n\n');
                buffer = lines.pop() || ''; // Keep incomplete message

                for (const line of lines) {
                    if (line.startsWith('data: ')) {
                        const jsonData = line.substring(6);
                        try {
                            const data = JSON.parse(jsonData);

                            if (data.type === 'content' && data.content) {
                                contentReceived = true;
                                process.stdout.write('.');
                            }

                            if (data.type === 'tool_call') {
                                toolCallReceived = true;
                                console.log(`\n🔧 Tool call: ${data.tool}`);
                            }

                            if (data.type === 'done') {
                                doneReceived = true;
                                console.log('\n✅ Stream completed');
                            }

                            if (data.type === 'error') {
                                console.error(`\n❌ Error: ${data.error}`);
                            }
                        } catch (e) {
                            console.warn(`\n⚠️  Failed to parse SSE: ${jsonData.substring(0, 50)}...`);
                        }
                    }
                }
            });

            res.on('end', () => {
                console.log('\n');
                console.log('━'.repeat(50));
                console.log('📊 Results:');
                console.log(`  ✅ HTTP 200: ${res.statusCode === 200}`);
                console.log(`  ✅ Content received: ${contentReceived}`);
                console.log(`  ✅ Tool call executed: ${toolCallReceived}`);
                console.log(`  ✅ Stream completed: ${doneReceived}`);
                console.log('');

                if (!contentReceived) {
                    console.error('❌ FAIL: No content received');
                    reject(new Error('No content received'));
                    return;
                }

                if (!doneReceived) {
                    console.error('❌ FAIL: Stream did not complete');
                    reject(new Error('Stream incomplete'));
                    return;
                }

                console.log('✅ PASS: All assertions passed');
                resolve({ contentReceived, toolCallReceived, doneReceived });
            });
        });

        req.on('error', (error) => {
            console.error('❌ Request failed:', error.message);
            reject(error);
        });

        req.setTimeout(30000, () => {
            console.error('❌ Request timeout (30s)');
            req.destroy();
            reject(new Error('Timeout'));
        });

        req.write(payload);
        req.end();
    });
}

// Run the test
(async () => {
    try {
        await testChat();
        process.exit(0);
    } catch (error) {
        console.error('\n❌ Smoke test failed:', error.message);
        process.exit(1);
    }
})();
