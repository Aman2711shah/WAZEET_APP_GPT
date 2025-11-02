import 'package:flutter/foundation.dart';

import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:csv/csv.dart';
import '../firebase_options.dart';

/// Standalone script to import freezone packages CSV to Firestore
///
/// Run this script with:
/// dart run lib/scripts/import_freezone_packages.dart
Future<void> main() async {
  debugPrint('🚀 Starting Freezone Packages Import...\n');

  // Initialize Firebase
  debugPrint('Initializing Firebase...');
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  debugPrint('✅ Firebase initialized\n');

  final firestore = FirebaseFirestore.instance;
  final csvFilePath =
      '/Users/amanshah/Downloads/UAE_Freezones_Pricing_All_17_Freezones.csv';

  try {
    // Read CSV file
    debugPrint('📄 Reading CSV file: $csvFilePath');
    final file = File(csvFilePath);
    if (!await file.exists()) {
      debugPrint('❌ Error: CSV file not found at $csvFilePath');
      exit(1);
    }

    final csvContent = await file.readAsString();
    final rows = const CsvToListConverter().convert(csvContent);

    if (rows.isEmpty) {
      debugPrint('❌ Error: CSV file is empty');
      exit(1);
    }

    // Get headers
    final headers = rows[0].map((e) => e.toString().trim()).toList();
    debugPrint('✅ Found ${rows.length - 1} packages to import');
    debugPrint('📋 Headers: ${headers.join(", ")}\n');

    // Get Firestore collection
    final collection = firestore.collection('freezonePackages');

    // Optional: Clear existing data
    debugPrint('Do you want to clear existing packages first? (y/n):');
    final clearResponse = stdin.readLineSync();
    if (clearResponse?.toLowerCase() == 'y') {
      debugPrint('🗑️  Clearing existing packages...');
      final snapshot = await collection.get();
      final batch = firestore.batch();
      for (var doc in snapshot.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();
      debugPrint('✅ Cleared ${snapshot.docs.length} existing packages\n');
    }

    // Import data
    debugPrint('📥 Importing packages to Firestore...\n');
    int successCount = 0;
    int errorCount = 0;

    for (int i = 1; i < rows.length; i++) {
      try {
        final row = rows[i];
        final packageData = <String, dynamic>{};

        // Map CSV columns to Firestore fields
        packageData['freezone'] = _getValue(row, 0);
        packageData['packageName'] = _getValue(row, 1);
        packageData['noOfActivitiesAllowed'] = _getValue(row, 2);
        packageData['noOfShareholdersAllowed'] = _getValue(row, 3);
        packageData['noOfVisasIncluded'] = _parseInt(_getValue(row, 4));
        packageData['tenureYears'] = _parseInt(_getValue(row, 5));
        packageData['priceAED'] = _parseDouble(_getValue(row, 6));
        packageData['immigrationCardFee'] = _getValue(row, 7);
        packageData['eChannelFee'] = _getValue(row, 8);
        packageData['visaCostAED'] = _getValue(row, 9);
        packageData['medicalFee'] = _getValue(row, 10);
        packageData['emiratesIDFee'] = _getValue(row, 11);
        packageData['changeOfStatusFee'] = _getValue(row, 12);
        packageData['otherCostsNotes'] = _getValue(row, 13);
        packageData['visaEligibility'] = _getValue(row, 14);

        // Add metadata
        packageData['createdAt'] = FieldValue.serverTimestamp();
        packageData['updatedAt'] = FieldValue.serverTimestamp();
        packageData['isActive'] = true;

        // Add to Firestore
        await collection.add(packageData);
        successCount++;

        if (successCount % 50 == 0) {
          debugPrint('   Imported $successCount packages...');
        }
      } catch (e) {
        errorCount++;
        debugPrint('⚠️  Error importing row $i: $e');
      }
    }

    debugPrint('\n✅ Import completed!');
    debugPrint('Successfully imported: $successCount packages');
    if (errorCount > 0) {
      debugPrint('⚠️  Errors: $errorCount packages failed');
    }

    // Show statistics
    debugPrint('\n📊 Package Statistics:');
    final snapshot = await collection.get();
    final freezoneCounts = <String, int>{};
    for (var doc in snapshot.docs) {
      final freezone = doc.data()['freezone'] as String? ?? 'Unknown';
      freezoneCounts[freezone] = (freezoneCounts[freezone] ?? 0) + 1;
    }

    freezoneCounts.forEach((freezone, pkgCount) {
      debugPrint('   $freezone: $pkgCount packages');
    });

    debugPrint('\n🎉 Import process finished!');
  } catch (e, stackTrace) {
    debugPrint('❌ Fatal error during import: $e');
    debugPrint(stackTrace.toString());
    exit(1);
  }

  exit(0);
}

/// Get value from row safely
String? _getValue(List row, int index) {
  if (index >= row.length) return null;
  final value = row[index]?.toString().trim();
  return (value == null || value.isEmpty) ? null : value;
}

/// Parse integer from string
int? _parseInt(String? value) {
  if (value == null || value.isEmpty) return null;

  // Handle ranges like "Up to 5" or "Upto 5"
  if (value.toLowerCase().contains('up to') ||
      value.toLowerCase().contains('upto')) {
    final match = RegExp(r'\d+').firstMatch(value);
    if (match != null) {
      return int.tryParse(match.group(0)!);
    }
  }

  return int.tryParse(value);
}

/// Parse double from string
double? _parseDouble(String? value) {
  if (value == null || value.isEmpty) return null;

  if (value.toLowerCase() == 'extra' ||
      value.toLowerCase() == 'additional' ||
      value.toLowerCase() == 'included') {
    return null;
  }

  // Remove currency symbols and commas
  final cleaned = value.replaceAll(RegExp(r'[^\d.]'), '');
  return double.tryParse(cleaned);
}
