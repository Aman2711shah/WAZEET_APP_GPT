import 'package:flutter/foundation.dart';

import 'dart:io';
import 'dart:convert';

/// Simple script to convert Activity List CSV to JSON for Firebase import
/// Run: dart lib/scripts/import_activity_list.dart
void main() async {
  debugPrint('🔄 Converting Activity List CSV to JSON for Firebase import...\n');

  final csvFile = File('/Users/amanshah/Downloads/Activity List - Master.csv');

  if (!await csvFile.exists()) {
    debugPrint('❌ CSV file not found!');
    debugPrint('Please ensure the file exists at:');
    debugPrint(csvFile.path);
    exit(1);
  }

  // Read CSV
  final lines = await csvFile.readAsLines();
  if (lines.isEmpty) {
    debugPrint('❌ CSV file is empty');
    exit(1);
  }

  // Parse headers
  final headers = lines[0].split(',').map((h) => h.trim()).toList();
  debugPrint('📋 Found ${lines.length - 1} activities');
  debugPrint('📊 Headers: ${headers.join(", ")}\n');

  // Convert to JSON array
  final List<Map<String, dynamic>> activities = [];

  for (int i = 1; i < lines.length; i++) {
    final values = _parseCsvLine(lines[i]);
    if (values.isEmpty || values.length < 2) continue;

    final activity = <String, dynamic>{};
    for (int j = 0; j < headers.length && j < values.length; j++) {
      final key = _camelCase(headers[j]);
      final value = values[j].trim();

      // Store value, convert to appropriate type if possible
      if (value.isEmpty) {
        activity[key] = null;
      } else if (_isNumeric(value)) {
        activity[key] = num.parse(value);
      } else if (value.toLowerCase() == 'true' ||
          value.toLowerCase() == 'false') {
        activity[key] = value.toLowerCase() == 'true';
      } else {
        activity[key] = value;
      }
    }

    // Add metadata
    activity['isActive'] = true;
    activity['importedAt'] = DateTime.now().toIso8601String();
    activity['createdAt'] = DateTime.now().toIso8601String();

    activities.add(activity);
  }

  // Write to JSON file
  final jsonFile = File('/Users/amanshah/Downloads/activity_list.json');
  await jsonFile.writeAsString(
    JsonEncoder.withIndent('  ').convert(activities),
  );

  debugPrint('✅ Successfully converted ${activities.length} activities!');
  debugPrint('📄 Output file: ${jsonFile.path}');
  debugPrint('\n📝 Instructions:');
  debugPrint('1. Go to Firebase Console: https://console.firebase.google.com');
  debugPrint('2. Select your project');
  debugPrint('3. Go to Firestore Database');
  debugPrint('4. Click "Import" button');
  debugPrint('5. Select the generated JSON file: activity_list.json');
  debugPrint('6. Set collection name: Activity list');
  debugPrint('7. Click "Import"');
  debugPrint('\n🎉 Done!');

  // Print sample data
  if (activities.isNotEmpty) {
    debugPrint('\n📋 Sample Activity:');
    debugPrint(JsonEncoder.withIndent('  ').convert(activities[0]));
  }
}

List<String> _parseCsvLine(String line) {
  final List<String> values = [];
  String currentValue = '';
  bool insideQuotes = false;

  for (int i = 0; i < line.length; i++) {
    final char = line[i];

    if (char == '"') {
      insideQuotes = !insideQuotes;
    } else if (char == ',' && !insideQuotes) {
      values.add(currentValue.trim());
      currentValue = '';
    } else {
      currentValue += char;
    }
  }

  values.add(currentValue.trim());
  return values;
}

String _camelCase(String str) {
  // Clean the string
  final cleaned = str.replaceAll(RegExp(r'[^a-zA-Z0-9]+'), ' ').trim();

  if (cleaned.isEmpty) return 'field';

  final words = cleaned.split(' ').where((word) => word.isNotEmpty).toList();
  if (words.isEmpty) return 'field';

  // First word lowercase, rest capitalized
  final result =
      words.first.toLowerCase() +
      words
          .skip(1)
          .map((word) {
            return word[0].toUpperCase() + word.substring(1).toLowerCase();
          })
          .join('');

  return result;
}

bool _isNumeric(String str) {
  if (str.isEmpty) return false;
  return num.tryParse(str) != null;
}
