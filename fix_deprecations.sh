#!/bin/bash

# Script to fix withOpacity deprecations in Flutter files
# Replaces .withOpacity(value) with .withValues(alpha: value)

echo "Fixing withOpacity deprecations..."

# Find all Dart files in lib directory
find /Users/amanshah/WAZEET_APP_GPT/lib -name "*.dart" -type f | while read file; do
  if grep -q "withOpacity" "$file"; then
    echo "Processing: $file"
    # Use sed to replace withOpacity with withValues
    # Pattern: .withOpacity(x) -> .withValues(alpha: x)
    sed -i '' 's/\.withOpacity(\([^)]*\))/.withValues(alpha: \1)/g' "$file"
  fi
done

echo "Done! All withOpacity calls have been replaced with withValues."
