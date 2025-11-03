#!/bin/bash
# Deploy Android beta build to Play Console Internal Testing locally

set -e

echo "🚀 Deploying Android Beta to Play Console..."
echo ""

# Check if we're in the right directory
if [ ! -f "pubspec.yaml" ]; then
    echo "❌ Error: Must run from project root directory"
    exit 1
fi

# Check if Fastlane is installed
if ! command -v fastlane &> /dev/null; then
    echo "⚠️  Fastlane not found. Installing..."
    gem install fastlane
fi

# Navigate to Android directory
cd android

# Install/update dependencies
echo "📦 Installing dependencies..."
bundle install

# Run Fastlane beta lane
echo "🏗️  Building and uploading to Play Console..."
bundle exec fastlane beta

echo ""
echo "✅ Android Beta deployment complete!"
echo "📱 Build is now in Play Console Internal Testing track"
