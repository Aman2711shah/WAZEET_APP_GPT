import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../theme.dart';
import '../../services/ai_business_expert_service.dart';

/// Chat message model
class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;

  ChatMessage({required this.text, required this.isUser, DateTime? timestamp})
    : timestamp = timestamp ?? DateTime.now();

  Map<String, dynamic> toFirestore() {
    return {
      'text': text,
      'isUser': isUser,
      'timestamp': Timestamp.fromDate(timestamp),
    };
  }

  factory ChatMessage.fromFirestore(Map<String, dynamic> data) {
    return ChatMessage(
      text: data['text'] as String,
      isUser: data['isUser'] as bool,
      timestamp: (data['timestamp'] as Timestamp).toDate(),
    );
  }
}

/// Conversation state provider
final conversationProvider =
    StateNotifierProvider<ConversationNotifier, List<ChatMessage>>((ref) {
      return ConversationNotifier();
    });

class ConversationNotifier extends StateNotifier<List<ChatMessage>> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String? _conversationId;

  ConversationNotifier() : super([]) {
    _loadOrInitializeConversation();
  }

  Future<void> _loadOrInitializeConversation() async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) {
      _initializeConversation();
      return;
    }

    try {
      // Try to load the most recent conversation
      final conversationsSnap = await _firestore
          .collection('ai_conversations')
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .limit(1)
          .get();

      if (conversationsSnap.docs.isNotEmpty) {
        final doc = conversationsSnap.docs.first;
        _conversationId = doc.id;

        // Load messages
        final messagesSnap = await _firestore
            .collection('ai_conversations')
            .doc(_conversationId)
            .collection('messages')
            .orderBy('timestamp', descending: false)
            .get();

        if (messagesSnap.docs.isNotEmpty) {
          state = messagesSnap.docs
              .map((doc) => ChatMessage.fromFirestore(doc.data()))
              .toList();
          return;
        }
      }

      // If no conversation found, create new one
      _initializeConversation();
    } catch (e) {
      debugPrint('Error loading conversation: $e');
      _initializeConversation();
    }
  }

  void _initializeConversation() {
    final greeting = AIBusinessExpertService.getInitialGreeting();
    state = [ChatMessage(text: greeting, isUser: false)];
  }

  Future<void> addMessage(ChatMessage message) async {
    state = [...state, message];

    // Persist to Firestore
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;

    try {
      // Create conversation if it doesn't exist
      if (_conversationId == null) {
        final conversationRef = _firestore.collection('ai_conversations').doc();
        _conversationId = conversationRef.id;

        await conversationRef.set({
          'userId': userId,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
          'messageCount': 1,
        });
      } else {
        // Update conversation timestamp
        await _firestore
            .collection('ai_conversations')
            .doc(_conversationId)
            .update({
              'updatedAt': FieldValue.serverTimestamp(),
              'messageCount': FieldValue.increment(1),
            });
      }

      // Save message
      await _firestore
          .collection('ai_conversations')
          .doc(_conversationId)
          .collection('messages')
          .add(message.toFirestore());
    } catch (e) {
      debugPrint('Error saving message: $e');
      // Don't throw - allow the app to continue working even if save fails
    }
  }

  Future<void> reset() async {
    final userId = _auth.currentUser?.uid;
    if (userId != null && _conversationId != null) {
      try {
        // Archive the old conversation by marking it
        await _firestore
            .collection('ai_conversations')
            .doc(_conversationId)
            .update({'archived': true});
      } catch (e) {
        debugPrint('Error archiving conversation: $e');
      }
    }

    _conversationId = null;
    _initializeConversation();
  }

  List<Map<String, String>> getConversationHistory() {
    return state
        .map(
          (msg) => {
            'role': msg.isUser ? 'user' : 'assistant',
            'content': msg.text,
          },
        )
        .toList();
  }
}

/// AI Business Expert Chat Page
class AIBusinessExpertPage extends ConsumerStatefulWidget {
  const AIBusinessExpertPage({super.key});

  @override
  ConsumerState<AIBusinessExpertPage> createState() =>
      _AIBusinessExpertPageState();
}

class _AIBusinessExpertPageState extends ConsumerState<AIBusinessExpertPage> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isTyping = false;

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty || _isTyping) return;

    // Add user message
    final userMessage = ChatMessage(text: text, isUser: true);
    ref.read(conversationProvider.notifier).addMessage(userMessage);
    _messageController.clear();
    _scrollToBottom();

    // Show typing indicator
    setState(() => _isTyping = true);

    try {
      // Get conversation history
      final history = ref
          .read(conversationProvider.notifier)
          .getConversationHistory();

      // Get AI response
      final response = await AIBusinessExpertService.sendMessage(
        userMessage: text,
        conversationHistory: history,
      );

      // Add AI response
      final aiMessage = ChatMessage(text: response, isUser: false);
      ref.read(conversationProvider.notifier).addMessage(aiMessage);

      _scrollToBottom();
    } catch (e) {
      debugPrint('Error sending message: $e');
      final errorMessage = ChatMessage(
        text:
            "I apologize, I'm having trouble connecting right now. Please try again.",
        isUser: false,
      );
      ref.read(conversationProvider.notifier).addMessage(errorMessage);
    } finally {
      setState(() => _isTyping = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final messages = ref.watch(conversationProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.psychology, size: 24),
            SizedBox(width: 8),
            Text('AI Business Expert'),
          ],
        ),
        backgroundColor: AppColors.primary,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Start Over',
            onPressed: () {
              ref.read(conversationProvider.notifier).reset();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Chat messages
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: messages.length + (_isTyping ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == messages.length) {
                  return _buildTypingIndicator();
                }
                return _buildMessageBubble(messages[index]);
              },
            ),
          ),

          // Input area
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 4,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Type your message...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide(color: AppColors.primary),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                      filled: true,
                      fillColor: Colors.grey[100],
                    ),
                    onSubmitted: (_) => _sendMessage(),
                    textInputAction: TextInputAction.send,
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppColors.primary, AppColors.purple],
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.send, color: Colors.white),
                    onPressed: _isTyping ? null : _sendMessage,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: message.isUser
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!message.isUser) ...[
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.psychology, color: AppColors.primary, size: 20),
            ),
            const SizedBox(width: 12),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: message.isUser ? AppColors.primary : Colors.grey[200],
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(20),
                  topRight: const Radius.circular(20),
                  bottomLeft: Radius.circular(message.isUser ? 20 : 4),
                  bottomRight: Radius.circular(message.isUser ? 4 : 20),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                message.text,
                style: TextStyle(
                  color: message.isUser ? Colors.white : Colors.black87,
                  fontSize: 15,
                  height: 1.4,
                ),
              ),
            ),
          ),
          if (message.isUser) ...[
            const SizedBox(width: 12),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.person, color: Colors.white, size: 20),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.psychology, color: AppColors.primary, size: 20),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildTypingDot(0),
                const SizedBox(width: 4),
                _buildTypingDot(1),
                const SizedBox(width: 4),
                _buildTypingDot(2),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypingDot(int index) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 600),
      builder: (context, value, child) {
        final delay = index * 0.2;
        final animValue = (value - delay).clamp(0.0, 1.0);
        final opacity = (animValue * 2).clamp(0.3, 1.0);
        return Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: Colors.grey[600]!.withValues(alpha: opacity),
            shape: BoxShape.circle,
          ),
        );
      },
      onEnd: () {
        if (mounted) setState(() {});
      },
    );
  }
}
