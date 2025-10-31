import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';

/// AI Business Expert service for interactive business consultation
/// Maintains conversation context and guides users through setup decisions
class AIBusinessExpertService {
  static const String _apiUrl = 'https://api.openai.com/v1/chat/completions';
  static const String _systemPrompt = '''
You are an expert UAE business setup consultant with deep knowledge of freezones, mainland licenses, and business structures.

Your role is to have a natural, consultative conversation with entrepreneurs to understand their needs and recommend the best business setup options.

Follow this conversation flow:
1. Start warmly and ask about their business idea/activity
2. Ask about number of shareholders/owners
3. Ask about visa requirements (for themselves and employees)
4. Ask if they'll do business inside UAE (mainland) or internationally (freezone)
5. Ask about their budget range (optional but helpful)
6. Based on answers, provide 2-3 specific freezone or mainland recommendations with clear reasoning

Keep responses:
- Warm and conversational (like a helpful consultant)
- Brief (2-3 sentences max per question)
- Focused on one question at a time
- Professional but friendly

When you have enough information, provide recommendations in this exact format:

RECOMMENDATIONS:
1. [Freezone Name]: [Brief reason why it fits]
2. [Freezone Name]: [Brief reason why it fits]
3. [Freezone Name]: [Brief reason why it fits]

SETUP_TYPE: [Freezone or Mainland]
BUSINESS_ACTIVITY: [extracted activity]
VISA_COUNT: [number]
BUDGET: [low/medium/high]
''';

  /// Send a message and get AI response with conversation history
  static Future<String> sendMessage({
    required String userMessage,
    required List<Map<String, String>> conversationHistory,
  }) async {
    try {
      if (!AppConfig.hasOpenAiKey) {
        return _getFallbackResponse(conversationHistory.length);
      }

      // Build messages array with system prompt + history + new message
      final messages = [
        {'role': 'system', 'content': _systemPrompt},
        ...conversationHistory,
        {'role': 'user', 'content': userMessage},
      ];

      final response = await http.post(
        Uri.parse(_apiUrl),
        headers: {
          'Authorization': 'Bearer ${AppConfig.openAiApiKey}',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'model': 'gpt-4o-mini',
          'messages': messages,
          'temperature': 0.7,
          'max_tokens': 500,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['choices'][0]['message']['content'];
      } else {
        print('API Error: ${response.statusCode} - ${response.body}');
        return _getFallbackResponse(conversationHistory.length);
      }
    } catch (e) {
      print('Error in AI Business Expert: $e');
      return _getFallbackResponse(conversationHistory.length);
    }
  }

  /// Extract business requirements from conversation when recommendations are given
  static Map<String, dynamic>? extractBusinessRequirements(String aiResponse) {
    if (!aiResponse.contains('RECOMMENDATIONS:')) {
      return null;
    }

    try {
      final requirements = <String, dynamic>{};

      // Extract setup type
      final setupTypeMatch = RegExp(
        r'SETUP_TYPE:\s*(\w+)',
        caseSensitive: false,
      ).firstMatch(aiResponse);
      if (setupTypeMatch != null) {
        requirements['setupType'] = setupTypeMatch.group(1)?.toLowerCase();
      }

      // Extract business activity
      final activityMatch = RegExp(
        r'BUSINESS_ACTIVITY:\s*(.+)',
        caseSensitive: false,
      ).firstMatch(aiResponse);
      if (activityMatch != null) {
        requirements['activity'] = activityMatch.group(1)?.trim();
      }

      // Extract visa count
      final visaMatch = RegExp(
        r'VISA_COUNT:\s*(\d+)',
        caseSensitive: false,
      ).firstMatch(aiResponse);
      if (visaMatch != null) {
        requirements['visaCount'] = int.tryParse(visaMatch.group(1) ?? '0');
      }

      // Extract budget
      final budgetMatch = RegExp(
        r'BUDGET:\s*(\w+)',
        caseSensitive: false,
      ).firstMatch(aiResponse);
      if (budgetMatch != null) {
        requirements['budget'] = budgetMatch.group(1)?.toLowerCase();
      }

      // Extract recommended freezones
      final recommendations = <String>[];
      final recSection = aiResponse.split('RECOMMENDATIONS:')[1].split('\n');
      for (final line in recSection) {
        final match = RegExp(
          r'\d+\.\s*([A-Z\s]+):',
          caseSensitive: false,
        ).firstMatch(line);
        if (match != null) {
          recommendations.add(match.group(1)!.trim());
        }
      }
      requirements['recommendations'] = recommendations;

      return requirements;
    } catch (e) {
      print('Error extracting requirements: $e');
      return null;
    }
  }

  /// Fallback responses when API is unavailable
  static String _getFallbackResponse(int messageCount) {
    switch (messageCount) {
      case 0:
        return "Hello! I'm here to help you set up your business in the UAE. What type of business are you planning to start?";
      case 2:
        return "That sounds interesting! How many shareholders or business partners will be involved?";
      case 4:
        return "Great. Will you need employment visas? If so, how many (including yourself)?";
      case 6:
        return "Perfect. Will you be doing business primarily inside the UAE (requiring mainland license) or internationally (suitable for freezone)?";
      case 8:
        return """
RECOMMENDATIONS:
1. RAKEZ: Cost-effective option with fast setup, ideal for international business
2. IFZA: Excellent support and modern facilities, great for service businesses
3. Meydan Freezone: Premium Dubai location with strong reputation

SETUP_TYPE: Freezone
BUSINESS_ACTIVITY: General Trading
VISA_COUNT: 2
BUDGET: medium
""";
      default:
        return "Thank you for sharing that information. Could you tell me more about your budget expectations?";
    }
  }

  /// Generate initial greeting message
  static String getInitialGreeting() {
    return "👋 Welcome! I'm your AI Business Expert.\n\nI'll help you find the perfect business setup in the UAE by asking a few questions about your plans.\n\nLet's start: What type of business are you planning to launch?";
  }
}
