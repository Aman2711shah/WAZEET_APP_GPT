import 'package:flutter/material.dart';
import '../ui/widgets/gradient_header.dart';
import '../ui/widgets/settings_item.dart';

class MoreTab extends StatelessWidget {
  const MoreTab({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        const GradientHeader(title: '', height: 200),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              const Text(
                'Account Settings',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 12),
              SettingsItem(
                icon: Icons.settings,
                title: 'Account Settings',
                onTap: () {},
              ),
              const SizedBox(height: 8),
              SettingsItem(
                icon: Icons.edit,
                title: 'Edit Profile',
                onTap: () {},
              ),
              const SizedBox(height: 8),
              SettingsItem(
                icon: Icons.link,
                title: 'Linked Accounts',
                onTap: () {},
              ),
              const SizedBox(height: 24),
              const Text(
                'App Preferences',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 12),
              SettingsItem(
                icon: Icons.palette,
                title: 'Appearance',
                trailing: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Light-Dark Mode (*)'),
                    SizedBox(width: 8),
                    Icon(Icons.chevron_right),
                  ],
                ),
                onTap: () {},
              ),
              const SizedBox(height: 8),
              SettingsItem(
                icon: Icons.privacy_tip,
                title: 'Privacy Policy',
                onTap: () {},
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () {},
                  child: const Text('Logout'),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
