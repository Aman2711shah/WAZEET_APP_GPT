import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers.dart';
import 'price_breakdown_screen.dart';

class PackageConfiguratorScreen extends ConsumerWidget {
  const PackageConfiguratorScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final visas = ref.watch(visasProvider);
    final activities = ref.watch(activitiesProvider);
    final shareholders = ref.watch(shareholdersProvider);
    final tenure = ref.watch(tenureProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Configure Package')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Visas
          const Text(
            'Number of visas',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          Slider(
            value: visas.toDouble(),
            onChanged: (v) =>
                ref.read(visasProvider.notifier).state = v.round().clamp(0, 20),
            min: 0,
            max: 20,
            divisions: 20,
            label: '$visas',
          ),
          Text('$visas visa(s)', style: const TextStyle(fontSize: 12)),
          const SizedBox(height: 16),
          // Activities
          const Text(
            'Number of activities',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          Slider(
            value: activities.toDouble(),
            onChanged: (v) => ref.read(activitiesProvider.notifier).state = v
                .round()
                .clamp(1, 20),
            min: 1,
            max: 20,
            divisions: 19,
            label: '$activities',
          ),
          Text(
            '$activities activity(ies)',
            style: const TextStyle(fontSize: 12),
          ),
          const SizedBox(height: 16),
          // Shareholders
          const Text(
            'Number of shareholders',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          Slider(
            value: shareholders.toDouble(),
            onChanged: (v) => ref.read(shareholdersProvider.notifier).state = v
                .round()
                .clamp(1, 10),
            min: 1,
            max: 10,
            divisions: 9,
            label: '$shareholders',
          ),
          Text(
            '$shareholders shareholder(s)',
            style: const TextStyle(fontSize: 12),
          ),
          const SizedBox(height: 16),
          // Tenure
          const Text(
            'License tenure (years)',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          Slider(
            value: tenure.toDouble(),
            onChanged: (v) =>
                ref.read(tenureProvider.notifier).state = v.round().clamp(1, 5),
            min: 1,
            max: 5,
            divisions: 4,
            label: '$tenure',
          ),
          Text('$tenure year(s)', style: const TextStyle(fontSize: 12)),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const PriceBreakdownScreen(),
                  ),
                );
              },
              child: const Text('See Price Breakdown'),
            ),
          ),
        ],
      ),
    );
  }
}
