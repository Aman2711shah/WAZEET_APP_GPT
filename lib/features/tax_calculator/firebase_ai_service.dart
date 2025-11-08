import 'package:cloud_functions/cloud_functions.dart';

class FirebaseAIService {
  FirebaseAIService({FirebaseFunctions? functions})
    : _functions = functions ?? FirebaseFunctions.instance;

  final FirebaseFunctions _functions;

  /// Calls the callable function `aiTaxExplain` to get a human-friendly
  /// explanation of the calculation and guidance. Returns plain text.
  Future<String> explainTax({required Map<String, dynamic> payload}) async {
    final callable = _functions.httpsCallable('aiTaxExplain');
    final result = await callable.call(payload);
    final data = result.data;
    if (data is Map && data['ok'] == true && data['text'] is String) {
      return data['text'] as String;
    }
    throw Exception('aiTaxExplain returned unexpected response');
  }
}
