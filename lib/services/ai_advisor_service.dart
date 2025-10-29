import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

/// Simple AI Advisor service. Uses OpenAI-compatible Chat Completions API.
///
/// Configure an API key securely (do not hardcode in the app):
/// - For local dev, set an environment variable or use a secure backend proxy.
/// - In production, route through your backend to avoid exposing secrets on web.
class AiAdvisorService {
  AiAdvisorService({http.Client? client, String? baseUrl, String? model})
    : _client = client ?? http.Client(),
      _baseUrl = baseUrl ?? 'https://api.openai.com/v1/chat/completions',
      _model = model ?? 'gpt-4o-mini';

  final http.Client _client;
  final String _baseUrl;
  final String _model;

  /// Provide the API key at call time. On web, never ship secrets in client code.
  /// Prefer passing an empty key ("") which will return a safe demo response.
  Future<String> getAdvice({
    required String question,
    String apiKey = '',
    String systemPrompt =
        'You are WAZEET AI Business Advisor. Be concise, actionable, and friendly. Use UAE context when relevant.',
  }) async {
    // If no API key provided, return a demo answer so UI can still be exercised.
    if (apiKey.isEmpty) {
      return 'Here\'s a quick insight: For UAE company setup, pick a free zone aligned with your activity (e.g., tech in DIFC/ADGM, e‑commerce in Dubai CommerCity). Budget for license + visa + bank KYC, and prepare UBO and MOA docs early to avoid delays.';
    }

    try {
      final resp = await _client.post(
        Uri.parse(_baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey',
        },
        body: jsonEncode({
          'model': _model,
          'messages': [
            {'role': 'system', 'content': systemPrompt},
            {'role': 'user', 'content': question},
          ],
          'temperature': 0.3,
          'max_tokens': 400,
        }),
      );

      if (resp.statusCode >= 200 && resp.statusCode < 300) {
        final data = jsonDecode(resp.body) as Map<String, dynamic>;
        final choices = data['choices'] as List<dynamic>?;
        String content = '';
        if (choices != null && choices.isNotEmpty) {
          final msg = choices.first is Map<String, dynamic>
              ? choices.first as Map<String, dynamic>
              : <String, dynamic>{};
          final message = msg['message'];
          if (message is Map<String, dynamic> && message['content'] is String) {
            content = message['content'] as String;
          }
        }
        if (content.trim().isEmpty) {
          return 'I couldn\'t generate advice right now. Please try again.';
        }
        return content.trim();
      } else {
        if (kDebugMode) {
          debugPrint('AI error ${resp.statusCode}: ${resp.body}');
        }
        return 'AI advisor is temporarily unavailable (HTTP ${resp.statusCode}). Please try again later.';
      }
    } catch (e) {
      if (kDebugMode) debugPrint('AI exception: $e');
      return 'Couldn\'t reach the AI advisor. Check your connection and try again.';
    }
  }
}
