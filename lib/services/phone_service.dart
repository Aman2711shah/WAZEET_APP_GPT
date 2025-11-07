import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

/// Service for handling phone call operations
class PhoneService {
  static const String supportPhoneNumber = '+971559986386';

  /// Launch phone dialer with the support number
  static Future<bool> makeCall(BuildContext context) async {
    try {
      final uri = Uri.parse('tel:$supportPhoneNumber');
      final canLaunch = await canLaunchUrl(uri);

      if (canLaunch) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
        return true;
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Cannot make calls on this device'),
              backgroundColor: Colors.orange,
            ),
          );
        }
        return false;
      }
    } catch (e) {
      debugPrint('Error launching phone dialer: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
      return false;
    }
  }

  /// Copy phone number to clipboard
  static Future<void> copyPhoneNumber(BuildContext context) async {
    await Clipboard.setData(const ClipboardData(text: supportPhoneNumber));
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Phone number copied to clipboard'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  /// Show bottom sheet with call options
  static void showCallOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.call, color: Colors.green),
                title: const Text('Call Now'),
                subtitle: const Text(supportPhoneNumber),
                onTap: () {
                  Navigator.of(ctx).pop();
                  makeCall(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.copy_all_outlined),
                title: const Text('Copy Number'),
                subtitle: const Text(supportPhoneNumber),
                onTap: () {
                  Navigator.of(ctx).pop();
                  copyPhoneNumber(context);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
