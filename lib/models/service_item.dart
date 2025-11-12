class ServiceCategory {
  final String id;
  final String name;
  final String? description;
  final String icon; // Now stores IconData name like 'flight' instead of emoji
  final String color;
  final List<ServiceType> serviceTypes;

  ServiceCategory({
    required this.id,
    required this.name,
    this.description,
    required this.icon,
    required this.color,
    required this.serviceTypes,
  });
}

class ServiceType {
  final String id;
  final String name;
  final String? description;
  final String? icon;
  final String categoryId;
  final List<SubService> subServices;

  ServiceType({
    required this.id,
    required this.name,
    this.description,
    this.icon,
    required this.categoryId,
    required this.subServices,
  });
}

class SubService {
  final String id;
  final String name;
  final String? description;
  final String? icon;
  final String serviceTypeId;
  final PricingTier premium;
  final PricingTier standard;
  final List<String> documentRequirements;

  SubService({
    required this.id,
    required this.name,
    this.description,
    this.icon,
    required this.serviceTypeId,
    required this.premium,
    required this.standard,
    required this.documentRequirements,
  });

  String get premiumCostDisplay {
    return _formatCost(premium.cost);
  }

  String get standardCostDisplay {
    return _formatCost(standard.cost);
  }

  String _formatCost(dynamic cost) {
    if (cost == null) return 'Contact us';

    if (cost is int) {
      return 'AED $cost';
    }

    if (cost is double) {
      return 'AED ${cost.toStringAsFixed(2)}';
    }

    final costStr = cost.toString().trim();
    if (costStr.isEmpty) return 'Contact us';

    final normalized = costStr.toUpperCase();
    const currencyPrefixes = ['AED', 'USD', 'EUR', 'GBP'];
    final hasCurrencyPrefix = currencyPrefixes.any(
      (prefix) => normalized.startsWith(prefix),
    );
    final containsSpecialMarker =
        normalized.contains('REQUEST') ||
        normalized.contains('CONTACT') ||
        normalized.contains('INCLUDED') ||
        normalized.contains('QUOTE');

    if (hasCurrencyPrefix || containsSpecialMarker) {
      return costStr;
    }

    return 'AED $costStr';
  }
}

class PricingTier {
  final dynamic cost; // Can be int, String (for ranges), or null
  final String timeline;

  PricingTier({required this.cost, required this.timeline});
}
