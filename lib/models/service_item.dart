class ServiceCategory {
  final String id;
  final String name;
  final String icon;
  final String color;
  final List<ServiceType> serviceTypes;

  ServiceCategory({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
    required this.serviceTypes,
  });
}

class ServiceType {
  final String id;
  final String name;
  final String categoryId;
  final List<SubService> subServices;

  ServiceType({
    required this.id,
    required this.name,
    required this.categoryId,
    required this.subServices,
  });
}

class SubService {
  final String id;
  final String name;
  final String serviceTypeId;
  final PricingTier premium;
  final PricingTier standard;
  final List<String> documentRequirements;

  SubService({
    required this.id,
    required this.name,
    required this.serviceTypeId,
    required this.premium,
    required this.standard,
    required this.documentRequirements,
  });

  String get premiumCostDisplay {
    if (premium.cost is int) {
      return 'AED ${premium.cost}';
    } else if (premium.cost is String) {
      return 'AED ${premium.cost}';
    }
    return 'Contact Us';
  }

  String get standardCostDisplay {
    if (standard.cost is int) {
      return 'AED ${standard.cost}';
    } else if (standard.cost is String) {
      return 'AED ${standard.cost}';
    }
    return 'Contact Us';
  }
}

class PricingTier {
  final dynamic cost; // Can be int, String (for ranges), or null
  final String timeline;

  PricingTier({required this.cost, required this.timeline});
}
