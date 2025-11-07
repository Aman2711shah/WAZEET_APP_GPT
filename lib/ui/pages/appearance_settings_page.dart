import 'package:flutter/material.dart';
import 'package:provider/provider.dart' as p;
import '../../theme/theme_controller.dart';

class AppearanceSettingsPage extends StatelessWidget {
  const AppearanceSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<ThemeController>();
    final selectedTheme = controller.themeMode;
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: scheme.surface,
      appBar: AppBar(
        title: const Text('Appearance'),
        backgroundColor: scheme.surface,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Header
          Text('Theme Settings', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          Text(
            'Choose how WAZEET looks to you',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
          ),
          const SizedBox(height: 24),

          // Light Mode Option
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: RadioListTile<ThemeMode>(
              value: ThemeMode.light,
              groupValue: selectedTheme,
              onChanged: (value) {
                if (value != null) controller.setThemeMode(value);
              },
              title: Text(
                'Light Mode',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              subtitle: Text(
                'Bright and clean interface',
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
              ),
              secondary: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: scheme.secondaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.wb_sunny, color: scheme.onSecondaryContainer),
              ),
              activeColor: scheme.primary,
            ),
          ),
          const SizedBox(height: 12),

          // Dark Mode Option
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: RadioListTile<ThemeMode>(
              value: ThemeMode.dark,
              groupValue: selectedTheme,
              onChanged: (value) {
                if (value != null) controller.setThemeMode(value);
              },
              title: Text(
                'Dark Mode',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              subtitle: Text(
                'Easy on the eyes',
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
              ),
              secondary: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: scheme.secondaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.nightlight_round,
                  color: scheme.onSecondaryContainer,
                ),
              ),
              activeColor: scheme.primary,
            ),
          ),
          const SizedBox(height: 24),

          // Info Box
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: scheme.secondaryContainer,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: scheme.outlineVariant),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: scheme.onSecondaryContainer),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Theme preference is saved and will persist across app restarts.',
                    style: Theme.of(context).textTheme.bodySmall,
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
