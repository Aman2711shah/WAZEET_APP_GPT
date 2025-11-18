import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../services/remote_ai_client.dart';
import '../theme.dart';

/// Chat message model
class ChatMessage {
  final String content;
  final bool isUser;
  final DateTime timestamp;
  final bool isStreaming;

  ChatMessage({
    required this.content,
    required this.isUser,
    DateTime? timestamp,
    this.isStreaming = false,
  }) : timestamp = timestamp ?? DateTime.now();
}

/// AI Business Chat page with ChatGPT integration
class AIBusinessChatPage extends ConsumerStatefulWidget {
  const AIBusinessChatPage({super.key});

  @override
  ConsumerState<AIBusinessChatPage> createState() => _AIBusinessChatPageState();
}

class _AIBusinessChatPageState extends ConsumerState<AIBusinessChatPage> {
  final _aiClient = RemoteAIClient();
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();
  final List<ChatMessage> _messages = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Add welcome message
    _messages.add(
      ChatMessage(
        content:
            "👋 Hello! I'm your AI Business Expert specialized in UAE business regulations, company formation, and free zones. How can I help you today?",
        isUser: false,
      ),
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty || _isLoading) return;

    // Add user message
    setState(() {
      _messages.add(ChatMessage(content: text, isUser: true));
      _isLoading = true;
    });

    _messageController.clear();
    _scrollToBottom();

    // Get conversation history
    final history = _messages
        .where((m) => !m.isStreaming)
        .map(
          (m) => {
            'role': m.isUser ? 'user' : 'assistant',
            'content': m.content,
          },
        )
        .toList();

    try {
      // Build full message list including the new user message
      final messages = [
        ...history,
        {'role': 'user', 'content': text},
      ];

      // Add empty AI message for streaming
      setState(() {
        _messages.add(
          ChatMessage(content: '', isUser: false, isStreaming: true),
        );
      });

      // Stream the response from backend (SSE if supported, else one chunk)
      await for (final chunk in _aiClient.sendChatStream(
        messages.cast<Map<String, dynamic>>(),
      )) {
        setState(() {
          _messages.last = ChatMessage(
            content: _messages.last.content + chunk,
            isUser: false,
            isStreaming: true,
          );
        });
        _scrollToBottom();
      }

      // Mark streaming as complete
      setState(() {
        _messages.last = ChatMessage(
          content: _messages.last.content,
          isUser: false,
          isStreaming: false,
        );
      });
    } catch (e) {
      setState(() {
        // Remove the streaming message
        if (_messages.last.isStreaming) {
          _messages.removeLast();
        }
        _messages.add(
          ChatMessage(
            content:
                'I\'m having trouble reaching the AI service right now. Please try again in a moment.',
            isUser: false,
          ),
        );
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.purple,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.smart_toy, color: Colors.white, size: 24),
            ),
            const SizedBox(width: 12),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'AI Business Expert',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  'Powered by ChatGPT',
                  style: TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: () {
              setState(() {
                _messages.clear();
                _messages.add(
                  ChatMessage(
                    content:
                        "👋 Hello! I'm your AI Business Expert specialized in UAE business regulations, company formation, and free zones. How can I help you today?",
                    isUser: false,
                  ),
                );
              });
            },
            tooltip: 'Clear conversation',
          ),
        ],
      ),
      body: Column(
        children: [
          // Suggested questions
          if (_messages.length == 1)
            Container(
              padding: const EdgeInsets.all(16),
              color: Colors.white,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Quick Questions',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade800,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _buildQuickQuestion(
                        'How do I start a business in Dubai?',
                      ),
                      _buildQuickQuestion('What is a Golden Visa?'),
                      _buildQuickQuestion('Free zone vs mainland company?'),
                      _buildQuickQuestion(
                        'How much does a trade license cost?',
                      ),
                    ],
                  ),
                ],
              ),
            ),

          // Messages list
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                return _buildMessageBubble(message);
              },
            ),
          ),

          // Input area with keyboard-aware padding
          Container(
            padding: EdgeInsets.only(
              left: 16,
              right: 16,
              top: 16,
              bottom: MediaQuery.of(context).viewInsets.bottom + 16,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      maxLines: null,
                      textCapitalization: TextCapitalization.sentences,
                      style: const TextStyle(
                        fontSize: 16,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w500,
                        height: 1.4,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Ask anything about UAE business setup…',
                        hintStyle: TextStyle(
                          color: Colors.grey.shade400,
                          fontSize: 15,
                          fontFamily: 'Inter',
                        ),
                        filled: true,
                        fillColor: Colors.grey.shade100,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(28),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 18, // Increased height
                        ),
                      ),
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF9333EA), Color(0xFF7C3AED)],
                      ),
                      borderRadius: BorderRadius.circular(28),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.purple.withValues(alpha: 0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: IconButton(
                      onPressed: _isLoading ? null : _sendMessage,
                      icon: _isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Icon(Icons.send, color: Colors.white),
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

  Widget _buildQuickQuestion(String question) {
    return InkWell(
      onTap: () {
        _messageController.text = question;
        _sendMessage();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.purple.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.purple.withValues(alpha: 0.3)),
        ),
        child: Text(
          question,
          style: TextStyle(
            color: AppColors.purple,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  String formatAssistantMessage(String raw) {
    // Remove markdown headings
    final headingRegex = RegExp(r'^#+\s*(.*)', multiLine: true);
    String formatted = raw.replaceAllMapped(headingRegex, (m) => m[1] ?? '');

    // Convert numbered headings to bold subtitles
    final numberedStepRegex = RegExp(r'^(\d+\.)\s*(.*)', multiLine: true);
    formatted = formatted.replaceAllMapped(
      numberedStepRegex,
      (m) => '\u2022 ${m[2]!.trim()}',
    ); // Use bullet for step, will bold in widget

    // Convert markdown lists to bullets
    final bulletRegex = RegExp(r'^[-*]\s*(.*)', multiLine: true);
    formatted = formatted.replaceAllMapped(
      bulletRegex,
      (m) => '\u2022 ${m[1]!.trim()}',
    );

    // Remove extra markdown symbols
    formatted = formatted.replaceAll(RegExp(r'[`>_\[\]]'), '');

    // Remove double blank lines
    formatted = formatted.replaceAll(RegExp(r'\n{3,}'), '\n\n');

    return formatted.trim();
  }

  Widget _buildMessageBubble(ChatMessage message) {
    final isAssistant = !message.isUser;
    final formattedContent = isAssistant
        ? formatAssistantMessage(message.content)
        : message.content;
    return Align(
      alignment: message.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.only(
          bottom: isAssistant ? 16 : 20,
        ), // More vertical spacing for user
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        child: Column(
          crossAxisAlignment: message.isUser
              ? CrossAxisAlignment.end
              : CrossAxisAlignment.start,
          children: [
            Container(
              padding: message.isUser
                  ? const EdgeInsets.symmetric(horizontal: 10, vertical: 14)
                  : const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
              decoration: BoxDecoration(
                gradient: isAssistant
                    ? const LinearGradient(
                        colors: [Color(0xFF6D5DF6), Color(0xFF9B7BF7)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                    : const LinearGradient(
                        colors: [Color(0xFF9333EA), Color(0xFF7C3AED)],
                      ),
                color: isAssistant ? null : Colors.white,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: isAssistant
                        ? Colors.deepPurple.withValues(alpha: 0.10)
                        : Colors.black.withValues(alpha: 0.08),
                    blurRadius: 12,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: message.isStreaming && message.content.isEmpty
                  ? const SizedBox(
                      width: 40,
                      height: 20,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            width: 8,
                            height: 8,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                          SizedBox(width: 8),
                          Text('•••', style: TextStyle(fontSize: 16)),
                        ],
                      ),
                    )
                  : isAssistant
                  ? _renderFormattedMessage(formattedContent, isAssistant)
                  : Text(
                      formattedContent,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        height: 1.5,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w500,
                      ),
                    ),
            ),
            if (isAssistant && !message.isStreaming)
              Padding(
                padding: const EdgeInsets.only(left: 4, top: 4),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.smart_toy,
                      size: 12,
                      color: Colors.grey.shade400,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'AI',
                      style: TextStyle(
                        color: Colors.grey.shade400,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _renderFormattedMessage(String content, bool isAssistant) {
    final lines = content.split('\n');
    return Column(
      crossAxisAlignment: isAssistant
          ? CrossAxisAlignment.start
          : CrossAxisAlignment.end,
      children: lines.map((line) {
        if (line.startsWith('• ')) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('• ', style: TextStyle(fontWeight: FontWeight.bold)),
                Expanded(
                  child: Text(
                    line.substring(2),
                    softWrap: true,
                    overflow: TextOverflow.visible,
                    style: TextStyle(
                      fontSize: 15,
                      height: 1.5,
                      fontWeight: FontWeight.w500,
                      color: isAssistant ? Colors.white : Colors.black87,
                      fontFamily: 'Inter',
                    ),
                  ),
                ),
              ],
            ),
          );
        } else if (RegExp(r'^(\d+\.)').hasMatch(line)) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Text(
              line,
              softWrap: true,
              overflow: TextOverflow.visible,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                height: 1.5,
                color: isAssistant ? Colors.white : Colors.black87,
                fontFamily: 'Inter',
              ),
            ),
          );
        } else {
          return Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Text(
              line,
              softWrap: true,
              overflow: TextOverflow.visible,
              style: TextStyle(
                fontSize: 15,
                height: 1.5,
                color: isAssistant ? Colors.white : Colors.black87,
                fontFamily: 'Inter',
              ),
            ),
          );
        }
      }).toList(),
    );
  }
}
