#!/bin/bash
# Deploy iOS beta build to TestFlight locally

set -e

echo "🚀 Deploying iOS Beta to TestFlight..."
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

# Navigate to iOS directory
cd ios

# Install/update dependencies
echo "📦 Installing dependencies..."
bundle install

# Run Fastlane beta lane
echo "🏗️  Building and uploading to TestFlight..."
bundle exec fastlane beta

echo ""
echo "✅ iOS Beta deployment complete!"
echo "📱 Build will be available in TestFlight shortly"
