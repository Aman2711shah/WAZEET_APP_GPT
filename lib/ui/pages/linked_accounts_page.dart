import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:simple_icons/simple_icons.dart';
import '../../providers/user_profile_provider.dart';
import '../theme.dart';

class LinkedAccountsPage extends ConsumerStatefulWidget {
  const LinkedAccountsPage({super.key});

  @override
  ConsumerState<LinkedAccountsPage> createState() => _LinkedAccountsPageState();
}

class _LinkedAccountsPageState extends ConsumerState<LinkedAccountsPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _linkedInController;
  late TextEditingController _twitterController;
  late TextEditingController _instagramController;
  late TextEditingController _websiteController;

  @override
  void initState() {
    super.initState();
    final profile = ref.read(userProfileProvider);
    _linkedInController = TextEditingController(
      text: profile?.linkedInUrl ?? '',
    );
    _twitterController = TextEditingController(text: profile?.twitterUrl ?? '');
    _instagramController = TextEditingController(
      text: profile?.instagramUrl ?? '',
    );
    _websiteController = TextEditingController(text: profile?.websiteUrl ?? '');
  }

  @override
  void dispose() {
    _linkedInController.dispose();
    _twitterController.dispose();
    _instagramController.dispose();
    _websiteController.dispose();
    super.dispose();
  }

  String? _validateUrl(String? value, String platform) {
    if (value == null || value.trim().isEmpty) {
      return null; // Optional field
    }

    final uri = Uri.tryParse(value.trim());
    if (uri == null || !uri.hasScheme || (!uri.scheme.startsWith('http'))) {
      return 'Please enter a valid URL (starting with https://)';
    }

    return null;
  }

  Future<void> _saveAccounts() async {
    if (!_formKey.currentState!.validate()) return;

    final notifier = ref.read(userProfileProvider.notifier);

    await notifier.updateLinkedAccounts(
      linkedInUrl: _linkedInController.text.trim().isEmpty
          ? null
          : _linkedInController.text.trim(),
      twitterUrl: _twitterController.text.trim().isEmpty
          ? null
          : _twitterController.text.trim(),
      instagramUrl: _instagramController.text.trim().isEmpty
          ? null
          : _instagramController.text.trim(),
      websiteUrl: _websiteController.text.trim().isEmpty
          ? null
          : _websiteController.text.trim(),
    );

    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Linked accounts updated!')));
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Linked Accounts'),
        actions: [
          TextButton(onPressed: _saveAccounts, child: const Text('Save')),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const Text(
              'Connect your social profiles',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 24),

            // LinkedIn
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(
                              0xFF0077B5,
                            ).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            SimpleIcons.linkedin,
                            color: Color(0xFF0077B5),
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          'LinkedIn',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _linkedInController,
                      decoration: const InputDecoration(
                        hintText: 'https://linkedin.com/in/yourprofile',
                        prefixIcon: Icon(Icons.link),
                      ),
                      keyboardType: TextInputType.url,
                      validator: (v) => _validateUrl(v, 'LinkedIn'),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Twitter/X
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(SimpleIcons.x, color: Colors.black),
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          'Twitter / X',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _twitterController,
                      decoration: const InputDecoration(
                        hintText: 'https://twitter.com/yourhandle',
                        prefixIcon: Icon(Icons.link),
                      ),
                      keyboardType: TextInputType.url,
                      validator: (v) => _validateUrl(v, 'Twitter'),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Instagram
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(
                              0xFFE4405F,
                            ).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            SimpleIcons.instagram,
                            color: Color(0xFFE4405F),
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          'Instagram',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _instagramController,
                      decoration: const InputDecoration(
                        hintText: 'https://instagram.com/yourprofile',
                        prefixIcon: Icon(Icons.link),
                      ),
                      keyboardType: TextInputType.url,
                      validator: (v) => _validateUrl(v, 'Instagram'),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Website
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.purple.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(Icons.language, color: AppColors.purple),
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          'Website',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _websiteController,
                      decoration: const InputDecoration(
                        hintText: 'https://yourwebsite.com',
                        prefixIcon: Icon(Icons.link),
                      ),
                      keyboardType: TextInputType.url,
                      validator: (v) => _validateUrl(v, 'Website'),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Save button
            SizedBox(
              height: 48,
              child: FilledButton.icon(
                onPressed: _saveAccounts,
                icon: const Icon(Icons.save),
                label: const Text('Save Changes'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
