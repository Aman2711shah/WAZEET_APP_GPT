import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:csv/csv.dart';

/// Utility class to import freezone packages from CSV to Firestore
class FreezonePackagesImporter {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Import all freezone packages from the CSV file
  static Future<void> importFromCSV(String csvContent) async {
    try {
      // Parse CSV
      final rows = const CsvToListConverter().convert(csvContent);

      if (rows.isEmpty) {
        print('CSV file is empty');
        return;
      }

      // First row is headers
      final headers = rows[0].map((e) => e.toString()).toList();
      print('Headers: $headers');

      // Get reference to the collection
      final collection = _firestore.collection('freezonePackages');

      int successCount = 0;
      int errorCount = 0;

      // Process each row (skip header row)
      for (int i = 1; i < rows.length; i++) {
        try {
          final row = rows[i];

          // Create a map from headers and row values
          final Map<String, dynamic> packageData = {};
          for (int j = 0; j < headers.length && j < row.length; j++) {
            final key = _normalizeKey(headers[j]);
            final value = _parseValue(row[j]);
            packageData[key] = value;
          }

          // Add metadata
          packageData['createdAt'] = FieldValue.serverTimestamp();
          packageData['updatedAt'] = FieldValue.serverTimestamp();
          packageData['isActive'] = true;

          // Convert numeric fields
          packageData['price'] = _parseDouble(packageData['price']);
          packageData['tenureYears'] = _parseInt(packageData['tenureYears']);
          packageData['immigrationCardFee'] = _parseDouble(
            packageData['immigrationCardFee'],
          );
          packageData['eChannelFee'] = _parseDouble(packageData['eChannelFee']);
          packageData['visaCost'] = _parseDouble(packageData['visaCost']);
          packageData['medicalFee'] = _parseDouble(packageData['medicalFee']);
          packageData['emiratesIdFee'] = _parseDouble(
            packageData['emiratesIdFee'],
          );
          packageData['changeOfStatusFee'] = _parseDouble(
            packageData['changeOfStatusFee'],
          );

          // Parse numeric ranges from strings like "Up to 5"
          packageData['noOfActivitiesAllowed'] = _parseRange(
            packageData['noOfActivitiesAllowed'],
          );
          packageData['noOfShareholdersAllowed'] = _parseInt(
            packageData['noOfShareholdersAllowed'],
          );
          packageData['noOfVisasIncluded'] = _parseInt(
            packageData['noOfVisasIncluded'],
          );

          // Add document to Firestore
          await collection.add(packageData);
          successCount++;

          if (successCount % 10 == 0) {
            print('Imported $successCount packages...');
          }
        } catch (e) {
          errorCount++;
          print('Error importing row $i: $e');
        }
      }

      print('✅ Import completed!');
      print('Successfully imported: $successCount packages');
      if (errorCount > 0) {
        print('⚠️ Errors: $errorCount packages failed');
      }
    } catch (e) {
      print('❌ Error during import: $e');
      rethrow;
    }
  }

  /// Normalize header keys to camelCase
  static String _normalizeKey(String header) {
    return header
        .trim()
        .replaceAll(' ', '')
        .replaceAll('(', '')
        .replaceAll(')', '')
        .replaceAll('.', '')
        .replaceAll('/', '')
        .replaceAll('-', '');
  }

  /// Parse value handling null/empty cases
  static dynamic _parseValue(dynamic value) {
    if (value == null || value.toString().trim().isEmpty) {
      return null;
    }
    final str = value.toString().trim();
    if (str.toLowerCase() == 'extra' ||
        str.toLowerCase() == 'additional' ||
        str.toLowerCase() == 'included') {
      return str;
    }
    return str;
  }

  /// Parse double from string, handling various formats
  static double? _parseDouble(dynamic value) {
    if (value == null) return null;
    final str = value.toString().trim();
    if (str.isEmpty ||
        str.toLowerCase() == 'extra' ||
        str.toLowerCase() == 'additional' ||
        str.toLowerCase() == 'included') {
      return null;
    }

    // Remove currency symbols and commas
    final cleaned = str.replaceAll(RegExp(r'[^\d.]'), '');
    return double.tryParse(cleaned);
  }

  /// Parse integer from string
  static int? _parseInt(dynamic value) {
    if (value == null) return null;
    final str = value.toString().trim();
    if (str.isEmpty) return null;

    // Handle ranges like "Up to 5" or "Upto 5"
    if (str.toLowerCase().contains('up to') ||
        str.toLowerCase().contains('upto')) {
      final match = RegExp(r'\d+').firstMatch(str);
      if (match != null) {
        return int.tryParse(match.group(0)!);
      }
    }

    return int.tryParse(str);
  }

  /// Parse range strings like "Up to 5" or "1"
  static String _parseRange(dynamic value) {
    if (value == null) return 'Any';
    final str = value.toString().trim();
    if (str.isEmpty) return 'Any';

    // Keep the original format for ranges
    if (str.toLowerCase().contains('up to') ||
        str.toLowerCase().contains('upto')) {
      return str;
    }

    return str;
  }

  /// Delete all existing packages (use with caution!)
  static Future<void> clearAllPackages() async {
    try {
      final collection = _firestore.collection('freezonePackages');
      final snapshot = await collection.get();

      final batch = _firestore.batch();
      for (var doc in snapshot.docs) {
        batch.delete(doc.reference);
      }

      await batch.commit();
      print('✅ Cleared ${snapshot.docs.length} packages from Firestore');
    } catch (e) {
      print('❌ Error clearing packages: $e');
      rethrow;
    }
  }

  /// Get count of packages by freezone
  static Future<Map<String, int>> getPackageCountByFreezone() async {
    try {
      final snapshot = await _firestore.collection('freezonePackages').get();
      final Map<String, int> counts = {};

      for (var doc in snapshot.docs) {
        final freezone = doc.data()['freezone'] as String? ?? 'Unknown';
        counts[freezone] = (counts[freezone] ?? 0) + 1;
      }

      return counts;
    } catch (e) {
      print('❌ Error getting package counts: $e');
      rethrow;
    }
  }
}
