import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import '../data/models/package_model.dart';

class FreezoneRepo {
  Future<List<PackageRow>> loadZone(String zone) async {
    final map = {
      'RAKEZ': 'assets/data/rakez_packages.json',
      'SHAMS': 'assets/data/shams_packages.json',
      'IFZA': 'assets/data/ifza_packages.json',
      'SPCFZ': 'assets/data/spcfz_packages.json',
      'MEYDAN': 'assets/data/meydan_packages.json',
    };
    final path = map[zone.toUpperCase()];
    if (path == null) return [];
    final raw = await rootBundle.loadString(path);
    final list = (json.decode(raw) as List).cast<dynamic>();
    return list.map((e) => PackageRow.fromJson(e as Map)).toList();
  }
}
