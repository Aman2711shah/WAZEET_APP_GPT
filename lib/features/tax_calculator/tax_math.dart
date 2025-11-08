import 'dart:math' as math;

import 'tax_models.dart';

/// Rounds to 2 decimal places (bankers rounding not required here)
double _round2(double v) => (v * 100).roundToDouble() / 100.0;

/// Calculates VAT result given input
VatResult calculateVat(VatInput input) {
  final rate = (input.vatRate.clamp(0, 100)) / 100.0;
  if (input.amountIncludesVat) {
    // amount = net * (1 + rate)
    final net = input.amount / (1 + rate);
    final vat = input.amount - net;
    return VatResult(
      net: _round2(net),
      vat: _round2(vat),
      gross: _round2(input.amount),
    );
  } else {
    final vat = input.amount * rate;
    final gross = input.amount + vat;
    return VatResult(
      net: _round2(input.amount),
      vat: _round2(vat),
      gross: _round2(gross),
    );
  }
}

/// UAE Corporate Tax as of 2025 basics:
/// - 0% on first AED 375,000 of taxable income
/// - 9% on taxable income above AED 375,000
/// - If Qualifying Free Zone Person (QFZP), qualifying income can be at 0%
CorporateTaxBreakdown calculateCorporateTax(CorporateTaxInput input) {
  // Profit before tax adjustments
  final baseProfit =
      input.revenue - input.deductibleExpenses + input.otherAdjustments;

  // If qualifying free zone: qualifying income portion at 0%
  final qualifyingPortion = input.qualifyingFreeZone
      ? math
            .min(math.max(baseProfit, 0), math.max(input.qualifyingIncome, 0))
            .toDouble()
      : 0.0;

  final taxableProfit = math.max(baseProfit - qualifyingPortion, 0).toDouble();

  // Apply bands
  const band = 375000.0;
  final zeroBandTaxable = math.min(taxableProfit, band).toDouble();
  final ninePercentTaxable = math.max(taxableProfit - band, 0).toDouble();

  final taxDue = (zeroBandTaxable * 0) + (ninePercentTaxable * 0.09);

  return CorporateTaxBreakdown(
    taxableProfit: _round2(taxableProfit),
    zeroBandTaxable: _round2(zeroBandTaxable),
    ninePercentTaxable: _round2(ninePercentTaxable),
    taxDue: _round2(taxDue),
  );
}
