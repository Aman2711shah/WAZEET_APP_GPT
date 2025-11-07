#!/bin/bash

# Quick verification script for new bottom sheet actions

echo "🔍 Verifying Bottom Sheet Implementation..."
echo ""

# Check if all new files exist
echo "📁 Checking files..."
files=(
  "lib/services/email_service.dart"
  "lib/services/phone_service.dart"
  "lib/services/ai_chat_service.dart"
  "lib/ui/widgets/share_freezones_sheet.dart"
  "lib/ui/widgets/ask_with_ai_sheet.dart"
  "lib/data/freezones_data.dart"
  "lib/data/mentions_data.dart"
)

all_exist=true
for file in "${files[@]}"; do
  if [ -f "$file" ]; then
    echo "✅ $file"
  else
    echo "❌ $file - MISSING"
    all_exist=false
  fi
done

echo ""
echo "📦 Checking Firebase Functions..."
if grep -q "exports.aiChat" functions/index.js; then
  echo "✅ aiChat function found in functions/index.js"
else
  echo "❌ aiChat function NOT found in functions/index.js"
fi

if grep -q '"openai"' functions/package.json; then
  echo "✅ openai package in package.json"
else
  echo "❌ openai package NOT in package.json"
fi

echo ""
echo "🔧 Checking pubspec.yaml dependencies..."
deps=("url_launcher" "shared_preferences" "cloud_functions")
for dep in "${deps[@]}"; do
  if grep -q "$dep" pubspec.yaml; then
    echo "✅ $dep"
  else
    echo "❌ $dep - MISSING"
  fi
done

echo ""
echo "📝 Checking freezone_detail_page.dart..."
if grep -q "Send Email" lib/ui/pages/freezone_detail_page.dart; then
  echo "✅ 'Send Email' action found"
else
  echo "❌ 'Send Email' action NOT found"
fi

if grep -q "Share Freezones & Mention" lib/ui/pages/freezone_detail_page.dart; then
  echo "✅ 'Share Freezones & Mention' action found"
else
  echo "❌ 'Share Freezones & Mention' action NOT found"
fi

if grep -q "Call Now" lib/ui/pages/freezone_detail_page.dart; then
  echo "✅ 'Call Now' action found"
else
  echo "❌ 'Call Now' action NOT found"
fi

if grep -q "Ask with AI" lib/ui/pages/freezone_detail_page.dart; then
  echo "✅ 'Ask with AI' action found"
else
  echo "❌ 'Ask with AI' action NOT found"
fi

if grep -q "Copy details" lib/ui/pages/freezone_detail_page.dart; then
  echo "⚠️  'Copy details' still found - should be removed"
else
  echo "✅ 'Copy details' removed successfully"
fi

echo ""
echo "🎯 Next Steps:"
echo "1. Set OpenAI API key: firebase functions:config:set openai.api_key=\"sk-...\""
echo "2. Deploy function: cd functions && firebase deploy --only functions:aiChat"
echo "3. Run the app and test all 4 actions"
echo "4. See AI_CHAT_SETUP_GUIDE.md for detailed instructions"
echo ""
echo "Done! 🎉"
