import 'package:flutter/foundation.dart';

import 'package:cloud_functions/cloud_functions.dart';

/// Script to manually trigger event discovery for testing
/// Run this from main.dart or create a test button in your app
Future<void> triggerEventDiscovery() async {
  try {
    debugPrint('Triggering event discovery...');

    final functions = FirebaseFunctions.instanceFor(region: 'us-central1');
    final result = await functions
        .httpsCallable('triggerEventDiscovery')
        .call();

    debugPrint('Success! Result: ${result.data}');
    debugPrint('Events should now be available in Firestore');
  } catch (e) {
    debugPrint('Error triggering event discovery: $e');
    debugPrint('Note: You must be authenticated to use this function');
  }
}
