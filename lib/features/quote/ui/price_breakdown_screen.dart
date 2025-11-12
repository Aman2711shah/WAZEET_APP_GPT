import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../providers.dart';

final _fmt = NumberFormat.currency(
  symbol: 'AED ',
  decimalDigits: 2,
  locale: 'en_US',
);

class PriceBreakdownScreen extends ConsumerWidget {
  const PriceBreakdownScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final quote = ref.watch(quoteProvider);
    final pkg = quote.pkg;
    return Scaffold(
      appBar: AppBar(title: const Text('Price Breakdown')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (pkg != null)
            Card(
              child: ListTile(
                title: Text(pkg.packageName ?? 'Package'),
                subtitle: Text(
                  'Freezone: ${pkg.freezone ?? '-'}  |  Tenure: ${pkg.tenureYears ?? '-'} year(s)',
                ),
              ),
            ),
          const SizedBox(height: 8),
          ...quote.items.map(
            (it) => _LineRow(label: it.label, amount: it.amount),
          ),
          const Divider(),
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Grand Total',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
              Text(
                _fmt.format(quote.total),
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          if (quote.activitiesExceeded)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: MaterialBanner(
                content: const Text(
                  'Requested activities exceed allowed for selected package. Quote is non-compliant.',
                ),
                actions: [
                  TextButton(onPressed: () {}, child: const Text('OK')),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _LineRow extends StatelessWidget {
  final String label;
  final double amount;
  const _LineRow({required this.label, required this.amount});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(child: Text(label)),
          Text(_fmt.format(amount)),
        ],
      ),
    );
  }
}
