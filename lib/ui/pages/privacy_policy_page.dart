import 'package:flutter/material.dart';
import '../theme.dart';

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Privacy Policy')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'WAZEET Privacy Policy',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Last updated: October 29, 2025',
            style: TextStyle(color: Colors.grey.shade600),
          ),
          const SizedBox(height: 24),

          _buildSection(
            'Information We Collect',
            'We collect information you provide directly to us, including your name, email address, phone number, and any other information you choose to provide.',
          ),
          _buildSection(
            'How We Use Your Information',
            'We use the information we collect to provide, maintain, and improve our services, to communicate with you, and to comply with legal obligations.',
          ),
          _buildSection(
            'Information Sharing',
            'We do not share your personal information with third parties except as described in this policy or with your consent.',
          ),
          _buildSection(
            'Data Security',
            'We implement appropriate technical and organizational measures to protect your personal information against unauthorized access, alteration, or destruction.',
          ),
          _buildSection(
            'Your Rights',
            'You have the right to access, update, or delete your personal information at any time through your account settings.',
          ),
          _buildSection(
            'Contact Us',
            'If you have any questions about this Privacy Policy, please contact us at privacy@wazeet.com',
          ),
          const SizedBox(height: 24),

          // Accept button
          SizedBox(
            height: 48,
            child: FilledButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('I Understand'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(content, style: const TextStyle(height: 1.5)),
        ],
      ),
    );
  }
}
