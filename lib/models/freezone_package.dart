class FreezonePackage {
  final String freezone;
  final String packageName;
  final String noOfActivitiesAllowed;
  final String noOfShareholdersAllowed;
  final String noOfVisasIncluded;
  final String tenureYears;
  final String priceAed;
  final String? immigrationCardFee;
  final String? eChannelFee;
  final String? visaCostAed;
  final String? medicalFee;
  final String? emiratesIdFee;
  final String? changeOfStatusFee;
  final String? otherCostsNotes;
  final String? visaEligibility;
  final bool isActive;
  final String? importedAt;

  FreezonePackage({
    required this.freezone,
    required this.packageName,
    required this.noOfActivitiesAllowed,
    required this.noOfShareholdersAllowed,
    required this.noOfVisasIncluded,
    required this.tenureYears,
    required this.priceAed,
    this.immigrationCardFee,
    this.eChannelFee,
    this.visaCostAed,
    this.medicalFee,
    this.emiratesIdFee,
    this.changeOfStatusFee,
    this.otherCostsNotes,
    this.visaEligibility,
    required this.isActive,
    this.importedAt,
  });

  factory FreezonePackage.fromFirestore(Map<String, dynamic> data) {
    return FreezonePackage(
      freezone: data['freezone'] ?? '',
      packageName: data['packageName'] ?? '',
      noOfActivitiesAllowed: data['NoOfActivitiesAllowed']?.toString() ?? '',
      noOfShareholdersAllowed:
          data['NoOfShareholdersAllowed']?.toString() ?? '',
      noOfVisasIncluded: data['NoOfVisasIncluded']?.toString() ?? '',
      tenureYears: data['tenureYears']?.toString() ?? '',
      priceAed: data['priceAed']?.toString() ?? '',
      immigrationCardFee: data['immigrationCardFee']?.toString(),
      eChannelFee: data['EChannelFee']?.toString(),
      visaCostAed: data['visaCostAed']?.toString(),
      medicalFee: data['medicalFee']?.toString(),
      emiratesIdFee: data['emiratesIdFee']?.toString(),
      changeOfStatusFee: data['changeOfStatusFee']?.toString(),
      otherCostsNotes: data['otherCostsNotes']?.toString(),
      visaEligibility: data['visaEligibility']?.toString(),
      isActive: data['isActive'] ?? true,
      importedAt: data['importedAt']?.toString(),
    );
  }

  // Helper method to get total cost
  double get totalCost {
    double total = double.tryParse(priceAed) ?? 0;
    total += double.tryParse(immigrationCardFee ?? '0') ?? 0;
    total += double.tryParse(eChannelFee ?? '0') ?? 0;
    total += double.tryParse(visaCostAed ?? '0') ?? 0;
    total += double.tryParse(medicalFee ?? '0') ?? 0;
    total += double.tryParse(emiratesIdFee ?? '0') ?? 0;
    total += double.tryParse(changeOfStatusFee ?? '0') ?? 0;
    return total;
  }

  // Formatted price
  String get formattedPrice {
    final price = double.tryParse(priceAed) ?? 0;
    return 'AED ${price.toStringAsFixed(0)}';
  }

  // Formatted total cost
  String get formattedTotalCost {
    return 'AED ${totalCost.toStringAsFixed(0)}';
  }
}
