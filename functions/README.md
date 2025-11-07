# Firebase Functions - Environment Setup

This directory contains Firebase Cloud Functions for the WAZEET application.

## 🔐 Secure Environment Variable Handling

This project uses secure environment variable management to protect API keys and sensitive data.

### Local Development (Emulators)

1. **Create `.env.local` file** (one-time setup):
   ```bash
   cd functions
   echo "OPENAI_API_KEY=sk-your-local-key-here" > .env.local
   ```

2. **The `.env.local` file is automatically excluded from Git** (via `.gitignore`)

3. **Start emulators**:
   ```bash
   npm run serve
   # or
   npm run emulate
   # or
   firebase emulators:start --only functions
   ```

4. **Test with smoke script**:
   ```bash
   # In one terminal: start emulators
   npm run emulate
   
   # In another terminal: run smoke test
   npm run test:smoke
   ```

### Production Deployment

For deployed functions, use Firebase Functions config:

```bash
# Set the OpenAI API key (ONE-TIME SETUP)
firebase functions:config:set openai.key="sk-your-production-key-here"

# Verify it's set (key will be shown - be careful!)
firebase functions:config:get

# Deploy the function
firebase deploy --only functions:aiBusinessChat
```

### 🔄 Key Rotation

If your API key is compromised or you want to rotate keys:

**For Local Development:**
```bash
# 1. Get new key from OpenAI dashboard
# 2. Update .env.local
echo "OPENAI_API_KEY=sk-new-key-here" > functions/.env.local

# 3. Restart emulators
cd functions && npm run emulate
```

**For Production:**
```bash
# 1. Set new key in Firebase config
firebase functions:config:set openai.key="sk-new-production-key"

# 2. Redeploy function
firebase deploy --only functions:aiBusinessChat

# 3. Revoke old key in OpenAI dashboard
# Go to: https://platform.openai.com/api-keys
```

**⚠️ CRITICAL: Never commit secrets**
- Never commit `.env.local` to Git (already in `.gitignore`)
- Never log or echo API keys in CI/CD pipelines
- Never share keys in chat, email, or Slack
- Rotate keys immediately if accidentally exposed
- Use separate keys for development and production

### How It Works

The `aiBusinessChat` function automatically detects the environment:

```typescript
// In functions/src/aiBusinessChat.ts
const getOpenAIKey = (): string => {
    // Local emulators: reads from .env.local via dotenv
    // Deployed: reads from functions.config()
    const key = process.env.OPENAI_API_KEY || functions.config().openai?.key;
    if (!key) {
        throw new Error('OpenAI API key not configured');
    }
    return key;
};
```

## 📦 Available Functions

### `aiBusinessChat`

AI-powered business consultation with OpenAI streaming.

**Endpoint:** `https://us-central1-business-setup-application.cloudfunctions.net/aiBusinessChat`

**Features:**
- Real-time streaming responses (SSE)
- Tool calling for freezone recommendations
- Secure API key handling
- Firebase Auth required

**Local Test:**
```bash
npm run serve
# Function available at: http://127.0.0.1:5001/business-setup-application/us-central1/aiBusinessChat
```

## 🚀 Quick Start

### First Time Setup

1. **Install dependencies**:
   ```bash
   npm install
   ```

2. **Create `.env.local`** (for local development):
   ```bash
   echo "OPENAI_API_KEY=sk-your-key-here" > .env.local
   ```

3. **Configure production key**:
   ```bash
   firebase functions:config:set openai.key="sk-your-production-key"
   ```

4. **Build TypeScript**:
   ```bash
   npm run build
   ```

5. **Test locally**:
   ```bash
   npm run serve
   ```

6. **Deploy to production**:
   ```bash
   npm run deploy
   # or
   firebase deploy --only functions:aiBusinessChat
   ```

## 🔧 Development Commands

```bash
# Build TypeScript
npm run build

# Watch mode (rebuild on changes)
npm run build:watch

# Start emulators
npm run serve

# Deploy all functions
npm run deploy

# Deploy specific function
firebase deploy --only functions:aiBusinessChat

# View logs
npm run logs
# or
firebase functions:log --only aiBusinessChat
```

## 🔒 Security Best Practices

### ✅ DO:
- ✅ Use `.env.local` for local development
- ✅ Use Firebase Functions config for production
- ✅ Keep `.env.local` in `.gitignore`
- ✅ Rotate keys regularly (every 90 days recommended)
- ✅ Use separate keys for dev/prod
- ✅ Revoke compromised keys immediately
- ✅ Monitor OpenAI usage dashboard for anomalies
- ✅ Enable Firebase Auth for all endpoints
- ✅ Use rate limiting to prevent abuse

### ❌ DON'T:
- ❌ Hard-code API keys in source files
- ❌ Commit `.env.local` to Git
- ❌ Share API keys in chat/email
- ❌ Use production keys in local development
- ❌ Expose keys in logs or error messages
- ❌ Log request/response bodies (may contain PII)
- ❌ Disable rate limiting in production
- ❌ Allow unauthenticated requests

### 🛡️ Production Hardening

The `aiBusinessChat` function includes:

1. **Environment Validation**
   - `requireEnv()` helper ensures API key is configured
   - Throws clear error if key is missing
   - Dual-mode support (`.env.local` or `functions.config()`)

2. **Secret Redaction**
   - `redactSecrets()` automatically removes `sk-*` patterns from logs
   - All errors logged with redaction
   - No request bodies logged (prevent PII leaks)

3. **Authentication Guard (401)**
   - Requires Firebase Auth token in `Authorization: Bearer <token>` header
   - Returns 401 for missing or invalid tokens
   - Validates token with Firebase Admin SDK

4. **Rate Limiting (429)**
   - In-memory per-user rate limiting
   - 1 request per second, burst of 3
   - Returns 429 with friendly message when exceeded
   - Automatic cleanup of old entries

5. **SSE Streaming Sanity**
   - Proper `Content-Type: text/event-stream` headers
   - Heartbeat messages to keep connection alive
   - Clean error handling and stream closure
   - Timeout protection (60s function timeout)

6. **Error Handling**
   - Never exposes sensitive data in error responses
   - Different messages for rate limits, timeouts, auth failures
   - Graceful SSE stream closure on errors
   - Comprehensive logging for debugging (without secrets)

## 📊 Monitoring

### View Function Logs

```bash
# Real-time logs
firebase functions:log --only aiBusinessChat --follow

# Last hour
firebase functions:log --only aiBusinessChat --since 1h

# With errors only
firebase functions:log --only aiBusinessChat --only-errors
```

### Firebase Console

- **Functions Dashboard:** https://console.firebase.google.com/project/business-setup-application/functions
- **Logs:** https://console.firebase.google.com/project/business-setup-application/logs

## 🧪 Testing

### Unit Tests

Run unit tests for environment handling, rate limiting, and secret redaction:

```bash
cd functions

# Install test dependencies (first time)
npm install

# Run all unit tests
npm run test:unit

# Or with mocha directly
npx mocha --require ts-node/register 'src/**/*.test.ts'
```

### Smoke Test (E2E)

Automated smoke test that verifies the function end-to-end:

```bash
# Start emulators in one terminal
cd functions
npm run emulate

# Run smoke test in another terminal
npm run test:smoke

# Or with custom URL/token
FUNCTION_URL=http://localhost:5001/... FIREBASE_TOKEN=xyz node scripts/smoke_chat.mjs
```

The smoke test verifies:
- ✅ HTTP 200 response
- ✅ SSE streaming with content chunks
- ✅ Tool call execution (recommend_freezones)
- ✅ Proper stream completion

### Manual Testing with Emulators

```bash
# Start emulators
npm run serve

# In another terminal, test with curl
curl -X POST \
  -H "Authorization: Bearer YOUR_FIREBASE_TOKEN" \
  -H "Content-Type: application/json" \
  -H "Accept: text/event-stream" \
  -d '{"messages":[{"role":"user","content":"I want to start an e-commerce business"}],"userId":"test"}' \
  http://127.0.0.1:5001/business-setup-application/us-central1/aiBusinessChat
```

### Test Deployed Function

```bash
curl -X POST \
  -H "Authorization: Bearer YOUR_FIREBASE_TOKEN" \
  -H "Content-Type: application/json" \
  -H "Accept: text/event-stream" \
  -d '{"messages":[{"role":"user","content":"Hello"}],"userId":"test"}' \
  https://us-central1-business-setup-application.cloudfunctions.net/aiBusinessChat
```

### Test Rate Limiting

```bash
# Send 4 rapid requests (4th should fail with 429)
for i in {1..4}; do
  echo "Request $i:"
  curl -X POST \
    -H "Authorization: Bearer YOUR_TOKEN" \
    -H "Content-Type: application/json" \
    -d '{"messages":[{"role":"user","content":"test"}],"userId":"test"}' \
    http://localhost:5001/.../aiBusinessChat
  echo ""
done
```

### CI/CD Testing

GitHub Actions automatically runs tests on every push:

```yaml
# .github/workflows/qa.yml
env:
  OPENAI_API_KEY: ${{ secrets.OPENAI_API_KEY }}  # ⚠️ Never logged

steps:
  - run: npm run test:unit  # Unit tests
  - run: npm run build      # TypeScript compilation
```

**⚠️ Important:** 
- Never log `${{ secrets.OPENAI_API_KEY }}` in CI/CD
- Tests should mock OpenAI client (no real API calls in unit tests)
- Smoke tests can use emulators (no production API usage)

## 🐛 Troubleshooting

### "OpenAI API key not configured"

**Local:**
- Check `.env.local` exists in `functions/` directory
- Verify `OPENAI_API_KEY` is set correctly
- Restart emulators after creating `.env.local`

**Deployed:**
- Run `firebase functions:config:get` to verify key is set
- Set with `firebase functions:config:set openai.key="sk-..."`
- Redeploy function after setting config

### "Module not found: 'dotenv/config'"

```bash
cd functions
npm install dotenv
npm run build
```

### TypeScript Compilation Errors

```bash
# Clean and rebuild
rm -rf lib/
npm run build
```

### Emulators Not Starting

```bash
# Kill existing processes
pkill -f firebase
firebase emulators:start --only functions
```

## 📝 Environment Variables Reference

### Local Development (`.env.local`)

| Variable | Description | Example |
|----------|-------------|---------|
| `OPENAI_API_KEY` | OpenAI API key for local testing | `sk-proj-...` |

### Production (Firebase Config)

| Config Path | Description | Set With |
|------------|-------------|----------|
| `openai.key` | OpenAI API key for production | `firebase functions:config:set openai.key="sk-..."` |

## 🔄 CI/CD Integration

### GitHub Actions

Add your OpenAI key as a GitHub secret:

1. Go to: **Settings → Secrets and variables → Actions**
2. Add new secret: `OPENAI_API_KEY`
3. Use in workflow:

```yaml
- name: Deploy to Firebase
  env:
    OPENAI_API_KEY: ${{ secrets.OPENAI_API_KEY }}
  run: |
    cd functions
    echo "OPENAI_API_KEY=$OPENAI_API_KEY" > .env.local
    npm run build
    firebase deploy --only functions:aiBusinessChat --token ${{ secrets.FIREBASE_TOKEN }}
```

## 📚 Additional Resources

- **Firebase Functions Documentation:** https://firebase.google.com/docs/functions
- **OpenAI API Reference:** https://platform.openai.com/docs/api-reference
- **TypeScript Documentation:** https://www.typescriptlang.org/docs

## 🆘 Support

- **Firebase Console:** https://console.firebase.google.com/project/business-setup-application
- **OpenAI Dashboard:** https://platform.openai.com/usage
- **Functions Logs:** `firebase functions:log --only aiBusinessChat`

---

**Security Note:** Never commit API keys or `.env.local` to version control. Always use environment variables or Firebase Functions config for sensitive data.
