#!/usr/bin/env dart

// Script to merge multiple business activity JSON files into one comprehensive list
import 'dart:io';
import 'dart:convert';
import 'package:flutter/foundation.dart' show debugPrint;

void main() async {
  debugPrint('🔄 Merging business activity JSON files...\n');

  final inputFiles = [
    '/Users/amanshah/Downloads/excel-to-json-5.json',
    '/Users/amanshah/Downloads/excel-to-json-6.json',
    '/Users/amanshah/Downloads/excel-to-json-7.json',
    '/Users/amanshah/Downloads/excel-to-json-8.json',
    '/Users/amanshah/Downloads/excel-to-json-9.json',
  ];

  final outputPath = 'assets/images/custom-activities.json';
  final allActivities = <Map<String, dynamic>>[];
  final seenCodes = <String>{};

  for (final filePath in inputFiles) {
    final file = File(filePath);
    if (!file.existsSync()) {
      debugPrint('⚠️  File not found: $filePath');
      continue;
    }

    try {
      final content = await file.readAsString();
      final data = jsonDecode(content) as List;

      debugPrint(
        '📂 Processing ${filePath.split('/').last}: ${data.length} activities',
      );

      for (final item in data) {
        if (item is! Map<String, dynamic>) continue;

        final code = item['Code']?.toString() ?? '';
        final activityName = item['Activity Name']?.toString() ?? '';

        // Skip if no activity name or duplicate code
        if (activityName.isEmpty) continue;
        if (code.isNotEmpty && seenCodes.contains(code)) continue;

        if (code.isNotEmpty) {
          seenCodes.add(code);
        }

        // Transform to our schema
        final activity = {
          'code': code,
          'category': item['Category']?.toString() ?? '',
          'activityGroup': item['Activity Group']?.toString() ?? '',
          'name': activityName,
          'description': item['Description']?.toString() ?? '',
          'licenseType': item['License Type']?.toString() ?? '',
          'officeRequirement': item['Office Requirement']?.toString() ?? '',
          'activityPrice': item['Activity Price'],
          'externalApproval': item['External Approval ']?.toString() ?? 'No',
          'authority': item['Authority']?.toString() ?? 'N/A',
          'when': item['When']?.toString() ?? 'N/A',
        };

        allActivities.add(activity);
      }
    } catch (e) {
      debugPrint('❌ Error processing $filePath: $e');
    }
  }

  // Sort by category, then by name
  allActivities.sort((a, b) {
    final catCompare = (a['category'] ?? '').compareTo(b['category'] ?? '');
    if (catCompare != 0) return catCompare;
    return (a['name'] ?? '').compareTo(b['name'] ?? '');
  });

  // Write output
  final output = File(outputPath);
  await output.writeAsString(
    JsonEncoder.withIndent('  ').convert(allActivities),
  );

  debugPrint('\n✅ Merged ${allActivities.length} unique activities');
  debugPrint('📝 Output: $outputPath');

  // Print category summary
  final categories = <String, int>{};
  for (final activity in allActivities) {
    final cat = activity['category']?.toString() ?? 'Unknown';
    categories[cat] = (categories[cat] ?? 0) + 1;
  }

  debugPrint('\n📊 Activities by category:');
  final sorted = categories.entries.toList()
    ..sort((a, b) => b.value.compareTo(a.value));
  for (final entry in sorted) {
    debugPrint('   ${entry.key}: ${entry.value}');
  }
}
