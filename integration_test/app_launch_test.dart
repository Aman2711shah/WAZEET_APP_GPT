import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:wazeet/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('app boots and shows main navigation', (tester) async {
    app.main();

    // Allow initial frames, async inits, and first layout.
    await tester.pumpAndSettle(const Duration(seconds: 5));

    // Validate that the bottom nav renders and Community tab is present.
    expect(find.text('Community'), findsOneWidget);
    expect(find.bySemanticsLabel('Community Tab'), findsOneWidget);
  });
}
