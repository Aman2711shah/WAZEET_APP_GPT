import 'package:flutter_test/flutter_test.dart';
import 'package:wazeet/features/quote/data/models/package_model.dart';
import 'package:wazeet/features/quote/logic/quote_engine.dart';

void main() {
  test('compute totals basic scenario', () {
    final pkg = const PackageRow(
      packageName: 'Media Package',
      priceAed: '5760',
      immigrationCardFee: '1575',
      eChannelFee: '2735',
      visaCostAed: '3360',
      medicalFee: '371',
      emiratesIdFee: '370',
      changeOfStatusFee: '1103',
      noOfActivitiesAllowed: 'Upto 5',
    );
    const input = QuoteInput(
      freezone: 'SHAMS',
      visas: 2,
      activities: 3,
      shareholders: 1,
      tenure: 1,
    );

    final q = compute(pkg, input);
    // License + Immigration + E-Channel + (VisaCost * 2) + (Change * 2) + (Med+EID) * 2
    expect(
      q.total,
      5760 + 1575 + 2735 + (3360 * 2) + (1103 * 2) + ((371 + 370) * 2),
    );
  });
}
