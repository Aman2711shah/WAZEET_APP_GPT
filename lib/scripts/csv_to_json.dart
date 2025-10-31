import 'dart:io';
import 'dart:convert';

/// Simple script to convert CSV to JSON for manual Firebase import
/// Run: dart lib/scripts/csv_to_json.dart
void main() async {
  print('🔄 Converting CSV to JSON for Firebase import...\n');

  final csvFile = File(
    '/Users/amanshah/Downloads/UAE_Freezones_Pricing_All_17_Freezones.csv',
  );

  if (!await csvFile.exists()) {
    print('❌ CSV file not found!');
    print('Please ensure the file exists at:');
    print(csvFile.path);
    exit(1);
  }

  // Read CSV
  final lines = await csvFile.readAsLines();
  if (lines.isEmpty) {
    print('❌ CSV file is empty');
    exit(1);
  }

  // Parse headers
  final headers = lines[0].split(',');
  print('📋 Found ${lines.length - 1} packages');
  print('📊 Headers: ${headers.join(", ")}\n');

  // Convert to JSON array
  final List<Map<String, dynamic>> packages = [];

  for (int i = 1; i < lines.length; i++) {
    final values = _parseCsvLine(lines[i]);
    if (values.length < headers.length) continue;

    final package = <String, dynamic>{};
    for (int j = 0; j < headers.length && j < values.length; j++) {
      package[_camelCase(headers[j])] = values[j];
    }

    // Add metadata
    package['isActive'] = true;
    package['importedAt'] = DateTime.now().toIso8601String();

    packages.add(package);
  }

  // Write to JSON file
  final jsonFile = File('/Users/amanshah/Downloads/freezone_packages.json');
  await jsonFile.writeAsString(JsonEncoder.withIndent('  ').convert(packages));

  print('✅ Successfully converted!');
  print('📄 Output file: ${jsonFile.path}');
  print('\n📝 Instructions:');
  print('1. Go to Firebase Console: https://console.firebase.google.com');
  print('2. Select your project');
  print('3. Go to Firestore Database');
  print('4. Click "Import" button');
  print('5. Select the generated JSON file: freezone_packages.json');
  print('6. Set collection name: freezonePackages');
  print('7. Click "Import"');
  print('\n🎉 Done!');
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
  return str
      .replaceAll(RegExp(r'[^a-zA-Z0-9]+'), ' ')
      .split(' ')
      .where((word) => word.isNotEmpty)
      .map((word) {
        final lower = word.toLowerCase();
        if (word == str.split(' ')[0]) return lower;
        return lower[0].toUpperCase() + lower.substring(1);
      })
      .join('');
}
