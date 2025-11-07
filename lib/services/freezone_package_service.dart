import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/freezone_package.dart';

class FreezonePackageService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _collection = 'freezonePackages';

  /// Get all packages for a specific freezone
  Stream<List<FreezonePackage>> getPackagesForFreezone(String freezoneName) {
    return _firestore
        .collection(_collection)
        .where('freezone', isEqualTo: freezoneName)
        .where('isActive', isEqualTo: true)
        .orderBy('priceAed')
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => FreezonePackage.fromFirestore(doc.data()))
              .toList();
        });
  }

  /// Get all packages grouped by freezone
  Stream<Map<String, List<FreezonePackage>>> getAllPackagesGrouped() {
    return _firestore
        .collection(_collection)
        .where('isActive', isEqualTo: true)
        .snapshots()
        .map((snapshot) {
          final Map<String, List<FreezonePackage>> grouped = {};

          for (final doc in snapshot.docs) {
            final package = FreezonePackage.fromFirestore(doc.data());
            grouped.putIfAbsent(package.freezone, () => []).add(package);
          }

          // Sort packages within each freezone by price
          for (final key in grouped.keys) {
            grouped[key]!.sort((a, b) {
              final priceA = double.tryParse(a.priceAed) ?? 0;
              final priceB = double.tryParse(b.priceAed) ?? 0;
              return priceA.compareTo(priceB);
            });
          }

          return grouped;
        });
  }

  /// Get packages for multiple freezones (for comparison)
  Future<Map<String, List<FreezonePackage>>> getPackagesForMultipleZones(
    List<String> freezoneNames,
  ) async {
    final Map<String, List<FreezonePackage>> result = {};

    for (final name in freezoneNames) {
      final snapshot = await _firestore
          .collection(_collection)
          .where('freezone', isEqualTo: name)
          .where('isActive', isEqualTo: true)
          .orderBy('priceAed')
          .get();

      result[name] = snapshot.docs
          .map((doc) => FreezonePackage.fromFirestore(doc.data()))
          .toList();
    }

    return result;
  }

  /// Get the cheapest package for a freezone
  Future<FreezonePackage?> getCheapestPackage(String freezoneName) async {
    final snapshot = await _firestore
        .collection(_collection)
        .where('freezone', isEqualTo: freezoneName)
        .where('isActive', isEqualTo: true)
        .orderBy('priceAed')
        .limit(1)
        .get();

    if (snapshot.docs.isEmpty) return null;
    return FreezonePackage.fromFirestore(snapshot.docs.first.data());
  }

  /// Get packages by emirate
  Stream<Map<String, List<FreezonePackage>>> getPackagesByEmirate() {
    return getAllPackagesGrouped();
  }
}
