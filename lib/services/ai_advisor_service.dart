import 'package:flutter/foundation.dart';
import 'remote_ai_client.dart';

/// Simple AI Advisor service calling the secure backend proxy.
class AiAdvisorService {
  AiAdvisorService();
  static final RemoteAIClient _client = RemoteAIClient();

  Future<String> getAdvice({
    required String question,
    String systemPrompt =
        'You are WAZEET AI Business Advisor. Be concise, actionable, and friendly. Use UAE context when relevant.',
  }) async {
    try {
      final messages = [
        {'role': 'system', 'content': systemPrompt},
        {'role': 'user', 'content': question},
      ];

      final text = await _client.sendChat(
        messages.cast<Map<String, dynamic>>(),
      );
      if (text.trim().isEmpty) {
        return 'I couldn\'t generate advice right now. Please try again.';
      }
      return text;
    } catch (e) {
      if (kDebugMode) debugPrint('AI exception: $e');
      return 'Couldn\'t reach the AI advisor. Check your connection and try again.';
    }
  }
}
