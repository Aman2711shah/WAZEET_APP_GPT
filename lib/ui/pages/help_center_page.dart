import 'package:flutter/material.dart';

class HelpCenterPage extends StatelessWidget {
  const HelpCenterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Help & FAQs')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          Text(
            'Help Center',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 12),
          Text(
            "We're here to help. Browse common questions or contact support via the assistant.",
          ),
        ],
      ),
    );
  }
}
