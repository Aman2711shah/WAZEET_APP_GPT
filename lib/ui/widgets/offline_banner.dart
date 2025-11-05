import 'dart:io';
import 'package:flutter/material.dart';

/// Simple offline indicator banner
/// Shows a dismissible banner when network errors occur
class OfflineBanner extends StatelessWidget {
  final VoidCallback? onRetry;
  
  const OfflineBanner({super.key, this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: Colors.orange.shade800,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          const Icon(
            Icons.cloud_off,
            color: Colors.white,
            size: 18,
          ),
          const SizedBox(width: 8),
          const Expanded(
            child: Text(
              'No internet connection. Some features may be unavailable.',
              style: TextStyle(
                color: Colors.white,
                fontSize: 13,
              ),
            ),
          ),
          if (onRetry != null)
            TextButton(
              onPressed: onRetry,
              child: const Text(
                'Retry',
                style: TextStyle(color: Colors.white),
              ),
            ),
        ],
      ),
    );
  }
}

/// Helper method to check internet connectivity
Future<bool> hasInternetConnection() async {
  try {
    final result = await InternetAddress.lookup('google.com');
    return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
  } catch (_) {
    return false;
  }
}
