import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/foundation.dart';

/// Service for general business chat with OpenAI ChatGPT
class OpenAIChatService {
  static const String _baseUrl = 'https://api.openai.com/v1/chat/completions';

  final String _apiKey;

  OpenAIChatService() : _apiKey = dotenv.env['OPENAI_API_KEY'] ?? '';

  /// Send a message to ChatGPT and get a response
  Future<String> sendMessage(
    String userMessage, {
    List<Map<String, String>>? conversationHistory,
  }) async {
    if (_apiKey.isEmpty) {
      throw Exception(
        'OpenAI API key not configured. Please add OPENAI_API_KEY to your .env file.\n\n'
        'Example:\nOPENAI_API_KEY=sk-your-key-here',
      );
    }

    // Build messages array with system prompt and conversation history
    final messages = <Map<String, String>>[
      {
        'role': 'system',
        'content':
            '''You are a knowledgeable business expert specialized in UAE business regulations, company formation, free zones, visa requirements, and business operations in Dubai and the UAE. 

Your expertise includes:
- UAE company setup and business licenses
- Free zone vs mainland company comparison
- Visa requirements and golden visa programs
- Business banking and financial regulations
- Tax regulations (VAT, corporate tax)
- Employment and labor laws
- Commercial property and leasing
- Import/export regulations
- Industry-specific requirements

Provide clear, accurate, and actionable advice. When discussing costs or specific regulations, mention that details may vary and recommend consulting official sources or Wazeet services for the most current information.

Keep responses concise but informative. Use bullet points for clarity when listing options or steps.''',
      },
      ...?conversationHistory,
      {'role': 'user', 'content': userMessage},
    ];

    try {
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_apiKey',
        },
        body: jsonEncode({
          'model': 'gpt-4o-mini', // Using the faster, cost-effective model
          'messages': messages,
          'temperature': 0.7,
          'max_tokens': 800,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final content = data['choices'][0]['message']['content'] as String;
        return content.trim();
      } else {
        final errorData = jsonDecode(response.body);
        final errorMsg = errorData['error']['message'] ?? 'Unknown error';
        throw Exception('OpenAI API error: $errorMsg');
      }
    } catch (e) {
      debugPrint('OpenAI API error: $e');
      throw Exception('Failed to get AI response: $e');
    }
  }

  /// Send a message with streaming response (for real-time typing effect)
  Stream<String> sendMessageStream(
    String userMessage, {
    List<Map<String, String>>? conversationHistory,
  }) async* {
    if (_apiKey.isEmpty) {
      throw Exception(
        'OpenAI API key not configured. Please add OPENAI_API_KEY to your .env file.',
      );
    }

    final messages = <Map<String, String>>[
      {
        'role': 'system',
        'content':
            '''You are a knowledgeable business expert specialized in UAE business regulations, company formation, free zones, visa requirements, and business operations in Dubai and the UAE. Provide clear, accurate, and actionable advice. Keep responses concise and use bullet points when helpful.''',
      },
      ...?conversationHistory,
      {'role': 'user', 'content': userMessage},
    ];

    final request = http.Request('POST', Uri.parse(_baseUrl));
    request.headers.addAll({
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $_apiKey',
    });
    request.body = jsonEncode({
      'model': 'gpt-4o-mini',
      'messages': messages,
      'temperature': 0.7,
      'max_tokens': 800,
      'stream': true,
    });

    try {
      final streamedResponse = await request.send();

      if (streamedResponse.statusCode != 200) {
        final errorBody = await streamedResponse.stream.bytesToString();
        debugPrint('Streaming API error: $errorBody');
        throw Exception(
          'API error (${streamedResponse.statusCode}): $errorBody',
        );
      }

      await for (var chunk in streamedResponse.stream.transform(utf8.decoder)) {
        final lines = chunk.split('\n');
        for (var line in lines) {
          if (line.startsWith('data: ')) {
            final data = line.substring(6).trim();
            if (data == '[DONE]') continue;

            try {
              final jsonData = jsonDecode(data);
              final delta = jsonData['choices']?[0]?['delta'];
              if (delta != null && delta['content'] != null) {
                yield delta['content'] as String;
              }
            } catch (e) {
              // Skip invalid JSON chunks
              debugPrint('Skipping invalid chunk: $e');
            }
          }
        }
      }
    } catch (e) {
      debugPrint('Streaming error: $e');
      throw Exception('Streaming failed: $e');
    }
  }
}
