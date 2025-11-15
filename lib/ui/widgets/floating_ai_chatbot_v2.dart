import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../services/ai_business_expert_service_v2.dart';
import '../pages/ai_business_expert_page_v2.dart';

/// Floating AI Chatbot Widget with Streaming Support
///
/// This is an enhanced version that uses the new streaming service
/// Drop this into your main navigation to replace the old floating chatbot
class FloatingAIChatbotV2 extends ConsumerStatefulWidget {
  const FloatingAIChatbotV2({super.key});

  @override
  ConsumerState<FloatingAIChatbotV2> createState() =>
      _FloatingAIChatbotV2State();
}

class _FloatingAIChatbotV2State extends ConsumerState<FloatingAIChatbotV2>
    with SingleTickerProviderStateMixin {
  bool _isExpanded = false;
  final ScrollController _scrollController = ScrollController();
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

  void _openFullPage() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AIBusinessExpertPage()),
    );
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

  @override
  Widget build(BuildContext context) {
    double safeDockBottom() {
      final padding = MediaQuery.of(context).padding.bottom;
      // Position button just above the bottom nav
      return 8 + kBottomNavigationBarHeight + padding;
    }

    return Stack(
      children: [
        // Expanded chat window - simplified, just shows "Open full chat" button
        if (_isExpanded)
          Positioned(
            right: 20,
            bottom: safeDockBottom() + 70,
            child: ScaleTransition(
              scale: _scaleAnimation,
              alignment: Alignment.bottomRight,
              child: _buildMiniChatWindow(),
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
          onTap: _isExpanded ? _minimizeChat : _toggleChat,
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
                            BoxShadow(
                              color: Colors.deepOrange.withValues(alpha: 0.55),
                              blurRadius: 16,
                              offset: const Offset(0, 8),
                            ),
                            const BoxShadow(
                              color: Colors.white24,
                              blurRadius: 2,
                              offset: Offset(-2, -2),
                            ),
                          ],
                        ),
                        foregroundDecoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(30),
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
                            Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.2),
                                  width: 1.2,
                                ),
                              ),
                            ),
                            Icon(
                              _isExpanded ? Icons.close : Icons.psychology,
                              color: Colors.white,
                              size: 28,
                            ),
                            // Pulse animation for recommendations
                            ValueListenableBuilder(
                              valueListenable:
                                  AIBusinessExpertServiceV2.recommendations,
                              builder: (context, recs, _) {
                                if (recs.isEmpty || _isExpanded) {
                                  return const SizedBox.shrink();
                                }
                                return Positioned(
                                  right: 7,
                                  top: 7,
                                  child: Container(
                                    width: 10,
                                    height: 10,
                                    decoration: const BoxDecoration(
                                      color: Colors.greenAccent,
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.greenAccent,
                                          blurRadius: 8,
                                          spreadRadius: 2,
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
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

  Widget _buildMiniChatWindow() {
    return Container(
      width: 320,
      height: 400,
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
                  icon: const Icon(Icons.minimize, color: Colors.white),
                  onPressed: _minimizeChat,
                  tooltip: 'Minimize',
                ),
              ],
            ),
          ),

          // Content - just prompt to open full chat
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.chat_bubble_outline,
                    size: 64,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'AI Business Expert',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24),
                    child: Text(
                      'Get personalized freezone recommendations',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: _openFullPage,
                    icon: const Icon(Icons.chat),
                    label: const Text('Start Chat'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepOrange,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 16,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ValueListenableBuilder(
                    valueListenable: AIBusinessExpertServiceV2.recommendations,
                    builder: (context, recs, _) {
                      if (recs.isEmpty) return const SizedBox.shrink();
                      return Chip(
                        avatar: const Icon(Icons.check_circle, size: 16),
                        label: Text('${recs.length} recommendations'),
                        backgroundColor: Colors.green[100],
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Global provider exposing the AI chat expanded state so other widgets can react
final aiChatExpandedProvider = StateProvider<bool>((_) => false);
