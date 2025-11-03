#!/bin/bash
# Deploy beta builds to both iOS and Android

set -e

echo "🚀 Deploying Beta Builds to iOS and Android..."
echo ""

# Deploy iOS
echo "================================"
echo "  iOS DEPLOYMENT"
echo "================================"
./scripts/deploy-ios-beta.sh

echo ""
echo "================================"
echo "  ANDROID DEPLOYMENT"
echo "================================"
./scripts/deploy-android-beta.sh

echo ""
echo "✅ All Beta deployments complete!"
echo "📱 Builds will be available shortly on TestFlight and Play Console"
