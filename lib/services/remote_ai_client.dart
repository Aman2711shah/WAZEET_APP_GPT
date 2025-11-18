import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:wazeet/config/app_config.dart';

/// Lightweight HTTP client that calls the Firebase Cloud Function proxy.
/// The server handles the actual OpenAI request so no API keys live on device.
class RemoteAIClient {
  RemoteAIClient({
    http.Client? client,
    String? baseUrl,
    String? chatPath,
  })  : _client = client ?? http.Client(),
        _baseUrl = baseUrl ?? AppConfig.backendBaseUrl,
        _chatPath = chatPath ?? AppConfig.backendChatPath;

  final http.Client _client;
  final String _baseUrl;
  final String _chatPath;

  Uri get _chatUri {
    final normalizedBase =
        _baseUrl.endsWith('/') ? _baseUrl.substring(0, _baseUrl.length - 1) : _baseUrl;
    final normalizedPath = _chatPath.startsWith('/') ? _chatPath : '/$_chatPath';
    return Uri.parse('$normalizedBase$normalizedPath');
  }

  /// Send a chat completion request to the backend proxy.
  /// Returns the assistant message string or a friendly fallback.
  Future<String> sendChat(List<Map<String, dynamic>> messages) async {
    try {
      final resp = await _client.post(
        _chatUri,
        headers: const {'Content-Type': 'application/json'},
        body: jsonEncode({'messages': messages}),
      );

      if (resp.statusCode != 200) {
        if (kDebugMode) {
          debugPrint(
            'RemoteAIClient error ${resp.statusCode}: ${resp.body}',
          );
        }
        return 'AI service error (${resp.statusCode}). Please try again later.';
      }

      final data = jsonDecode(resp.body);
      if (data is Map<String, dynamic>) {
        final message = data['message'];
        if (message is String && message.trim().isNotEmpty) {
          return message.trim();
        }
      }
      return 'The AI response was empty. Please try again.';
    } catch (error) {
      if (kDebugMode) debugPrint('RemoteAIClient exception: $error');
      return 'Could not reach the AI service. Check your internet connection and try again.';
    }
  }

  /// Convenience wrapper so existing streaming UIs work even if backend
  /// returns a single response payload.
  Stream<String> sendChatStream(List<Map<String, dynamic>> messages) async* {
    yield await sendChat(messages);
  }
}
