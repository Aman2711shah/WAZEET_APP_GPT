#!/usr/bin/env dart

// Script to split the master excel-to-json-4.json by freezone
import 'dart:io';
import 'dart:convert';

void main() async {
  final input = File('freezone-import/excel-to-json-4.json');
  final data = jsonDecode(await input.readAsString()) as List;

  // Map freezone names to target files
  final zoneMap = {
    'RAKEZ': 'assets/data/rakez_packages.json',
    'SHAMS': 'assets/data/shams_packages.json',
    'IFZA Dubai': 'assets/data/ifza_packages.json',
    'SPC': 'assets/data/spcfz_packages.json',
    'Meydan Free Zone': 'assets/data/meydan_packages.json',
  };

  for (final entry in zoneMap.entries) {
    final filtered = data.where((row) => row['freezone'] == entry.key).toList();
    final output = File(entry.value);
    await output.writeAsString(JsonEncoder.withIndent('  ').convert(filtered));
    stdout.writeln(
      '✓ ${entry.key}: ${filtered.length} packages → ${entry.value}',
    );
  }

  stdout.writeln();
  stdout.writeln('Done! All 5 freezone datasets created.');
}
