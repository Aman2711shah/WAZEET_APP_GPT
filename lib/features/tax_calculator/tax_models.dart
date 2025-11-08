/// VAT calculation input
class VatInput {
  final double amount; // Base amount before VAT or after based on includeVat
  final double vatRate; // e.g., 5 for 5%
  final bool amountIncludesVat; // if true, amount is VAT-inclusive

  const VatInput({
    required this.amount,
    required this.vatRate,
    this.amountIncludesVat = false,
  });
}

class VatResult {
  final double net; // amount excluding VAT
  final double vat; // VAT portion
  final double gross; // total including VAT

  const VatResult({required this.net, required this.vat, required this.gross});
}

/// Corporate tax input per UAE regime
class CorporateTaxInput {
  final double revenue; // total revenue
  final double deductibleExpenses; // allowable deductions
  final double otherAdjustments; // +/- adjustments (e.g., exempt income)
  final bool qualifyingFreeZone; // QFZP potentially 0% on qualifying income
  final double qualifyingIncome; // subset of profit that is at 0%

  const CorporateTaxInput({
    required this.revenue,
    required this.deductibleExpenses,
    this.otherAdjustments = 0,
    this.qualifyingFreeZone = false,
    this.qualifyingIncome = 0,
  });
}

class CorporateTaxBreakdown {
  final double taxableProfit; // overall taxable profit after adjustments
  final double zeroBandTaxable; // up to AED 375,000
  final double ninePercentTaxable; // above AED 375,000
  final double taxDue; // total tax due

  const CorporateTaxBreakdown({
    required this.taxableProfit,
    required this.zeroBandTaxable,
    required this.ninePercentTaxable,
    required this.taxDue,
  });
}
