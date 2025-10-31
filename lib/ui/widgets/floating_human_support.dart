import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import 'floating_ai_chatbot.dart';

/// Floating human support button shown bottom-left on all screens.
class FloatingHumanSupport extends ConsumerStatefulWidget {
  const FloatingHumanSupport({super.key});

  @override
  ConsumerState<FloatingHumanSupport> createState() =>
      _FloatingHumanSupportState();
}

class _FloatingHumanSupportState extends ConsumerState<FloatingHumanSupport>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _offsetAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _offsetAnim = Tween<Offset>(
      begin: const Offset(-0.2, 0.2),
      end: Offset.zero,
    ).chain(CurveTween(curve: Curves.easeOutBack)).animate(_controller);
    // Play entry animation
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final aiExpanded = ref.watch(aiChatExpandedProvider);

    return Positioned(
      left: 20,
      bottom: 20,
      child: SlideTransition(
        position: _offsetAnim,
        child: _SupportButton(minimized: aiExpanded),
      ),
    );
  }
}

class _SupportButton extends StatelessWidget {
  final bool minimized; // when true, show compact circular icon
  const _SupportButton({required this.minimized});

  @override
  Widget build(BuildContext context) {
    final gradient = const LinearGradient(
      colors: [Color(0xFF7A5AF8), Color(0xFF9B7BFF)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );

    final button = Material(
      elevation: 8,
      borderRadius: BorderRadius.circular(minimized ? 28 : 28),
      child: InkWell(
        onTap: () => _openSupportSheet(context),
        borderRadius: BorderRadius.circular(minimized ? 28 : 28),
        child: Container(
          height: 56,
          constraints: BoxConstraints(minWidth: minimized ? 56 : 200),
          padding: EdgeInsets.symmetric(horizontal: minimized ? 0 : 16),
          decoration: BoxDecoration(
            gradient: gradient,
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF7A5AF8).withOpacity(0.35),
                blurRadius: 14,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: minimized ? MainAxisSize.min : MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.headset_mic, color: Colors.white, size: 22),
              if (!minimized) ...[
                const SizedBox(width: 8),
                const Text(
                  'Talk to an Expert',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );

    return Semantics(
      label: minimized
          ? 'Chat with an Expert Support'
          : 'Call an Expert Support',
      button: true,
      child: Tooltip(message: 'Talk to an Expert', child: button),
    );
  }

  void _openSupportSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: const [
                    Icon(Icons.support_agent, color: Color(0xFF7A5AF8)),
                    SizedBox(width: 8),
                    Text(
                      'Expert Support',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ListTile(
                  leading: const Icon(Icons.call, color: Colors.green),
                  title: const Text('Call an Expert'),
                  subtitle: const Text('+971 55 998 6386'),
                  onTap: () async {
                    final uri = Uri(scheme: 'tel', path: '+971559986386');
                    await launchUrl(uri, mode: LaunchMode.externalApplication);
                  },
                ),
                ListTile(
                  leading: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      const Icon(Icons.chat_bubble, color: Color(0xFF7A5AF8)),
                      Positioned(
                        right: -2,
                        top: -2,
                        child: Container(
                          width: 10,
                          height: 10,
                          decoration: const BoxDecoration(
                            color: Colors.green,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    ],
                  ),
                  title: const Text('Chat with an Expert'),
                  subtitle: const Text('Response Time: Within 15 minutes'),
                  onTap: () async {
                    final subject = Uri.encodeComponent(
                      'Support Request from Wazeet App',
                    );
                    final body = Uri.encodeComponent(
                      'Hello Wazeet Team, I need assistance with…',
                    );
                    final uri = Uri(
                      scheme: 'mailto',
                      path: 'info@wazeet.com',
                      query: 'subject=$subject&body=$body',
                    );
                    await launchUrl(uri, mode: LaunchMode.externalApplication);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.chat, color: Colors.green),
                  title: const Text('WhatsApp'),
                  subtitle: const Text('+971 55 998 6386'),
                  onTap: () async {
                    final url = Uri.parse('https://wa.me/971559986386');
                    if (!await launchUrl(
                      url,
                      mode: LaunchMode.externalApplication,
                    )) {
                      // Fallback to dialer
                      final tel = Uri(scheme: 'tel', path: '+971559986386');
                      await launchUrl(
                        tel,
                        mode: LaunchMode.externalApplication,
                      );
                    }
                  },
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        );
      },
    );
  }
}
