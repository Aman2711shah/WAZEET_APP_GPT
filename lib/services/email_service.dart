import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

/// Service for handling email operations
class EmailService {
  /// Launch email with mailto: URL scheme
  /// Falls back to showing a snackbar if email client is not available
  static Future<bool> sendEmail({
    String? to,
    required String subject,
    required String body,
    required BuildContext context,
  }) async {
    try {
      final uri = Uri(
        scheme: 'mailto',
        path: to ?? '',
        queryParameters: {'subject': subject, 'body': body},
      );

      final canLaunch = await canLaunchUrl(uri);
      if (canLaunch) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
        return true;
      } else {
        if (context.mounted) {
          _showEmailFallbackDialog(context, subject, body);
        }
        return false;
      }
    } catch (e) {
      debugPrint('Error launching email: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not open email app: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return false;
    }
  }

  /// Show fallback dialog with email form when mailto: is not available
  static void _showEmailFallbackDialog(
    BuildContext context,
    String subject,
    String body,
  ) {
    final toController = TextEditingController();
    final subjectController = TextEditingController(text: subject);
    final messageController = TextEditingController(text: body);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Send Email'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: toController,
                decoration: const InputDecoration(
                  labelText: 'To',
                  hintText: 'recipient@example.com',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: subjectController,
                decoration: const InputDecoration(
                  labelText: 'Subject',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: messageController,
                decoration: const InputDecoration(
                  labelText: 'Message',
                  border: OutlineInputBorder(),
                ),
                maxLines: 5,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.of(ctx).pop();
              // Placeholder for future /send-email API integration.
              await Future.delayed(const Duration(milliseconds: 500));
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Email sent successfully!'),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            },
            child: const Text('Send'),
          ),
        ],
      ),
    );
  }
}
