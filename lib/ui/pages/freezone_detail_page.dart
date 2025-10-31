import 'package:flutter/material.dart';
import '../../models/freezone.dart';
import '../theme.dart';

class FreeZoneDetailPage extends StatelessWidget {
  final FreeZone zone;

  const FreeZoneDetailPage({super.key, required this.zone});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(zone.abbreviation),
        backgroundColor: AppColors.primary,
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {
              // TODO: Implement share functionality
            },
          ),
          IconButton(
            icon: const Icon(Icons.bookmark_border),
            onPressed: () {
              // TODO: Implement bookmark functionality
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Header Card
          Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.apartment,
                          color: AppColors.primary,
                          size: 32,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              zone.name,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              _getEmirateDisplayName(zone.emirate),
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  if (zone.established != null) ...[
                    const SizedBox(height: 12),
                    Text(
                      'Established: ${zone.established}',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ],
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Price Card
          Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.attach_money, color: Colors.green[700]),
                      const SizedBox(width: 8),
                      const Text(
                        'Pricing',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Starting from',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    zone.startingPriceFormatted,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.green[700],
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildPricingTable(),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // License Types
          _buildSection(
            'License Types',
            Icons.business_outlined,
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: zone.licenseTypes
                  .map(
                    (type) => Chip(
                      label: Text(type),
                      backgroundColor: AppColors.primary.withOpacity(0.1),
                    ),
                  )
                  .toList(),
            ),
          ),

          const SizedBox(height: 16),

          // Visa Allocation
          _buildSection(
            'Visa Allocation',
            Icons.people_outlined,
            child: _buildVisaAllocation(),
          ),

          const SizedBox(height: 16),

          // Industries
          if (zone.industries.isNotEmpty)
            _buildSection(
              'Industries',
              Icons.category_outlined,
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: zone.industries
                    .take(10)
                    .map(
                      (industry) => Chip(
                        label: Text(
                          industry,
                          style: const TextStyle(fontSize: 12),
                        ),
                        backgroundColor: Colors.grey[200],
                      ),
                    )
                    .toList(),
              ),
            ),

          const SizedBox(height: 16),

          // Key Advantages
          _buildSection(
            'Key Advantages',
            Icons.check_circle_outline,
            child: Column(
              children: zone.keyAdvantages
                  .map(
                    (advantage) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.check_circle,
                            color: Colors.green[600],
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              advantage,
                              style: const TextStyle(fontSize: 15),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),

          const SizedBox(height: 16),

          // Notable Limitations
          if (zone.notableLimitations.isNotEmpty)
            _buildSection(
              'Notable Limitations',
              Icons.info_outline,
              child: Column(
                children: zone.notableLimitations
                    .map(
                      (limitation) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.info,
                              color: Colors.orange[600],
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                limitation,
                                style: const TextStyle(fontSize: 15),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),

          const SizedBox(height: 16),

          // Special Features
          if (zone.specialFeatures != null && zone.specialFeatures!.isNotEmpty)
            _buildSection(
              'Special Features',
              Icons.star_outline,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: zone.specialFeatures!.entries
                    .map(
                      (entry) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          children: [
                            Icon(
                              Icons.star,
                              color: Colors.amber[700],
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                '${_formatKey(entry.key)}: ${entry.value}',
                                style: const TextStyle(fontSize: 14),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),

          const SizedBox(height: 24),

          // CTA Button
          ElevatedButton(
            onPressed: () {
              // TODO: Implement contact or inquiry functionality
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Get Started with This Free Zone',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),

          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildSection(String title, IconData icon, {required Widget child}) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: AppColors.primary),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            child,
          ],
        ),
      ),
    );
  }

  Widget _buildPricingTable() {
    final setupValue = zone.costs['setup'];
    final renewalValue = zone.costs['annual_renewal'];

    // Handle string format (new data structure)
    if (setupValue is String || renewalValue is String) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (setupValue is String && setupValue.isNotEmpty) ...[
            const Text(
              'Setup Costs',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(setupValue),
            const SizedBox(height: 16),
          ],
          if (renewalValue is String && renewalValue.isNotEmpty) ...[
            const Text(
              'Annual Renewal',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(renewalValue),
          ],
        ],
      );
    }

    // Handle Map format (old data structure)
    final setup = setupValue is Map<String, dynamic> ? setupValue : null;
    final renewal = renewalValue is Map<String, dynamic> ? renewalValue : null;

    if (setup == null && renewal == null) {
      return const Text('Contact for pricing details');
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (setup != null && setup.isNotEmpty) ...[
          const Text(
            'Setup Costs',
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
          ),
          const SizedBox(height: 8),
          ...setup.entries.map(
            (entry) => _buildPriceRow(entry.key, entry.value),
          ),
          const SizedBox(height: 16),
        ],
        if (renewal != null && renewal.isNotEmpty) ...[
          const Text(
            'Annual Renewal',
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
          ),
          const SizedBox(height: 8),
          ...renewal.entries.map(
            (entry) => _buildPriceRow(entry.key, entry.value),
          ),
        ],
      ],
    );
  }

  Widget _buildPriceRow(String label, dynamic value) {
    String displayValue = '';
    if (value is Map) {
      final amount = value['amount'];
      final currency = value['currency'] ?? 'AED';
      displayValue = amount != null ? '$currency $amount' : 'Contact for price';
    } else {
      displayValue = value.toString();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              _formatKey(label),
              style: const TextStyle(fontSize: 14),
            ),
          ),
          Text(
            displayValue,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _buildVisaAllocation() {
    if (zone.visaAllocation.isEmpty) {
      return const Text('Contact for visa allocation details');
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: zone.visaAllocation.entries.map((entry) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(_formatKey(entry.key), style: const TextStyle(fontSize: 15)),
              Text(
                entry.value.toString(),
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  String _formatKey(String key) {
    return key
        .replaceAll('_', ' ')
        .split(' ')
        .map((word) => word[0].toUpperCase() + word.substring(1))
        .join(' ');
  }

  String _getEmirateDisplayName(String emirate) {
    final map = {
      'abu_dhabi': 'Abu Dhabi',
      'dubai': 'Dubai',
      'sharjah': 'Sharjah',
      'ras_al_khaimah': 'Ras Al Khaimah',
      'ajman': 'Ajman',
      'fujairah': 'Fujairah',
      'umm_al_quwain': 'Umm Al Quwain',
    };
    return map[emirate] ??
        emirate
            .replaceAll('_', ' ')
            .split(' ')
            .map((w) => w[0].toUpperCase() + w.substring(1))
            .join(' ');
  }
}
