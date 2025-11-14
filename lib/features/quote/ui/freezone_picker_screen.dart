import 'package:flutter/material.dart';

/// Temporary stub to unblock web runs.
/// Replace with the real FreezonePickerScreen implementation when available.
class FreezonePickerScreen extends StatelessWidget {
  const FreezonePickerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Freezone Quote')),
      body: const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text(
            'Freezone quote flow is coming soon.\n\n'
            'This is a placeholder screen to allow the app to run on the web.',
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
