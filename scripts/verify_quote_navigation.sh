#!/bin/bash
# Quick verification that quote feature navigation compiles

echo "Checking quote feature compilation..."

dart analyze lib/features/quote/ui/freezone_picker_screen.dart \
  lib/features/quote/ui/package_configurator_screen.dart \
  lib/features/quote/ui/price_breakdown_screen.dart \
  lib/ui/pages/freezone_quote_page.dart 2>&1 | grep -i error

if [ $? -eq 0 ]; then
  echo "❌ Errors found"
  exit 1
else
  echo "✅ No errors - navigation should work"
  exit 0
fi
