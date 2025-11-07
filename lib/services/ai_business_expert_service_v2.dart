import 'package:flutter/foundation.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import '../models/freezone_rec.dart';

/// Enhanced AI Business Expert service with streaming and tool-call support
class AIBusinessExpertServiceV2 {
  static const String _functionUrl =
      'https://us-central1-business-setup-application.cloudfunctions.net/aiBusinessChat';

  // Retry configuration
  static const int _maxRetries = 3;
  static const Duration _initialRetryDelay = Duration(milliseconds: 800);

  // Circuit breaker for rate limiting
  static DateTime? _circuitBreakerUntil;
  static int _consecutiveRateLimits = 0;

  // Current recommendations
  static final ValueNotifier<List<FreezoneRec>> recommendations = ValueNotifier(
    [],
  );

  /// Send a message with streaming response
  /// Returns a stream of partial responses as they arrive
  static Stream<AIStreamEvent> sendMessageStream({
    required String userMessage,
    required List<Map<String, String>> conversationHistory,
    Map<String, dynamic>? filters,
  }) async* {
    // Check circuit breaker
    if (_circuitBreakerUntil != null &&
        DateTime.now().isBefore(_circuitBreakerUntil!)) {
      yield AIStreamEvent.error(
        'Service temporarily unavailable. Please try again in a moment.',
      );
      return;
    }

    // Get Firebase auth token
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      yield AIStreamEvent.error('Please sign in to use this feature.');
      return;
    }

    String? idToken;
    try {
      idToken = await user.getIdToken();
    } catch (e) {
      yield AIStreamEvent.error('Authentication error. Please sign in again.');
      return;
    }

    // Build messages array
    final messages = [
      ...conversationHistory,
      {'role': 'user', 'content': userMessage},
    ];

    // Retry logic with exponential backoff
    int retryCount = 0;
    Duration retryDelay = _initialRetryDelay;

    while (retryCount <= _maxRetries) {
      try {
        final request = http.Request('POST', Uri.parse(_functionUrl));
        request.headers.addAll({
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $idToken',
          'Accept': 'text/event-stream',
        });

        request.body = jsonEncode({
          'messages': messages,
          'userId': user.uid,
          if (filters != null) 'filters': filters,
        });

        // Send request
        final streamedResponse = await request.send().timeout(
          const Duration(seconds: 15),
          onTimeout: () {
            throw TimeoutException('Request timed out');
          },
        );

        if (streamedResponse.statusCode == 200) {
          // Reset rate limit counters on success
          _consecutiveRateLimits = 0;
          _circuitBreakerUntil = null;

          // Parse SSE stream
          String buffer = '';
          await for (final chunk in streamedResponse.stream.transform(
            utf8.decoder,
          )) {
            buffer += chunk;

            // Process complete SSE messages
            final lines = buffer.split('\n\n');
            buffer = lines.removeLast(); // Keep incomplete message in buffer

            for (final line in lines) {
              if (line.startsWith('data: ')) {
                final jsonData = line.substring(6);
                try {
                  final data = jsonDecode(jsonData);
                  final event = AIStreamEvent.fromJson(data);

                  // Handle tool calls
                  if (event.type == AIStreamEventType.toolCall &&
                      event.toolName == 'recommend_freezones' &&
                      event.toolResult != null) {
                    _processRecommendations(event.toolResult!);
                  }

                  yield event;
                } catch (e) {
                  debugPrint('Error parsing SSE data: $e');
                }
              }
            }
          }

          return; // Success, exit retry loop
        } else if (streamedResponse.statusCode == 429) {
          // Rate limiting
          _consecutiveRateLimits++;

          if (_consecutiveRateLimits >= 3) {
            // Enable circuit breaker
            _circuitBreakerUntil = DateTime.now().add(
              const Duration(minutes: 1),
            );
            yield AIStreamEvent.error(
              'Too many requests. Please wait a moment before trying again.',
            );
            return;
          }

          // Retry with backoff
          if (retryCount < _maxRetries) {
            await Future.delayed(retryDelay);
            retryDelay *= 2;
            retryCount++;
            continue;
          } else {
            yield AIStreamEvent.error(
              'Service is busy. Please try again later.',
            );
            return;
          }
        } else if (streamedResponse.statusCode == 401) {
          yield AIStreamEvent.error(
            'Authentication failed. Please sign in again.',
          );
          return;
        } else {
          throw Exception('HTTP ${streamedResponse.statusCode}');
        }
      } on TimeoutException {
        if (retryCount < _maxRetries) {
          await Future.delayed(retryDelay);
          retryDelay *= 2;
          retryCount++;
          continue;
        } else {
          yield AIStreamEvent.error(
            'Connection timeout. Please check your internet and try again.',
          );
          return;
        }
      } catch (e) {
        debugPrint('Error in AI stream: $e');
        if (retryCount < _maxRetries) {
          await Future.delayed(retryDelay);
          retryDelay *= 2;
          retryCount++;
          continue;
        } else {
          yield AIStreamEvent.error('An error occurred. Please try again.');
          return;
        }
      }
    }
  }

  /// Process recommendations from tool result
  static void _processRecommendations(Map<String, dynamic> toolResult) {
    try {
      final recs = toolResult['recommendations'] as List?;
      if (recs != null) {
        final freezoneRecs = recs.map((r) {
          return FreezoneRec(
            name: r['name'] ?? '',
            id: r['id'] ?? r['abbreviation']?.toLowerCase(),
          );
        }).toList();

        recommendations.value = freezoneRecs;
        debugPrint('✅ Processed ${freezoneRecs.length} recommendations');
      }
    } catch (e) {
      debugPrint('Error processing recommendations: $e');
    }
  }

  /// Generate initial greeting message
  static String getInitialGreeting() {
    return "👋 Welcome! I'm your AI Business Expert.\n\nI'll help you find the perfect business setup in the UAE by asking a few questions about your plans.\n\nLet's start: What type of business are you planning to launch?";
  }

  /// Clear current recommendations
  static void clearRecommendations() {
    recommendations.value = [];
  }
}

/// AI Stream Event types
enum AIStreamEventType { content, toolCall, done, error }

/// AI Stream Event
class AIStreamEvent {
  final AIStreamEventType type;
  final String? content;
  final String? fullContent;
  final String? error;
  final String? toolName;
  final Map<String, dynamic>? toolResult;

  AIStreamEvent({
    required this.type,
    this.content,
    this.fullContent,
    this.error,
    this.toolName,
    this.toolResult,
  });

  factory AIStreamEvent.content(String content) {
    return AIStreamEvent(type: AIStreamEventType.content, content: content);
  }

  factory AIStreamEvent.toolCall(String toolName, Map<String, dynamic> result) {
    return AIStreamEvent(
      type: AIStreamEventType.toolCall,
      toolName: toolName,
      toolResult: result,
    );
  }

  factory AIStreamEvent.done(String fullContent) {
    return AIStreamEvent(
      type: AIStreamEventType.done,
      fullContent: fullContent,
    );
  }

  factory AIStreamEvent.error(String error) {
    return AIStreamEvent(type: AIStreamEventType.error, error: error);
  }

  factory AIStreamEvent.fromJson(Map<String, dynamic> json) {
    final typeStr = json['type'] as String;

    switch (typeStr) {
      case 'content':
        return AIStreamEvent.content(json['content'] ?? '');
      case 'tool_call':
        return AIStreamEvent.toolCall(
          json['tool'] ?? '',
          json['result'] as Map<String, dynamic>? ?? {},
        );
      case 'done':
        return AIStreamEvent.done(json['fullContent'] ?? '');
      case 'error':
        return AIStreamEvent.error(json['error'] ?? 'Unknown error');
      default:
        return AIStreamEvent.error('Unknown event type: $typeStr');
    }
  }

  bool get isError => type == AIStreamEventType.error;
  bool get isDone => type == AIStreamEventType.done;
  bool get isContent => type == AIStreamEventType.content;
  bool get isToolCall => type == AIStreamEventType.toolCall;
}
