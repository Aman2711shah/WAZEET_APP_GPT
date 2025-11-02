import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme.dart';
import '../../services/ai_business_expert_service.dart';
import 'freezone_browser_page.dart';

/// Chat message model
class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;

  ChatMessage({required this.text, required this.isUser, DateTime? timestamp})
    : timestamp = timestamp ?? DateTime.now();
}

/// Conversation state provider
final conversationProvider =
    StateNotifierProvider<ConversationNotifier, List<ChatMessage>>((ref) {
      return ConversationNotifier();
    });

class ConversationNotifier extends StateNotifier<List<ChatMessage>> {
  ConversationNotifier() : super([]) {
    _initializeConversation();
  }

  void _initializeConversation() {
    final greeting = AIBusinessExpertService.getInitialGreeting();
    state = [ChatMessage(text: greeting, isUser: false)];
  }

  void addMessage(ChatMessage message) {
    state = [...state, message];
  }

  void reset() {
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
  Map<String, dynamic>? _extractedRequirements;

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

      // Check if recommendations are provided
      final requirements = AIBusinessExpertService.extractBusinessRequirements(
        response,
      );
      if (requirements != null) {
        setState(() => _extractedRequirements = requirements);
      }

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

  void _navigateToFreezoneBrowser() {
    if (_extractedRequirements == null) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FreezoneBrowserPage(
          prefilledRecommendations:
              _extractedRequirements!['recommendations'] as List<String>?,
          minVisas: _extractedRequirements!['visaCount'] as int?,
          searchQuery: _extractedRequirements!['activity'] as String?,
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
              setState(() => _extractedRequirements = null);
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

          // Recommendation action button
          if (_extractedRequirements != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                border: Border(
                  top: BorderSide(color: AppColors.primary.withValues(alpha: 0.3)),
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.lightbulb, color: Colors.orange, size: 20),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'Ready to explore these options?',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: _navigateToFreezoneBrowser,
                    icon: const Icon(Icons.arrow_forward, size: 18),
                    label: const Text('View Freezones'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
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
                color: AppColors.primary.withValues(alpha: 0.1),
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
                    color: Colors.black.withValues(alpha: 0.05),
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
              color: AppColors.primary.withValues(alpha: 0.1),
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
