import 'package:flutter/foundation.dart';
import 'remote_ai_client.dart';

/// AI Business Expert service for interactive business consultation
/// Maintains conversation context and guides users through setup decisions
class AIBusinessExpertService {
  // No direct OpenAI calls in client; use backend proxy
  static final RemoteAIClient _client = RemoteAIClient();
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

  // Context window configuration
  static const int _maxContextMessages =
      20; // Keep last 20 messages (10 exchanges)
  static const int _maxTokensEstimate =
      8000; // gpt-4o-mini has 128k context, but we'll be conservative

  /// Estimate token count for a message (rough approximation: 1 token ≈ 4 characters)
  static int _estimateTokens(String text) {
    return (text.length / 4).ceil();
  }

  /// Trim conversation history to prevent context overflow using sliding window
  static List<Map<String, String>> _trimConversationHistory(
    List<Map<String, String>> history,
  ) {
    if (history.isEmpty) return history;

    // First, limit by message count (sliding window)
    var trimmedHistory = history.length > _maxContextMessages
        ? history.sublist(history.length - _maxContextMessages)
        : history;

    // Then, check estimated token count
    int totalTokens = _estimateTokens(_systemPrompt);
    final List<Map<String, String>> finalHistory = [];

    // Add messages from most recent to oldest until we hit token limit
    for (int i = trimmedHistory.length - 1; i >= 0; i--) {
      final message = trimmedHistory[i];
      final messageTokens = _estimateTokens(message['content'] ?? '');

      if (totalTokens + messageTokens > _maxTokensEstimate) {
        debugPrint(
          'Context window limit reached. Keeping last ${finalHistory.length} messages.',
        );
        break;
      }

      finalHistory.insert(0, message);
      totalTokens += messageTokens;
    }

    // Always keep at least the last 4 messages (2 exchanges) if possible
    if (finalHistory.length < 4 && trimmedHistory.length >= 4) {
      return trimmedHistory.sublist(trimmedHistory.length - 4);
    }

    return finalHistory;
  }

  /// Send a message and get AI response with conversation history
  static Future<String> sendMessage({
    required String userMessage,
    required List<Map<String, String>> conversationHistory,
  }) async {
    try {
      // Trim conversation history to prevent context overflow
      final trimmedHistory = _trimConversationHistory(conversationHistory);

      if (trimmedHistory.length < conversationHistory.length) {
        debugPrint(
          'Trimmed conversation from ${conversationHistory.length} to ${trimmedHistory.length} messages',
        );
      }

      // Build messages array with system prompt + trimmed history + new message
      final messages = [
        {'role': 'system', 'content': _systemPrompt},
        ...trimmedHistory,
        {'role': 'user', 'content': userMessage},
      ];

      final text = await _client.sendChat(
        messages.cast<Map<String, dynamic>>(),
      );

      if (text.trim().isEmpty) {
        return _getFallbackResponse(conversationHistory.length);
      }

      return text;
    } catch (e) {
      debugPrint('Error in AI Business Expert: $e');
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
      debugPrint('Error extracting requirements: $e');
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
