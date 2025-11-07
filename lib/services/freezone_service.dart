import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/freezone.dart';

class FreeZoneService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'freezones';

  // Cache for repeated queries
  final Map<String, List<FreeZone>> _cache = {};
  DateTime? _lastFetch;

  // Get all zones
  Stream<List<FreeZone>> getAllZones() {
    return _firestore
        .collection(_collection)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => FreeZone.fromFirestore(doc.data(), doc.id))
              .toList(),
        );
  }

  // Get zones by emirate
  Stream<List<FreeZone>> getZonesByEmirate(String emirate) {
    final normalizedEmirate = emirate.toLowerCase().replaceAll(' ', '_');
    return _firestore
        .collection(_collection)
        .where('emirate', isEqualTo: normalizedEmirate)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => FreeZone.fromFirestore(doc.data(), doc.id))
              .toList(),
        );
  }

  // Get zones by industry (client-side filtering)
  Stream<List<FreeZone>> getZonesByIndustry(String industry) {
    return getAllZones().map((zones) {
      if (industry.isEmpty) return zones;

      final industryLower = industry.toLowerCase();
      return zones.where((zone) {
        // Check if industry matches any license type
        final matchesLicenseType = zone.licenseTypes.any(
          (type) =>
              type.toLowerCase().contains(industryLower) ||
              industryLower.contains(type.toLowerCase()),
        );

        // Check if industry matches any industry tag
        final matchesIndustry = zone.industries.any(
          (ind) =>
              ind.toLowerCase().contains(industryLower) ||
              industryLower.contains(ind.toLowerCase()),
        );

        return matchesLicenseType || matchesIndustry;
      }).toList();
    });
  }

  // Search zones by name
  Future<List<FreeZone>> searchZones(String query) async {
    if (query.isEmpty) {
      final snapshot = await _firestore.collection(_collection).get();
      return snapshot.docs
          .map((doc) => FreeZone.fromFirestore(doc.data(), doc.id))
          .toList();
    }

    final snapshot = await _firestore.collection(_collection).get();
    final allZones = snapshot.docs
        .map((doc) => FreeZone.fromFirestore(doc.data(), doc.id))
        .toList();

    final queryLower = query.toLowerCase();
    return allZones
        .where(
          (zone) =>
              zone.name.toLowerCase().contains(queryLower) ||
              zone.abbreviation.toLowerCase().contains(queryLower),
        )
        .toList();
  }

  // Apply filters
  List<FreeZone> applyFilters(
    List<FreeZone> zones, {
    String? licenseType,
    double? minPrice,
    double? maxPrice,
    int? minVisas,
    bool? remoteSetup,
  }) {
    var filtered = zones;

    if (licenseType != null && licenseType.isNotEmpty) {
      filtered = filtered
          .where(
            (zone) => zone.licenseTypes.any(
              (lt) => lt.toLowerCase().contains(licenseType.toLowerCase()),
            ),
          )
          .toList();
    }

    if (minPrice != null || maxPrice != null) {
      filtered = filtered.where((zone) {
        final price = zone.startingPrice;
        if (price == null) return false;
        if (minPrice != null && price < minPrice) return false;
        if (maxPrice != null && price > maxPrice) return false;
        return true;
      }).toList();
    }

    if (minVisas != null) {
      filtered = filtered.where((zone) {
        try {
          final allocation = zone.visaAllocation;
          if (allocation['basic'] is int) {
            return (allocation['basic'] as int) >= minVisas;
          }
          // Try to find any visa count
          for (final value in allocation.values) {
            if (value is int && value >= minVisas) return true;
          }
          return false;
        } catch (e) {
          return false;
        }
      }).toList();
    }

    if (remoteSetup != null && remoteSetup) {
      filtered = filtered.where((zone) => zone.remoteSetup == true).toList();
    }

    return filtered;
  }

  // Sort zones
  List<FreeZone> sortZones(List<FreeZone> zones, SortBy sortBy) {
    final sorted = List<FreeZone>.from(zones);

    switch (sortBy) {
      case SortBy.costLowToHigh:
        sorted.sort((a, b) {
          final aPrice = a.startingPrice ?? double.infinity;
          final bPrice = b.startingPrice ?? double.infinity;
          return aPrice.compareTo(bPrice);
        });
        break;
      case SortBy.costHighToLow:
        sorted.sort((a, b) {
          final aPrice = a.startingPrice ?? 0;
          final bPrice = b.startingPrice ?? 0;
          return bPrice.compareTo(aPrice);
        });
        break;
      case SortBy.visaCapacity:
        sorted.sort((a, b) {
          final aVisas = _getMaxVisas(a);
          final bVisas = _getMaxVisas(b);
          return bVisas.compareTo(aVisas);
        });
        break;
      case SortBy.rating:
        sorted.sort((a, b) {
          final aRating = a.rating ?? 0;
          final bRating = b.rating ?? 0;
          return bRating.compareTo(aRating);
        });
        break;
      case SortBy.name:
        sorted.sort((a, b) => a.name.compareTo(b.name));
        break;
    }

    return sorted;
  }

  int _getMaxVisas(FreeZone zone) {
    try {
      final allocation = zone.visaAllocation;
      int maxVisas = 0;
      for (final value in allocation.values) {
        if (value is int && value > maxVisas) {
          maxVisas = value;
        }
      }
      return maxVisas;
    } catch (e) {
      return 0;
    }
  }

  // Get unique industries
  Future<List<String>> getIndustries() async {
    final cacheKey = 'industries';
    if (_cache.containsKey(cacheKey) && _shouldUseCache()) {
      return _cache[cacheKey]!.expand((z) => z.industries).toSet().toList();
    }

    final snapshot = await _firestore.collection(_collection).get();
    final zones = snapshot.docs
        .map((doc) => FreeZone.fromFirestore(doc.data(), doc.id))
        .toList();

    _cache[cacheKey] = zones;
    _lastFetch = DateTime.now();

    final industries = zones.expand((zone) => zone.industries).toSet().toList();
    industries.sort();
    return industries;
  }

  // Get unique emirates
  Future<List<String>> getEmirates() async {
    final snapshot = await _firestore.collection(_collection).get();
    final emirates = snapshot.docs
        .map((doc) => doc.data()['emirate'] as String?)
        .where((emirate) => emirate != null)
        .toSet()
        .toList();
    emirates.sort();
    return emirates.cast<String>();
  }

  bool _shouldUseCache() {
    if (_lastFetch == null) return false;
    final diff = DateTime.now().difference(_lastFetch!);
    return diff.inMinutes < 30; // Cache for 30 minutes
  }

  // Clear cache
  void clearCache() {
    _cache.clear();
    _lastFetch = null;
  }
}

enum SortBy { costLowToHigh, costHighToLow, visaCapacity, rating, name }
