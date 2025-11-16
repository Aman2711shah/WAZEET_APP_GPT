import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:simple_icons/simple_icons.dart';

import '../pages/ai_business_chat_page.dart';

/// A reusable panel that shows multiple contact/share options
/// under the "Need a custom solution?" section.
class CustomSolutionPanel extends StatelessWidget {
  const CustomSolutionPanel({super.key});

  static const _supportEmail = 'support@wazeet.com';
  static const _phone = '+971559986386';

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: scheme.primary.withValues(alpha: .08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Need a custom solution?',
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
          ),
          const SizedBox(height: 8),
          Text(
            'Choose how you’d like to reach us or share with your team.',
            style: TextStyle(color: scheme.onSurfaceVariant, fontSize: 13),
          ),
          const SizedBox(height: 12),
          _actionTile(
            context,
            icon: Icons.email_outlined,
            title: 'Send Email',
            subtitle: 'Contact us via email',
            onTap: () => _sendEmail(context),
          ),
          _divider(scheme),
          _actionTile(
            context,
            icon: Icons.call_outlined,
            title: 'Call Now',
            subtitle: '+971 55 998 6386',
            onTap: () => _callNow(context),
          ),
          _divider(scheme),
          _actionTile(
            context,
            icon: SimpleIcons.whatsapp,
            title: 'WhatsApp Chat',
            subtitle: 'Instant messaging',
            onTap: () => _openWhatsApp(context),
          ),
          _divider(scheme),
          _actionTile(
            context,
            icon: Icons.smart_toy_outlined,
            title: 'Ask with AI (ChatGPT)',
            subtitle: 'Get instant answers',
            onTap: () => _openAIChat(context),
          ),
        ],
      ),
    );
  }

  static Widget _divider(ColorScheme scheme) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 8),
    child: Divider(height: 1, color: scheme.outlineVariant),
  );

  static Widget _actionTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    final scheme = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: scheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: scheme.primary),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: scheme.onSurfaceVariant,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: scheme.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }

  static Future<void> _sendEmail(BuildContext context) async {
    final uri = Uri(
      scheme: 'mailto',
      path: _supportEmail,
      queryParameters: {'subject': 'Wazeet – Custom Solution Request'},
    );
    final ok = await launchUrl(uri);
    if (!ok && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Email not supported on this device.')),
      );
    }
  }

  static Future<void> _callNow(BuildContext context) async {
    final uri = Uri(scheme: 'tel', path: _phone);
    final ok = await launchUrl(uri);
    if (!ok && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Calling is not supported on this device.'),
        ),
      );
    }
  }

  static void _openAIChat(BuildContext context) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const AIBusinessChatPage()));
  }

  static Future<void> _openWhatsApp(BuildContext context) async {
    // Remove '+' for wa.me format
    final cleaned = _phone.replaceAll('+', '');
    final uri = Uri.parse(
      'https://wa.me/$cleaned?text=${Uri.encodeComponent('Hello Wazeet team, I would like a custom solution.')}',
    );
    final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!ok && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('WhatsApp not available on this device.')),
      );
    }
  }
}
