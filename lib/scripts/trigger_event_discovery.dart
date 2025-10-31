import 'package:cloud_functions/cloud_functions.dart';

/// Script to manually trigger event discovery for testing
/// Run this from main.dart or create a test button in your app
Future<void> triggerEventDiscovery() async {
  try {
    print('Triggering event discovery...');

    final functions = FirebaseFunctions.instanceFor(region: 'us-central1');
    final result = await functions
        .httpsCallable('triggerEventDiscovery')
        .call();

    print('Success! Result: ${result.data}');
    print('Events should now be available in Firestore');
  } catch (e) {
    print('Error triggering event discovery: $e');
    print('Note: You must be authenticated to use this function');
  }
}
