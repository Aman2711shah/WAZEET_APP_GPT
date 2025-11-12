import 'package:flutter_test/flutter_test.dart';
import 'package:wazeet/features/quote/logic/normalizers.dart';

void main() {
  test('parseMoney normalizes FREE/TBD', () {
    expect(parseMoney('FREE'), 0.0);
    expect(parseMoney('TBD'), isNull);
    expect(parseMoney('Not Applicable'), isNull);
  });

  test('parseActivitiesCount extracts number', () {
    expect(parseActivitiesCount('5 Mix & Match'), 5);
    expect(parseActivitiesCount('7 activities'), 7);
    expect(parseActivitiesCount(null), 0);
  });
}
