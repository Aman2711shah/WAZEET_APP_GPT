import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/theme_provider.dart';
import '../theme.dart';

class AppearanceSettingsPage extends ConsumerWidget {
  const AppearanceSettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final isDarkMode = themeMode == ThemeMode.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(title: const Text('Appearance')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Theme Settings',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Choose how WAZEET looks to you',
            style: TextStyle(color: Colors.grey.shade600),
          ),
          const SizedBox(height: 24),

          // Light Mode Option
          Card(
            child: RadioListTile<bool>(
              value: false,
              groupValue: isDarkMode,
              onChanged: (value) {
                ref
                    .read(themeModeProvider.notifier)
                    .setThemeMode(ThemeMode.light);
              },
              title: const Text('Light Mode'),
              subtitle: const Text('Bright and clean interface'),
              secondary: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDarkMode
                      ? Colors.grey.shade800
                      : Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.light_mode,
                  color: isDarkMode ? Colors.orange.shade300 : Colors.orange,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Dark Mode Option
          Card(
            child: RadioListTile<bool>(
              value: true,
              groupValue: isDarkMode,
              onChanged: (value) {
                ref
                    .read(themeModeProvider.notifier)
                    .setThemeMode(ThemeMode.dark);
              },
              title: const Text('Dark Mode'),
              subtitle: const Text('Easy on the eyes'),
              secondary: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDarkMode
                      ? Colors.purple.shade900
                      : Colors.grey.shade800,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.dark_mode, color: Colors.white),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Info card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.purple.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.purple.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: AppColors.purple),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Theme preference is saved and will persist across app restarts.',
                    style: TextStyle(
                      fontSize: 13,
                      color: isDarkMode ? AppColors.darkText : AppColors.text,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
