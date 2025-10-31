class FreeZone {
  final String id;
  final String name;
  final String abbreviation;
  final String emirate;
  final int? established;
  final List<String> licenseTypes;
  final List<String> industries;
  final Map<String, dynamic> costs;
  final Map<String, dynamic> visaAllocation;
  final Map<String, dynamic>? activities;
  final Map<String, dynamic>? officeRequirements;
  final List<String> keyAdvantages;
  final List<String> notableLimitations;
  final Map<String, dynamic>? specialFeatures;
  final double? rating;
  final bool? dualLicense;
  final bool? remoteSetup;

  FreeZone({
    required this.id,
    required this.name,
    required this.abbreviation,
    required this.emirate,
    this.established,
    required this.licenseTypes,
    required this.industries,
    required this.costs,
    required this.visaAllocation,
    this.activities,
    this.officeRequirements,
    required this.keyAdvantages,
    required this.notableLimitations,
    this.specialFeatures,
    this.rating,
    this.dualLicense,
    this.remoteSetup,
  });

  factory FreeZone.fromFirestore(Map<String, dynamic> data, String documentId) {
    return FreeZone(
      id: documentId,
      name: data['name'] ?? '',
      abbreviation: data['abbreviation'] ?? '',
      emirate: data['emirate'] ?? '',
      established: data['established'] as int?,
      licenseTypes: _parseList(data['license_types']),
      industries: _parseIndustries(data),
      costs: _parseCosts(data['costs']),
      visaAllocation: _parseVisaAllocation(data['visa_allocation']),
      activities: _parseActivities(data['activities']),
      officeRequirements: _parseOfficeRequirements(data['office_requirements']),
      keyAdvantages: _parseList(data['key_advantages']),
      notableLimitations: _parseList(data['notable_limitations']),
      specialFeatures: data['special_features'] as Map<String, dynamic>?,
      rating: _parseDouble(data['rating']),
      dualLicense: (data['special_features'] as Map?)?['dual_license'] as bool?,
      remoteSetup: (data['special_features'] as Map?)?['remote_setup'] as bool?,
    );
  }

  static Map<String, dynamic> _parseCosts(dynamic value) {
    if (value == null) return {};
    if (value is Map<String, dynamic>) return value;
    return {};
  }

  static Map<String, dynamic> _parseVisaAllocation(dynamic value) {
    if (value == null) return {};
    if (value is Map<String, dynamic>) return value;
    if (value is String) return {'description': value};
    return {};
  }

  static Map<String, dynamic>? _parseActivities(dynamic value) {
    if (value == null) return null;
    if (value is Map<String, dynamic>) return value;
    return null;
  }

  static Map<String, dynamic>? _parseOfficeRequirements(dynamic value) {
    if (value == null) return null;
    if (value is Map<String, dynamic>) return value;
    if (value is String) return {'description': value};
    return null;
  }

  static List<String> _parseList(dynamic value) {
    if (value == null) return [];
    if (value is List) return value.map((e) => e.toString()).toList();
    return [];
  }

  static List<String> _parseIndustries(Map<String, dynamic> data) {
    final Set<String> industries = {};

    // From license_types
    if (data['license_types'] is List) {
      industries.addAll(
        (data['license_types'] as List).map((e) => e.toString()),
      );
    }

    // From activities.allowed
    if (data['activities'] is Map) {
      final allowed = (data['activities'] as Map)['allowed'];
      if (allowed is List) {
        industries.addAll(allowed.map((e) => e.toString()));
      }
    }

    return industries.toList();
  }

  static double? _parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  double? get startingPrice {
    try {
      final setup = costs['setup'];
      if (setup is Map) {
        // Try different possible keys
        for (final key in [
          'basic',
          'standard',
          'license',
          'startup_package',
          'non_financial',
        ]) {
          final pkg = setup[key];
          if (pkg is Map && pkg['amount'] != null) {
            final amount = pkg['amount'];
            if (amount is num) return amount.toDouble();
          }
        }
        // If no named package, try first entry
        if (setup.isNotEmpty) {
          final first = setup.values.first;
          if (first is Map && first['amount'] != null) {
            final amount = first['amount'];
            if (amount is num) return amount.toDouble();
          }
        }
      }
    } catch (e) {
      // Return null if parsing fails
    }
    return null;
  }

  String get startingPriceFormatted {
    try {
      // Check if costs has setup as a string (new format)
      final setup = costs['setup'];
      if (setup is String && setup.isNotEmpty) {
        return setup;
      }

      // Otherwise try the old format with nested maps
      final price = startingPrice;
      if (price == null) return 'Contact for pricing';

      String currency = 'AED';
      if (setup is Map && setup.values.isNotEmpty) {
        final first = setup.values.first;
        if (first is Map && first['currency'] != null) {
          currency = first['currency'].toString();
        }
      }

      return '$currency ${price.toStringAsFixed(0)}';
    } catch (e) {
      return 'Contact for pricing';
    }
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'abbreviation': abbreviation,
      'emirate': emirate,
      'established': established,
      'license_types': licenseTypes,
      'industries': industries,
      'costs': costs,
      'visa_allocation': visaAllocation,
      'activities': activities,
      'office_requirements': officeRequirements,
      'key_advantages': keyAdvantages,
      'notable_limitations': notableLimitations,
      'special_features': specialFeatures,
      'rating': rating,
    };
  }
}
