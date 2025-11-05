import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../services/ai_business_expert_service.dart';
import '../../config/app_config.dart';
import '../pages/freezone_browser_page.dart';

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

/// Floating AI Chatbot Widget
class FloatingAIChatbot extends ConsumerStatefulWidget {
  const FloatingAIChatbot({super.key});

  @override
  ConsumerState<FloatingAIChatbot> createState() => _FloatingAIChatbotState();
}

class _FloatingAIChatbotState extends ConsumerState<FloatingAIChatbot>
    with SingleTickerProviderStateMixin {
  bool _isExpanded = false;
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isTyping = false;
  Map<String, dynamic>? _extractedRequirements;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  // 3D interactions
  bool _hovering = false;
  bool _pressed = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _scaleAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutBack,
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _toggleChat() {
    setState(() {
      _isExpanded = !_isExpanded;
    });
    // Broadcast expanded state for other overlays (e.g., human support button)
    ref.read(aiChatExpandedProvider.notifier).state = _isExpanded;
    if (_isExpanded) {
      _animationController.forward();
      _scrollToBottom();
    } else {
      _animationController.reverse();
    }
  }

  void _minimizeChat() {
    setState(() {
      _isExpanded = false;
    });
    ref.read(aiChatExpandedProvider.notifier).state = false;
    _animationController.reverse();
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

    final userMessage = ChatMessage(text: text, isUser: true);
    ref.read(conversationProvider.notifier).addMessage(userMessage);
    _messageController.clear();
    _scrollToBottom();

    setState(() => _isTyping = true);

    try {
      final history = ref
          .read(conversationProvider.notifier)
          .getConversationHistory();
      final response = await AIBusinessExpertService.sendMessage(
        userMessage: text,
        conversationHistory: history,
      );

      final aiMessage = ChatMessage(text: response, isUser: false);
      ref.read(conversationProvider.notifier).addMessage(aiMessage);

      final requirements = AIBusinessExpertService.extractBusinessRequirements(
        response,
      );
      if (requirements != null) {
        setState(() => _extractedRequirements = requirements);
      }

      _scrollToBottom();
    } catch (e) {
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
    _minimizeChat();
  }

  @override
  Widget build(BuildContext context) {
    double safeDockBottom() {
      final padding = MediaQuery.of(context).padding.bottom;
      // Keep the button clear of the bottom nav and device insets
      return 20 + kBottomNavigationBarHeight + padding;
    }

    return Stack(
      children: [
        // Expanded chat window
        if (_isExpanded)
          Positioned(
            right: 20,
            bottom: safeDockBottom() + 70,
            child: ScaleTransition(
              scale: _scaleAnimation,
              alignment: Alignment.bottomRight,
              child: _buildChatWindow(),
            ),
          ),

        // Floating action button
        Positioned(
          right: 20,
          bottom: safeDockBottom(),
          child: _buildFloatingButton(),
        ),
      ],
    );
  }

  Widget _buildFloatingButton() {
    // 3D glossy floating button with hover tilt, press sink, and layered shadows
    return Tooltip(
      message: _isExpanded ? 'Close' : 'AI Business Expert',
      preferBelow: false,
      child: MouseRegion(
        onEnter: (_) => setState(() => _hovering = true),
        onExit: (_) => setState(() => _hovering = false),
        child: GestureDetector(
          onTapDown: (_) => setState(() => _pressed = true),
          onTapCancel: () => setState(() => _pressed = false),
          onTapUp: (_) => setState(() => _pressed = false),
          onTap: _toggleChat,
          child: SizedBox(
            width: 76,
            height: 76,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Soft ground shadow
                Positioned(
                  bottom: 8,
                  child: Container(
                    width: 46,
                    height: 16,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.25),
                          blurRadius: 20,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                  ),
                ),

                // Main button with tilt/scale animation
                AnimatedScale(
                  duration: const Duration(milliseconds: 140),
                  curve: Curves.easeOut,
                  scale: _pressed
                      ? 0.96
                      : _hovering
                      ? 1.06
                      : 1.0,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 160),
                    curve: Curves.easeOut,
                    transformAlignment: Alignment.center,
                    transform: Matrix4.identity()
                      ..setEntry(3, 2, 0.001)
                      ..rotateX(_hovering ? -0.06 : 0.0)
                      ..rotateY(_hovering ? 0.06 : 0.0),
                    child: Material(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(30),
                      elevation: _pressed ? 6 : (_hovering ? 14 : 10),
                      shadowColor: Colors.black.withValues(alpha: 0.35),
                      child: Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(30),
                          gradient: LinearGradient(
                            colors: [Colors.orange[500]!, Colors.deepOrange],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          boxShadow: [
                            // Deep colored ambient
                            BoxShadow(
                              color: Colors.deepOrange.withValues(alpha: 0.55),
                              blurRadius: 16,
                              offset: const Offset(0, 8),
                            ),
                            // Subtle rim light
                            const BoxShadow(
                              color: Colors.white24,
                              blurRadius: 2,
                              offset: Offset(-2, -2),
                            ),
                          ],
                        ),
                        foregroundDecoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(30),
                          // Specular highlight gloss
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Colors.white.withValues(alpha: 0.28),
                              Colors.white.withValues(alpha: 0.04),
                              Colors.white.withValues(alpha: 0.0),
                            ],
                            stops: const [0.0, 0.35, 1.0],
                          ),
                        ),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            // Outer subtle ring
                            Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.2),
                                  width: 1.2,
                                ),
                              ),
                            ),
                            // Icon
                            Icon(
                              _isExpanded ? Icons.close : Icons.psychology,
                              color: Colors.white,
                              size: 28,
                            ),
                            // Tiny online/typing indicator
                            if (!_isExpanded && _isTyping)
                              Positioned(
                                right: 7,
                                top: 7,
                                child: Container(
                                  width: 10,
                                  height: 10,
                                  decoration: const BoxDecoration(
                                    color: Colors.greenAccent,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ),
                            // Gloss highlight streak
                            Positioned(
                              left: 10,
                              top: 12,
                              child: Transform.rotate(
                                angle: -0.6,
                                child: Container(
                                  width: 38,
                                  height: 14,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(20),
                                    gradient: LinearGradient(
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                      colors: [
                                        Colors.white.withValues(alpha: 0.55),
                                        Colors.white.withValues(alpha: 0.0),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildChatWindow() {
    final messages = ref.watch(conversationProvider);
    final screenSize = MediaQuery.of(context).size;
    
    // Responsive sizing: max 380 width, 550 height, but adapt to small screens
    final chatWidth = (screenSize.width * 0.9).clamp(280.0, 380.0);
    final chatHeight = (screenSize.height * 0.7).clamp(400.0, 550.0);

    return Container(
      width: chatWidth,
      height: chatHeight,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.deepOrange, Colors.orange[700]!],
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.psychology,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'AI Business Expert',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Online',
                        style: TextStyle(color: Colors.white70, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.refresh, color: Colors.white),
                  onPressed: () {
                    ref.read(conversationProvider.notifier).reset();
                    setState(() => _extractedRequirements = null);
                  },
                  tooltip: 'Start Over',
                ),
                IconButton(
                  icon: const Icon(Icons.minimize, color: Colors.white),
                  onPressed: _minimizeChat,
                  tooltip: 'Minimize',
                ),
              ],
            ),
          ),

          // Warning banner if API key is missing
          if (!AppConfig.hasOpenAiKey)
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.orange.shade100,
                border: Border(bottom: BorderSide(color: Colors.orange.shade300)),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.orange.shade800, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Limited mode: AI features unavailable. Configure OpenAI API key for full functionality.',
                      style: TextStyle(
                        color: Colors.orange.shade900,
                        fontSize: 11,
                      ),
                    ),
                  ),
                ],
              ),
            ),

          // Messages
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

          // Recommendation action
          if (_extractedRequirements != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.green[50],
                border: Border(top: BorderSide(color: Colors.green[200]!)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.lightbulb, color: Colors.orange, size: 18),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'View recommendations?',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: _navigateToFreezoneBrowser,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                    ),
                    child: const Text('View', style: TextStyle(fontSize: 13)),
                  ),
                ],
              ),
            ),

          // Input area
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Type your message...',
                      hintStyle: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[500],
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                    ),
                    onSubmitted: (_) => _sendMessage(),
                    textInputAction: TextInputAction.send,
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.deepOrange, Colors.orange[700]!],
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.send, color: Colors.white, size: 20),
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
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: message.isUser
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!message.isUser) ...[
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.deepOrange.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.psychology,
                color: Colors.deepOrange,
                size: 16,
              ),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: message.isUser ? Colors.deepOrange : Colors.grey[200],
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
                  fontSize: 13,
                  height: 1.4,
                ),
              ),
            ),
          ),
          if (message.isUser) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.all(6),
              decoration: const BoxDecoration(
                color: Colors.deepOrange,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.person, color: Colors.white, size: 16),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.deepOrange.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.psychology,
              color: Colors.deepOrange,
              size: 16,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
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

/// Global provider exposing the AI chat expanded state so other widgets can react
final aiChatExpandedProvider = StateProvider<bool>((_) => false);
