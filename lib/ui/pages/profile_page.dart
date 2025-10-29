import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/user_profile_provider.dart';
import '../theme.dart';
import '../widgets/custom_page_header.dart';
import 'edit_profile_page.dart';
import 'linked_accounts_page.dart';
import 'account_settings_page.dart';
import 'appearance_settings_page.dart';
import 'privacy_policy_page.dart';
import 'admin_requests_page.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(userProfileProvider);
    final user = FirebaseAuth.instance.currentUser;
    final name = profile?.name ?? user?.email?.split('@').first ?? 'User';
    final email = profile?.email ?? user?.email ?? '';
    final title = profile?.title ?? 'Entrepreneur';
    final photoUrl = profile?.photoUrl;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          CustomPageHeader(
            title: 'More',
            subtitle: 'Settings, preferences & account management',
            backgroundImageUrl:
                'https://images.unsplash.com/photo-1522071820081-009f0129c71c?w=1600&h=800&fit=crop',
            trailing: CircleAvatar(
              radius: 32,
              backgroundColor: Colors.white,
              backgroundImage: photoUrl != null ? NetworkImage(photoUrl) : null,
              child: photoUrl == null
                  ? Text(
                      name.isNotEmpty ? name[0].toUpperCase() : 'U',
                      style: const TextStyle(
                        fontSize: 24,
                        color: AppColors.purple,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  : null,
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Profile summary
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 36,
                          backgroundImage: photoUrl != null
                              ? NetworkImage(photoUrl)
                              : null,
                          child: photoUrl == null
                              ? Text(
                                  name.isNotEmpty ? name[0].toUpperCase() : 'U',
                                  style: const TextStyle(fontSize: 24),
                                )
                              : null,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          title,
                          style: TextStyle(color: Colors.grey.shade600),
                        ),
                        Text(
                          email,
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Settings list
                _menuItem(
                  context,
                  icon: Icons.person_outline,
                  title: 'Account Settings',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const AccountSettingsPage(),
                      ),
                    );
                  },
                ),
                _menuItem(
                  context,
                  icon: Icons.edit_outlined,
                  title: 'Edit Profile',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const EditProfilePage(),
                      ),
                    );
                  },
                ),
                _menuItem(
                  context,
                  icon: Icons.link_outlined,
                  title: 'Linked Accounts',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const LinkedAccountsPage(),
                      ),
                    );
                  },
                ),
                const Divider(height: 32),
                // Admin section
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 4,
                    vertical: 8,
                  ),
                  child: Row(
                    children: [
                      const Text(
                        'Admin',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.purple.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'ADMIN ONLY',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: AppColors.purple,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                _menuItem(
                  context,
                  icon: Icons.admin_panel_settings,
                  title: 'Service Requests',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const AdminRequestsPage(),
                      ),
                    );
                  },
                ),
                const Divider(height: 32),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 4),
                  child: Text(
                    'App Preferences',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                _menuItem(
                  context,
                  icon: Icons.dark_mode_outlined,
                  title: 'Appearance (Light/Dark)',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const AppearanceSettingsPage(),
                      ),
                    );
                  },
                ),
                _menuItem(
                  context,
                  icon: Icons.privacy_tip_outlined,
                  title: 'Privacy Policy',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const PrivacyPolicyPage(),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 24),

                // Logout
                SizedBox(
                  height: 48,
                  child: FilledButton(
                    style: FilledButton.styleFrom(backgroundColor: Colors.red),
                    onPressed: () => FirebaseAuth.instance.signOut(),
                    child: const Text('Logout'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _menuItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    VoidCallback? onTap,
  }) {
    return Card(
      child: ListTile(
        leading: Icon(icon),
        title: Text(title),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
