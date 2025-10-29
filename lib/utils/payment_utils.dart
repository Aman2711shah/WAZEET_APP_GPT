import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';

/// Initialize Stripe payment and present PaymentSheet
Future<void> payForApplication(String applicationId, double amountAED) async {
  try {
    // 1) Get clientSecret from Cloud Function
    final callable = FirebaseFunctions.instanceFor(
      region: 'me-central1',
    ).httpsCallable('createPaymentIntent');
    final resp = await callable.call({
      'amount': amountAED,
      'applicationId': applicationId,
    });
    final clientSecret = (resp.data as Map)['clientSecret'] as String;

    // 2) Init & present PaymentSheet
    await Stripe.instance.initPaymentSheet(
      paymentSheetParameters: SetupPaymentSheetParameters(
        paymentIntentClientSecret: clientSecret,
        merchantDisplayName: 'WAZEET',
        style: ThemeMode.system,
      ),
    );
    await Stripe.instance.presentPaymentSheet();

    // 3) Save payment status to Firestore
    await FirebaseFirestore.instance.collection('payments').add({
      'application_id': applicationId,
      'amount': amountAED,
      'currency': 'AED',
      'status': 'paid',
      'created_at': FieldValue.serverTimestamp(),
    });
  } catch (e) {
    // Handle error (e.g., user cancellation)
    rethrow;
  }
}
