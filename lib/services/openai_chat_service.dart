import 'package:flutter/foundation.dart';
import 'remote_ai_client.dart';

/// Deprecated: Kept for backward compatibility in case any imports remain.
/// Routes all calls through the secure backend proxy via [RemoteAIClient].
class OpenAIChatService {
  final RemoteAIClient _client = RemoteAIClient();

  Future<String> sendMessage(
    String userMessage, {
    List<Map<String, String>>? conversationHistory,
  }) async {
    final messages = <Map<String, String>>[
      {
        'role': 'system',
        'content':
            'You are a knowledgeable business expert for UAE business setup. Be concise and helpful.',
      },
      ...?conversationHistory,
      {'role': 'user', 'content': userMessage},
    ];
    try {
      return await _client.sendChat(messages.cast<Map<String, dynamic>>());
    } catch (e) {
      debugPrint('AI proxy error: $e');
      rethrow;
    }
  }

  Stream<String> sendMessageStream(
    String userMessage, {
    List<Map<String, String>>? conversationHistory,
  }) async* {
    final messages = <Map<String, String>>[
      {
        'role': 'system',
        'content':
            'You are a knowledgeable business expert for UAE business setup. Be concise and helpful.',
      },
      ...?conversationHistory,
      {'role': 'user', 'content': userMessage},
    ];
    yield* _client.sendChatStream(messages.cast<Map<String, dynamic>>());
  }
}
