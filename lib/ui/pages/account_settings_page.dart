import 'package:flutter/material.dart';
import '../theme.dart';
import '../../services/user_prefs_service.dart';
import '../widgets/hubspot_test_widget.dart';
import 'account/change_password_page.dart';
import 'account/two_factor_page.dart';
import 'account/data_export_page.dart';
import 'account/delete_account_confirm_sheet.dart';

class AccountSettingsPage extends StatefulWidget {
  const AccountSettingsPage({super.key});

  @override
  State<AccountSettingsPage> createState() => _AccountSettingsPageState();
}

class _AccountSettingsPageState extends State<AccountSettingsPage> {
  final _prefsService = UserPreferencesService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Account Settings')),
      body: StreamBuilder<UserPreferences>(
        stream: _prefsService.preferences$,
        builder: (context, snapshot) {
          final prefs = snapshot.data ?? UserPreferences();

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // HubSpot Integration Test (Developer Tool)
              const HubSpotTestWidget(),
              const SizedBox(height: 24),

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
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const ChangePasswordPage(),
                      ),
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
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const TwoFactorPage(),
                      ),
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
                  value: prefs.emailNotifications,
                  onChanged: snapshot.hasData
                      ? (value) async {
                          try {
                            await _prefsService.setEmailNotifications(value);
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Email notifications ${value ? "enabled" : "disabled"}',
                                  ),
                                ),
                              );
                            }
                          } catch (e) {
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Failed to update: $e'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          }
                        }
                      : null,
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
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const DataExportPage(),
                      ),
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
                    showDeleteAccountSheet(context);
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
