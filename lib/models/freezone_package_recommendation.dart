/// Model class representing a Freezone Package recommendation
///
/// This model matches the Firestore collection 'freezonePackages' schema
/// and includes calculated total costs based on user's visa requirements.
class FreezonePackageRecommendation {
  // Basic package info
  final String id; // Firestore document ID
  final String freezone; // e.g., "SHAMS", "RAKEZ", "IFZA"
  final String product; // e.g., "1 Visa License"
  final String jurisdiction; // e.g., "Freezone" or "Mainland"

  // Office and activities
  final String officeType; // e.g., "Co-Working/Flexi-desk"
  final String activitiesAllowed; // e.g., "5" or "Mix & Match"
  final int visaEligibility; // Total visa quota available

  // Cost breakdown
  final double licenseFee; // license_cost_including_quota_fee
  final double visaInvestorCost; // Total cost for investor visas
  final double visaManagerCost; // Total cost for manager visas
  final double visaEmploymentCost; // Total cost for employment visas
  final double establishmentCard; // immigration_establishment_card
  final double eChannel; // e_channel_registration
  final double medicalTotal; // medical_cost * total visas
  final double eidTotal; // eid_cost * total visas

  // Calculated total
  final double totalCost;

  FreezonePackageRecommendation({
    required this.id,
    required this.freezone,
    required this.product,
    required this.jurisdiction,
    required this.officeType,
    required this.activitiesAllowed,
    required this.visaEligibility,
    required this.licenseFee,
    required this.visaInvestorCost,
    required this.visaManagerCost,
    required this.visaEmploymentCost,
    required this.establishmentCard,
    required this.eChannel,
    required this.medicalTotal,
    required this.eidTotal,
    required this.totalCost,
  });

  /// Formatted total cost as AED string
  String get formattedTotalCost {
    return 'AED ${totalCost.toStringAsFixed(2)}';
  }

  /// Formatted total cost (rounded) as AED string
  String get formattedTotalCostRounded {
    return 'AED ${totalCost.round().toStringAsFixed(0)}';
  }

  /// Get breakdown of costs for detailed view
  Map<String, double> get costBreakdown {
    return {
      'License Fee': licenseFee,
      'Investor Visas': visaInvestorCost,
      'Manager Visas': visaManagerCost,
      'Employment Visas': visaEmploymentCost,
      'Establishment Card': establishmentCard,
      'E-Channel Registration': eChannel,
      'Medical Costs': medicalTotal,
      'Emirates ID Costs': eidTotal,
    };
  }
}
