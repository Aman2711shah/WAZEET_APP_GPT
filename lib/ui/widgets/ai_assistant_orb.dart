import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:simple_icons/simple_icons.dart';
import '../pages/ai_business_expert_page_v2.dart';
import '../pages/help_center_page.dart';

/// Floating AI Assistant Orb
/// - Purple gradient (#7B5CF9 -> #A97FFF)
/// - Soft glow, tooltip, idle pulse
/// - On tap: bottom sheet with support actions
class AiAssistantOrb extends StatefulWidget {
  const AiAssistantOrb({super.key});

  @override
  State<AiAssistantOrb> createState() => _AiAssistantOrbState();
}

class _AiAssistantOrbState extends State<AiAssistantOrb>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
      lowerBound: 0.0,
      upperBound: 1.0,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  double _dockBottom(BuildContext context) {
    final pad = MediaQuery.of(context).padding.bottom;
    return 8 + kBottomNavigationBarHeight + pad;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Positioned(
      right: 20,
      bottom: _dockBottom(context),
      child: Tooltip(
        message: 'Ask WAZEET AI',
        child: GestureDetector(
          onTap: () => _showOptions(context),
          child: AnimatedBuilder(
            animation: _pulse,
            builder: (context, child) {
              final scale = 1.0 + (_pulse.value * 0.04);
              return Transform.scale(
                scale: scale,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Glow halo
                    Container(
                      width: 74,
                      height: 74,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: const Color(
                              0xFF7B5CF9,
                            ).withValues(alpha: isDark ? 0.65 : 0.35),
                            blurRadius: isDark ? 26 : 18,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                    ),
                    // Orb
                    ClipRRect(
                      borderRadius: BorderRadius.circular(34),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Backdrop blur for dark mode pop
                          if (isDark)
                            BackdropFilter(
                              filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                              child: const SizedBox(width: 68, height: 68),
                            ),
                          // Gradient orb
                          Container(
                            width: 68,
                            height: 68,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: const LinearGradient(
                                colors: [Color(0xFF7B5CF9), Color(0xFFA97FFF)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(
                                    0xFF7B5CF9,
                                  ).withValues(alpha: isDark ? 0.7 : 0.45),
                                  blurRadius: 20,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                          ),
                          // Gloss highlight
                          Positioned(
                            left: 12,
                            top: 10,
                            child: Container(
                              width: 36,
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
                          // Brain/AI icon
                          const Icon(
                            Icons.support_agent_rounded,
                            color: Colors.white,
                            size: 30,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  void _showOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        Widget action({
          required IconData icon,
          required Color color,
          required String title,
          required VoidCallback onTap,
        }) {
          return ListTile(
            leading: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [color.withValues(alpha: 0.85), color],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: Colors.white),
            ),
            title: Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            onTap: () {
              Navigator.pop(context);
              onTap();
            },
          );
        }

        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                action(
                  icon: Icons.chat_bubble_outline,
                  color: const Color(0xFF7B5CF9),
                  title: 'Chat with WAZEET AI',
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const AIBusinessExpertPage(),
                      ),
                    );
                  },
                ),
                action(
                  icon: Icons.phone,
                  color: Colors.green,
                  title: 'Call Support',
                  onTap: () => launchUrl(Uri.parse('tel:+971559986386')),
                ),
                action(
                  icon: SimpleIcons.whatsapp,
                  color: const Color(0xFF25D366),
                  title: 'WhatsApp Support',
                  onTap: () =>
                      launchUrl(Uri.parse('https://wa.me/971559986386')),
                ),
                action(
                  icon: Icons.email_outlined,
                  color: Colors.orange,
                  title: 'Email Support',
                  onTap: () =>
                      launchUrl(Uri.parse('mailto:info@unitradegroup.ae')),
                ),
                action(
                  icon: Icons.help_outline,
                  color: Colors.blue,
                  title: 'FAQs & Help',
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const HelpCenterPage()),
                    );
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
