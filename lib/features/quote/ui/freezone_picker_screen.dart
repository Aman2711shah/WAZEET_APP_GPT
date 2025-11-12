import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers.dart';
import 'package_configurator_screen.dart';

class FreezonePickerScreen extends ConsumerWidget {
  const FreezonePickerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final zone = ref.watch(freezoneProvider);
    final zones = const ['RAKEZ', 'SHAMS', 'IFZA', 'SPCFZ', 'MEYDAN'];
    return Scaffold(
      appBar: AppBar(title: const Text('Get a Quote')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Select Freezone',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Choose the free zone where you want to set up your business',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Freezone',
              ),
              value: zone,
              items: zones
                  .map((z) => DropdownMenuItem(value: z, child: Text(z)))
                  .toList(),
              onChanged: (v) {
                if (v != null) {
                  ref.read(freezoneProvider.notifier).state = v;
                }
              },
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const PackageConfiguratorScreen(),
                    ),
                  );
                },
                child: const Text('Configure Package'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
