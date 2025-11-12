import 'package:flutter_test/flutter_test.dart';
import 'package:wazeet/features/quote/data/models/package_model.dart';
import 'package:wazeet/features/quote/logic/matchers.dart';

void main() {
  PackageRow row(String acts, String shs, String tenure) => PackageRow(
    packageName: 'Package $acts-$shs-$tenure',
    noOfActivitiesAllowed: acts,
    noOfShareholdersAllowed: shs,
    tenureYears: tenure,
    isActive: true,
  );

  test('pickBestPackage matches by activities, shareholders, tenure', () {
    final rows = [
      row('Upto 5', 'Up to 5', '1'),
      row('Upto 5', 'Up to 5', '2'),
      row('Upto 5', 'Up to 5', '3'),
      row('Upto 10', 'Up to 5', '1'),
    ];
    // Exact match
    final r1 = pickBestPackage(rows, activities: 5, shareholders: 5, tenure: 2);
    expect(r1?.tenureYears, '2');
    // Higher tenure fallback
    final r2 = pickBestPackage(rows, activities: 3, shareholders: 2, tenure: 5);
    expect(r2?.tenureYears, '3'); // closest higher or last
  });
}
