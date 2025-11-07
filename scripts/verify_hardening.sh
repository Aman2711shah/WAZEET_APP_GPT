#!/bin/bash

# Production Hardening Verification Script
# This script verifies all security measures are in place

echo "🔐 Production Hardening Verification"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

pass_count=0
fail_count=0

function check_pass() {
    echo -e "${GREEN}✅ PASS${NC}: $1"
    ((pass_count++))
}

function check_fail() {
    echo -e "${RED}❌ FAIL${NC}: $1"
    ((fail_count++))
}

function check_warn() {
    echo -e "${YELLOW}⚠️  WARN${NC}: $1"
}

# 1. Check .env.local is gitignored
echo "1️⃣  Checking Git protection..."
if git check-ignore -q functions/.env.local 2>/dev/null; then
    check_pass ".env.local is gitignored"
else
    check_fail ".env.local is NOT gitignored (security risk!)"
fi

# 2. Check for hardcoded API keys in source
echo ""
echo "2️⃣  Checking for hardcoded API keys..."
if grep -r "sk-proj-" functions/src/*.ts 2>/dev/null | grep -v "test" | grep -v "REDACTED"; then
    check_fail "Found potential hardcoded API keys in source!"
else
    check_pass "No hardcoded API keys in TypeScript source"
fi

if grep -r "sk-proj-" lib/**/*.dart 2>/dev/null; then
    check_fail "Found potential hardcoded API keys in Dart!"
else
    check_pass "No hardcoded API keys in Dart source"
fi

# 3. Check TypeScript compiles
echo ""
echo "3️⃣  Checking TypeScript compilation..."
cd functions
if npm run build > /dev/null 2>&1; then
    check_pass "TypeScript compiles without errors"
else
    check_fail "TypeScript compilation failed"
fi

# 4. Check test files exist
echo ""
echo "4️⃣  Checking test infrastructure..."
if [ -f "src/aiBusinessChat.test.ts" ]; then
    check_pass "Unit test file exists"
else
    check_fail "Unit test file missing"
fi

if [ -f "../scripts/smoke_chat.mjs" ]; then
    check_pass "Smoke test script exists"
else
    check_fail "Smoke test script missing"
fi

# 5. Check package.json has test scripts
echo ""
echo "5️⃣  Checking npm scripts..."
if grep -q '"test":' package.json; then
    check_pass "npm test script configured"
else
    check_fail "npm test script missing"
fi

if grep -q '"test:smoke":' package.json; then
    check_pass "npm test:smoke script configured"
else
    check_fail "npm test:smoke script missing"
fi

if grep -q '"emulate":' package.json; then
    check_pass "npm emulate script configured"
else
    check_fail "npm emulate script missing"
fi

# 6. Check test dependencies installed
echo ""
echo "6️⃣  Checking test dependencies..."
if npm list chai > /dev/null 2>&1; then
    check_pass "chai installed"
else
    check_fail "chai not installed (run: npm install)"
fi

if npm list mocha > /dev/null 2>&1; then
    check_pass "mocha installed"
else
    check_fail "mocha not installed (run: npm install)"
fi

# 7. Check GitHub Actions workflow
echo ""
echo "7️⃣  Checking CI/CD configuration..."
cd ..
if grep -q "OPENAI_API_KEY" .github/workflows/qa.yml; then
    check_pass "GitHub Actions uses OPENAI_API_KEY secret"
else
    check_fail "GitHub Actions not configured for OPENAI_API_KEY"
fi

# 8. Check Flutter service configuration
echo ""
echo "8️⃣  Checking Flutter service..."
if grep -q "business-setup-application" lib/services/ai_business_expert_service_v2.dart; then
    check_pass "Flutter service points to correct Firebase project"
else
    check_fail "Flutter service URL incorrect"
fi

if grep -q "maxRetries = 3" lib/services/ai_business_expert_service_v2.dart; then
    check_pass "Flutter service has retry logic (3 attempts)"
else
    check_warn "Flutter service retry configuration not found"
fi

if grep -q "Duration(seconds: 15)" lib/services/ai_business_expert_service_v2.dart; then
    check_pass "Flutter service has 15s timeout"
else
    check_warn "Flutter service timeout configuration not found"
fi

# 9. Check documentation exists
echo ""
echo "9️⃣  Checking documentation..."
if [ -f "functions/README.md" ]; then
    if grep -q "Secure Environment Variable Handling" functions/README.md; then
        check_pass "functions/README.md has security documentation"
    else
        check_warn "functions/README.md missing security section"
    fi
else
    check_fail "functions/README.md not found"
fi

if [ -f "PRODUCTION_HARDENING_COMPLETE.md" ]; then
    check_pass "Production hardening summary exists"
else
    check_warn "PRODUCTION_HARDENING_COMPLETE.md not found"
fi

# 10. Check aiBusinessChat.ts has security features
echo ""
echo "🔟 Checking security features in aiBusinessChat.ts..."
if grep -q "requireEnv" functions/src/aiBusinessChat.ts; then
    check_pass "Environment validation (requireEnv) implemented"
else
    check_fail "Environment validation missing"
fi

if grep -q "redactSecrets" functions/src/aiBusinessChat.ts; then
    check_pass "Secret redaction implemented"
else
    check_fail "Secret redaction missing"
fi

if grep -q "checkRateLimit" functions/src/aiBusinessChat.ts; then
    check_pass "Rate limiting implemented"
else
    check_fail "Rate limiting missing"
fi

if grep -q "401" functions/src/aiBusinessChat.ts && grep -q "Unauthorized" functions/src/aiBusinessChat.ts; then
    check_pass "Authentication guard (401) implemented"
else
    check_fail "Authentication guard missing"
fi

if grep -q "429" functions/src/aiBusinessChat.ts && grep -q "Rate limit" functions/src/aiBusinessChat.ts; then
    check_pass "Rate limit response (429) implemented"
else
    check_fail "Rate limit response missing"
fi

if grep -q "text/event-stream" functions/src/aiBusinessChat.ts; then
    check_pass "SSE headers configured"
else
    check_fail "SSE headers missing"
fi

if grep -q "heartbeat" functions/src/aiBusinessChat.ts; then
    check_pass "SSE heartbeat implemented"
else
    check_warn "SSE heartbeat not found"
fi

# Summary
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📊 Summary:"
echo ""
echo -e "  ${GREEN}✅ Passed: $pass_count${NC}"
echo -e "  ${RED}❌ Failed: $fail_count${NC}"
echo ""

if [ $fail_count -eq 0 ]; then
    echo -e "${GREEN}🎉 All checks passed! Production ready.${NC}"
    exit 0
else
    echo -e "${RED}⚠️  Some checks failed. Review and fix before deploying.${NC}"
    exit 1
fi
