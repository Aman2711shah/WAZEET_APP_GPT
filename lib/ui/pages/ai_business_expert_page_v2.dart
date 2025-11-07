import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../theme.dart';
import '../../services/ai_business_expert_service_v2.dart';
import '../../models/freezone_rec.dart';
import 'freezone_browser_page.dart';

/// Chat message model with tool call tracking
class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;
  final String? toolName;
  final Map<String, dynamic>? toolResult;

  ChatMessage({
    required this.text,
    required this.isUser,
    DateTime? timestamp,
    this.toolName,
    this.toolResult,
  }) : timestamp = timestamp ?? DateTime.now();

  Map<String, dynamic> toFirestore() {
    return {
      'text': text,
      'isUser': isUser,
      'timestamp': Timestamp.fromDate(timestamp),
      if (toolName != null) 'toolName': toolName,
      if (toolResult != null) 'toolResult': toolResult,
    };
  }

  factory ChatMessage.fromFirestore(Map<String, dynamic> data) {
    return ChatMessage(
      text: data['text'] as String,
      isUser: data['isUser'] as bool,
      timestamp: (data['timestamp'] as Timestamp).toDate(),
      toolName: data['toolName'] as String?,
      toolResult: data['toolResult'] as Map<String, dynamic>?,
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
          .collection('conversations')
          .where('userId', isEqualTo: userId)
          .orderBy('updatedAt', descending: true)
          .limit(1)
          .get();

      if (conversationsSnap.docs.isNotEmpty) {
        final doc = conversationsSnap.docs.first;
        _conversationId = doc.id;

        // Load messages
        final messagesSnap = await _firestore
            .collection('conversations')
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
    final greeting = AIBusinessExpertServiceV2.getInitialGreeting();
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
        final conversationRef = _firestore.collection('conversations').doc();
        _conversationId = conversationRef.id;

        await conversationRef.set({
          'userId': userId,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });
      } else {
        // Update existing conversation
        await _firestore
            .collection('conversations')
            .doc(_conversationId)
            .update({
              'updatedAt': FieldValue.serverTimestamp(),
              if (message.toolName != null) 'lastTool': message.toolName,
            });
      }

      // Add message to subcollection
      await _firestore
          .collection('conversations')
          .doc(_conversationId)
          .collection('messages')
          .add(message.toFirestore());
    } catch (e) {
      debugPrint('Error saving message: $e');
    }
  }

  Future<void> reset() async {
    final userId = _auth.currentUser?.uid;
    if (userId != null && _conversationId != null) {
      try {
        // Archive current conversation
        await _firestore
            .collection('conversations')
            .doc(_conversationId)
            .update({
              'archived': true,
              'archivedAt': FieldValue.serverTimestamp(),
            });
      } catch (e) {
        debugPrint('Error archiving conversation: $e');
      }
    }

    _conversationId = null;
    AIBusinessExpertServiceV2.clearRecommendations();
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

/// AI Business Expert Chat Page with Streaming
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
  String _streamingContent = '';

  // Quick reply options
  final List<String> _quickReplies = [
    'E-commerce',
    'General Trading',
    'Consultancy',
    'IT Services',
    'Restaurant',
    'Freelancer',
  ];

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

  Future<void> _sendMessage([String? quickReply]) async {
    final text = quickReply ?? _messageController.text.trim();
    if (text.isEmpty || _isTyping) return;

    final userMessage = ChatMessage(text: text, isUser: true);
    ref.read(conversationProvider.notifier).addMessage(userMessage);
    _messageController.clear();
    _scrollToBottom();

    setState(() {
      _isTyping = true;
      _streamingContent = '';
    });

    try {
      final history = ref
          .read(conversationProvider.notifier)
          .getConversationHistory();

      // Listen to stream
      await for (final event in AIBusinessExpertServiceV2.sendMessageStream(
        userMessage: text,
        conversationHistory: history,
      )) {
        if (event.isContent) {
          // Append streaming content
          setState(() {
            _streamingContent += event.content ?? '';
          });
          _scrollToBottom();
        } else if (event.isToolCall) {
          // Tool call completed
          debugPrint('🔧 Tool called: ${event.toolName}');
        } else if (event.isDone) {
          // Stream complete
          final aiMessage = ChatMessage(
            text: event.fullContent ?? _streamingContent,
            isUser: false,
          );
          ref.read(conversationProvider.notifier).addMessage(aiMessage);
          setState(() {
            _streamingContent = '';
          });
          _scrollToBottom();
          break;
        } else if (event.isError) {
          // Error occurred
          final errorMessage = ChatMessage(
            text:
                event.error ??
                "I'm having trouble connecting. Please try again.",
            isUser: false,
          );
          ref.read(conversationProvider.notifier).addMessage(errorMessage);
          setState(() {
            _streamingContent = '';
          });
          break;
        }
      }
    } catch (e) {
      debugPrint('Error sending message: $e');
      final errorMessage = ChatMessage(
        text:
            "I apologize, I'm having trouble connecting right now. Please try again.",
        isUser: false,
      );
      ref.read(conversationProvider.notifier).addMessage(errorMessage);
    } finally {
      setState(() {
        _isTyping = false;
        _streamingContent = '';
      });
    }
  }

  void _viewRecommendations() {
    final recs = AIBusinessExpertServiceV2.recommendations.value;
    if (recs.isEmpty) return;

    // Navigate to freezone browser with recommendations
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => FreezoneBrowserPage(
          prefilledRecommendations: recs.map((r) => r.name).toList(),
        ),
      ),
    );
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
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('AI Business Expert', style: TextStyle(fontSize: 16)),
                Text(
                  'Online',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.normal),
                ),
              ],
            ),
          ],
        ),
        backgroundColor: AppColors.primary,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Start Over',
            onPressed: () {
              showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Start Over?'),
                  content: const Text(
                    'This will clear the current conversation.',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () {
                        ref.read(conversationProvider.notifier).reset();
                        Navigator.pop(ctx);
                      },
                      child: const Text('Start Over'),
                    ),
                  ],
                ),
              );
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
                  return _buildStreamingMessage();
                }
                return _buildMessageBubble(messages[index]);
              },
            ),
          ),

          // Recommendations CTA
          ValueListenableBuilder<List<FreezoneRec>>(
            valueListenable: AIBusinessExpertServiceV2.recommendations,
            builder: (context, recs, _) {
              if (recs.isEmpty) return const SizedBox.shrink();

              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  border: Border(
                    top: BorderSide(
                      color: AppColors.primary.withValues(alpha: 0.3),
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle, color: AppColors.primary),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        '${recs.length} recommendations ready',
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: _viewRecommendations,
                      icon: const Icon(Icons.arrow_forward, size: 18),
                      label: const Text('View'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),

          // Quick reply chips
          if (!_isTyping)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _quickReplies.map((reply) {
                  return ActionChip(
                    label: Text(reply),
                    onPressed: () => _sendMessage(reply),
                    backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                    labelStyle: TextStyle(color: AppColors.primary),
                  );
                }).toList(),
              ),
            ),

          // Input area
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
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
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.grey[100],
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                    ),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.deepOrange, Colors.orange[700]!],
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
                color: AppColors.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.psychology,
                color: AppColors.primary,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: message.isUser ? AppColors.primary : Colors.grey[200],
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: Radius.circular(message.isUser ? 16 : 4),
                  bottomRight: Radius.circular(message.isUser ? 4 : 16),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 3,
                    offset: const Offset(0, 1),
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
              decoration: const BoxDecoration(
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

  Widget _buildStreamingMessage() {
    if (_streamingContent.isEmpty) {
      return _buildTypingIndicator();
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.psychology,
              color: AppColors.primary,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                  bottomLeft: Radius.circular(4),
                  bottomRight: Radius.circular(16),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 3,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Flexible(
                    child: Text(
                      _streamingContent,
                      style: const TextStyle(
                        color: Colors.black87,
                        fontSize: 15,
                        height: 1.4,
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  SizedBox(
                    width: 12,
                    height: 12,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
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
              color: AppColors.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.psychology,
              color: AppColors.primary,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(16),
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
          width: 6,
          height: 6,
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
