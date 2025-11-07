import 'dart:convert';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Message model for AI chat
class ChatMessage {
  final String role; // 'user' or 'assistant' or 'system'
  final String content;
  final DateTime timestamp;

  ChatMessage({required this.role, required this.content, DateTime? timestamp})
    : timestamp = timestamp ?? DateTime.now();

  Map<String, dynamic> toJson() => {
    'role': role,
    'content': content,
    'timestamp': timestamp.toIso8601String(),
  };

  factory ChatMessage.fromJson(Map<String, dynamic> json) => ChatMessage(
    role: json['role'] as String,
    content: json['content'] as String,
    timestamp: DateTime.parse(json['timestamp'] as String),
  );
}

/// Service for AI chat operations using Firebase Functions
class AIChatService {
  static const String _storageKey = 'ai_chat_history';
  static const int _maxStoredMessages = 10;
  static const String _systemPrompt =
      'You are a helpful assistant for UAE company setup, free zones, licensing, costs, and documentation. Answer concisely, state assumptions, and suggest next steps when uncertain.';

  final FirebaseFunctions _functions;

  AIChatService({FirebaseFunctions? functions})
    : _functions = functions ?? FirebaseFunctions.instance;

  /// Send a message to the AI and get a response
  /// Returns the assistant's response text or null on error
  Future<String?> sendMessage({
    required String userMessage,
    required List<ChatMessage> conversationHistory,
    required BuildContext context,
  }) async {
    try {
      // Build messages array with system prompt
      final messages = [
        {'role': 'system', 'content': _systemPrompt},
        ...conversationHistory.map(
          (m) => {'role': m.role, 'content': m.content},
        ),
        {'role': 'user', 'content': userMessage},
      ];

      // Call Firebase Function (which will call OpenAI API with the key)
      final callable = _functions.httpsCallable('aiChat');
      final result = await callable.call({'messages': messages});

      final data = result.data as Map<String, dynamic>;
      return data['text'] as String?;
    } catch (e) {
      debugPrint('AI Chat error: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('AI Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return null;
    }
  }

  /// Save chat history to local storage
  Future<void> saveChatHistory(List<ChatMessage> messages) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      // Keep only last N messages
      final toStore = messages.length > _maxStoredMessages
          ? messages.sublist(messages.length - _maxStoredMessages)
          : messages;

      final jsonList = toStore.map((m) => m.toJson()).toList();
      await prefs.setString(_storageKey, jsonEncode(jsonList));
    } catch (e) {
      debugPrint('Error saving chat history: $e');
    }
  }

  /// Load chat history from local storage
  Future<List<ChatMessage>> loadChatHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_storageKey);
      if (jsonString == null) return [];

      final jsonList = jsonDecode(jsonString) as List<dynamic>;
      return jsonList
          .map((json) => ChatMessage.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('Error loading chat history: $e');
      return [];
    }
  }

  /// Clear chat history from local storage
  Future<void> clearChatHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_storageKey);
    } catch (e) {
      debugPrint('Error clearing chat history: $e');
    }
  }
}
