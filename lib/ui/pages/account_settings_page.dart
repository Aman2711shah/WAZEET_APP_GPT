import 'package:flutter/material.dart';
import '../theme.dart';

class AccountSettingsPage extends StatelessWidget {
  const AccountSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Account Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Security & Privacy',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          // Change Password
          Card(
            child: ListTile(
              leading: const Icon(Icons.lock_outline),
              title: const Text('Change Password'),
              subtitle: const Text('Update your account password'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Password change coming soon!')),
                );
              },
            ),
          ),
          const SizedBox(height: 12),

          // Two-Factor Authentication
          Card(
            child: ListTile(
              leading: const Icon(Icons.security),
              title: const Text('Two-Factor Authentication'),
              subtitle: const Text('Add an extra layer of security'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('2FA setup coming soon!')),
                );
              },
            ),
          ),
          const SizedBox(height: 12),

          // Email Notifications
          Card(
            child: SwitchListTile(
              secondary: const Icon(Icons.notifications_outlined),
              title: const Text('Email Notifications'),
              subtitle: const Text('Receive updates via email'),
              value: true,
              onChanged: (value) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Email notifications ${value ? "enabled" : "disabled"}',
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 24),

          const Text(
            'Data Management',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          // Download Data
          Card(
            child: ListTile(
              leading: const Icon(Icons.download_outlined),
              title: const Text('Download Your Data'),
              subtitle: const Text('Export all your information'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Data export coming soon!')),
                );
              },
            ),
          ),
          const SizedBox(height: 12),

          // Delete Account
          Card(
            child: ListTile(
              leading: const Icon(Icons.delete_outline, color: Colors.red),
              title: const Text(
                'Delete Account',
                style: TextStyle(color: Colors.red),
              ),
              subtitle: const Text('Permanently delete your account'),
              trailing: const Icon(Icons.chevron_right, color: Colors.red),
              onTap: () {
                _showDeleteAccountDialog(context);
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteAccountDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Account?'),
        content: const Text(
          'This action cannot be undone. All your data will be permanently deleted.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Account deletion coming soon!')),
              );
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
