import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';

/// Initialize Stripe payment and present PaymentSheet
/// Pay for an application with dynamic tier pricing.
/// Pass the tier ('standard' or 'premium') so backend can record metadata.
Future<void> payForApplication(
  String applicationId,
  double amountAED, {
  String tier = 'standard',
}) async {
  try {
    // 1) Get clientSecret from Cloud Function
    final callable = FirebaseFunctions.instanceFor(
      region: 'us-central1',
    ).httpsCallable('createPaymentIntent');
    final resp = await callable.call({
      'amount': amountAED,
      'applicationId': applicationId,
      'tier': tier,
    });
    final data = resp.data as Map;
    final clientSecret = data['clientSecret'] as String?;
    if (clientSecret == null || clientSecret.isEmpty) {
      throw Exception('Missing client secret from payment initializer');
    }

    // 2) Init & present PaymentSheet
    await Stripe.instance.initPaymentSheet(
      paymentSheetParameters: SetupPaymentSheetParameters(
        paymentIntentClientSecret: clientSecret,
        merchantDisplayName: 'WAZEET',
        style: ThemeMode.system,
      ),
    );
    await Stripe.instance.presentPaymentSheet();

    // 3) Save payment status to Firestore (this will trigger HubSpot sync)
    final userId = FirebaseAuth.instance.currentUser?.uid;
    final paymentRef = await FirebaseFirestore.instance
        .collection('payments')
        .add({
          'application_id': applicationId,
          'user_id': userId,
          'amount': amountAED,
          'currency': 'AED',
          'status': 'paid',
          'tier': tier,
          'payment_intent_id': data['paymentIntentId'],
          'created_at': FieldValue.serverTimestamp(),
        });

    // 4) Fallback: Manually trigger HubSpot sync while Firestore trigger is pending
    //    This ensures leads are created immediately after successful payment.
    try {
      final hubspotSync = FirebaseFunctions.instanceFor(
        region: 'us-central1',
      ).httpsCallable('syncPaymentToHubSpotManual');

      await hubspotSync.call({'paymentId': paymentRef.id});
    } catch (e) {
      // Don't block payment flow if HubSpot sync fails; it can be retried later
      debugPrint('HubSpot manual sync failed: $e');
    }
  } on FirebaseFunctionsException catch (e) {
    // Map well-known errors to friendlier messages for the UI layer
    String msg;
    switch (e.code) {
      case 'unauthenticated':
        msg = 'Please sign in to continue with payment.';
        break;
      case 'failed-precondition':
        msg = 'Payment is temporarily unavailable (configuration). Please try again later.';
        break;
      case 'invalid-argument':
        msg = 'Invalid payment amount. Please contact support if this persists.';
        break;
      default:
        msg = e.message ?? 'Payment failed. Please try again.';
    }
    throw Exception('Payment initialization failed: $msg');
  } catch (e) {
    throw Exception('Payment initialization failed: $e');
  }
}
