import 'package:flutter_test/flutter_test.dart';
import 'package:wazeet/features/tax_calculator/tax_models.dart';
import 'package:wazeet/features/tax_calculator/tax_math.dart';

void main() {
  group('VAT calculations', () {
    test('Exclusive amount VAT 5%', () {
      final res = calculateVat(const VatInput(amount: 1000, vatRate: 5));
      expect(res.net, 1000);
      expect(res.vat, 50);
      expect(res.gross, 1050);
    });

    test('Inclusive amount VAT 5%', () {
      final res = calculateVat(
        const VatInput(amount: 1050, vatRate: 5, amountIncludesVat: true),
      );
      expect(res.net, 1000);
      expect(res.vat, 50);
      expect(res.gross, 1050);
    });
  });

  group('Corporate tax calculations', () {
    test('Profit below threshold -> zero tax', () {
      final res = calculateCorporateTax(
        const CorporateTaxInput(revenue: 300000, deductibleExpenses: 0),
      );
      expect(res.taxableProfit, 300000);
      expect(res.taxDue, 0);
      expect(res.ninePercentTaxable, 0);
    });

    test('Profit above threshold -> 9% band applied', () {
      final res = calculateCorporateTax(
        const CorporateTaxInput(revenue: 500000, deductibleExpenses: 0),
      );
      expect(res.taxableProfit, 500000);
      expect(res.zeroBandTaxable, 375000);
      expect(res.ninePercentTaxable, 125000);
      expect(res.taxDue, 11250); // 125000 * 9%
    });

    test('Qualifying free zone reduces taxable profit', () {
      final res = calculateCorporateTax(
        const CorporateTaxInput(
          revenue: 800000,
          deductibleExpenses: 200000,
          qualifyingFreeZone: true,
          qualifyingIncome: 250000, // this portion treated at 0%
        ),
      );
      // Base profit = 600000, qualifying portion 250000 -> taxable 350000
      expect(res.taxableProfit, 350000);
      expect(res.taxDue, 0); // under 375k
    });
  });
}
