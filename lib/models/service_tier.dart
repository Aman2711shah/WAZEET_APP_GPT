/// Represents a service tier (Standard or Premium) with pricing and timeline information
class ServiceTier {
  /// Unique identifier ('standard' | 'premium')
  final String id;

  /// Display name (e.g., 'Standard', 'Premium')
  final String name;

  /// Price in AED
  final int price;

  /// Minimum processing days
  final int minDays;

  /// Maximum processing days
  final int maxDays;

  /// Whether to show the FAST badge (premium only)
  final bool fastBadge;

  const ServiceTier({
    required this.id,
    required this.name,
    required this.price,
    required this.minDays,
    required this.maxDays,
    this.fastBadge = false,
  });

  /// Returns formatted days range label
  String get daysLabel {
    if (minDays == maxDays) {
      return '$minDays ${minDays == 1 ? 'day' : 'days'}';
    }
    return '$minDays–$maxDays days';
  }

  /// Returns formatted price label
  String get priceLabel => 'AED $price';

  /// Create a copy with updated fields
  ServiceTier copyWith({
    String? id,
    String? name,
    int? price,
    int? minDays,
    int? maxDays,
    bool? fastBadge,
  }) {
    return ServiceTier(
      id: id ?? this.id,
      name: name ?? this.name,
      price: price ?? this.price,
      minDays: minDays ?? this.minDays,
      maxDays: maxDays ?? this.maxDays,
      fastBadge: fastBadge ?? this.fastBadge,
    );
  }

  @override
  String toString() {
    return 'ServiceTier(id: $id, name: $name, price: $price, minDays: $minDays, maxDays: $maxDays, fastBadge: $fastBadge)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ServiceTier &&
        other.id == id &&
        other.name == name &&
        other.price == price &&
        other.minDays == minDays &&
        other.maxDays == maxDays &&
        other.fastBadge == fastBadge;
  }

  @override
  int get hashCode {
    return Object.hash(id, name, price, minDays, maxDays, fastBadge);
  }
}
