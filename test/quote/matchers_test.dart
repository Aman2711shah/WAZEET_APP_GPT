import 'package:flutter_test/flutter_test.dart';

void main() {
  test('legacy quote engine tests disabled', () {
    // The old quote engine has been removed in favor of Firestore-backed recommendations.
    // This placeholder keeps the test suite green.
    expect(true, isTrue);
  });
}
