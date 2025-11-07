import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import '../../models/freezone.dart';
import '../theme.dart';
import '../../providers/bookmarks_provider.dart';
import '../../services/email_service.dart';
import '../../services/phone_service.dart';
import '../widgets/share_freezones_sheet.dart';
import '../widgets/ask_with_ai_sheet.dart';

class FreeZoneDetailPage extends ConsumerWidget {
  final FreeZone zone;

  const FreeZoneDetailPage({super.key, required this.zone});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookmarks = ref.watch(bookmarksProvider);
    final isBookmarked = bookmarks.contains(zone.id);
    return Scaffold(
      appBar: AppBar(
        title: Text(zone.abbreviation),
        backgroundColor: AppColors.primary,
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {
              final shareText =
                  'Free Zone: ${zone.name} (${_getEmirateDisplayName(zone.emirate)})\nStarting from: ${zone.startingPriceFormatted}';
              Share.share(shareText, subject: 'Check this Free Zone');
            },
          ),
          IconButton(
            icon: Icon(isBookmarked ? Icons.bookmark : Icons.bookmark_border),
            onPressed: () async {
              await ref.read(bookmarksProvider.notifier).toggle(zone.id);
              if (context.mounted) {
                final msg = isBookmarked ? 'Removed bookmark' : 'Bookmarked';
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text(msg)));
              }
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
                          color: AppColors.primary.withValues(alpha: 0.1),
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

          // Pricing Section with Stacked Cards
          Card(
            elevation: 0,
            color: Colors.grey[50],
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.green[100],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.monetization_on,
                          color: Colors.green[700],
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'Pricing',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Starting from',
                    style: TextStyle(color: Colors.grey[600], fontSize: 14),
                  ),
                  const SizedBox(height: 20),
                  _buildPricingCards(),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // License Types
          Card(
            elevation: 0,
            color: Colors.grey[50],
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.purple.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.business_outlined,
                          color: AppColors.purple,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'License Types',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ...zone.licenseTypes.map(
                    (type) => _buildLicenseTypeCard(type),
                  ),
                ],
              ),
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
            onPressed: () => _showContactSheet(context),
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

  void _showContactSheet(BuildContext context) {
    final subject = 'Inquiry about ${zone.name}';
    final body =
        'Hello,\n\nI am interested in ${zone.name} (${_getEmirateDisplayName(zone.emirate)}).\nStarting from: ${zone.startingPriceFormatted}.\n\nPlease share more details.\n\nThanks,';
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.email_outlined),
              title: const Text('Send Email'),
              subtitle: const Text('Contact us via email'),
              onTap: () async {
                Navigator.of(ctx).pop();
                await EmailService.sendEmail(
                  subject: subject,
                  body: body,
                  context: context,
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.share_outlined),
              title: const Text('Share Freezones & Mention'),
              subtitle: const Text('Share with team members'),
              onTap: () {
                Navigator.of(ctx).pop();
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (_) => const ShareFreezonesSheet(),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.call_outlined),
              title: const Text('Call Now'),
              subtitle: const Text('+971 55 998 6386'),
              onTap: () {
                Navigator.of(ctx).pop();
                PhoneService.makeCall(context);
              },
              onLongPress: () {
                PhoneService.copyPhoneNumber(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.smart_toy_outlined),
              title: const Text('Ask with AI (ChatGPT)'),
              subtitle: const Text('Get instant answers'),
              onTap: () {
                Navigator.of(ctx).pop();
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const AskWithAISheet(),
                    fullscreenDialog: true,
                  ),
                );
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
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

  Widget _buildPricingCards() {
    final setupValue = zone.costs['setup'];
    final renewalValue = zone.costs['annual_renewal'];

    // Handle string format (new data structure)
    if (setupValue is String || renewalValue is String) {
      return _buildStringBasedPricingCards(setupValue, renewalValue);
    }

    // Handle Map format (old data structure)
    final setup = setupValue is Map<String, dynamic> ? setupValue : null;
    final renewal = renewalValue is Map<String, dynamic> ? renewalValue : null;

    if (setup == null && renewal == null) {
      return _buildSinglePricingCard(
        'Contact for Pricing',
        'Please contact us for detailed pricing information',
        '',
        Icons.phone,
      );
    }

    return Column(
      children: [
        if (setup != null && setup.isNotEmpty) ...[
          const Text(
            'Setup Costs',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 16,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          ...setup.entries.map(
            (entry) => _buildPricingCardFromMap(entry.key, entry.value),
          ),
          const SizedBox(height: 20),
        ],
        if (renewal != null && renewal.isNotEmpty) ...[
          const Text(
            'Annual Renewal',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 16,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          ...renewal.entries.map(
            (entry) => _buildPricingCardFromMap(entry.key, entry.value),
          ),
        ],
      ],
    );
  }

  Widget _buildStringBasedPricingCards(
    dynamic setupValue,
    dynamic renewalValue,
  ) {
    // Parse the string format pricing information
    final List<Widget> cards = [];

    if (setupValue is String && setupValue.isNotEmpty) {
      cards.add(
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Setup Costs',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 16,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            ..._parseStringPricing(setupValue),
            const SizedBox(height: 20),
          ],
        ),
      );
    }

    if (renewalValue is String && renewalValue.isNotEmpty) {
      cards.add(
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Annual Renewal',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 16,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            ..._parseStringPricing(renewalValue),
          ],
        ),
      );
    }

    return Column(children: cards);
  }

  List<Widget> _parseStringPricing(String pricingText) {
    // Parse formats like "License: AED 15,020 / General Trading: AED 50,000 / Registration: AED 7,000"
    final items = pricingText.split('/').map((s) => s.trim()).toList();
    return items.map((item) {
      final parts = item.split(':').map((s) => s.trim()).toList();
      if (parts.length == 2) {
        return _buildSinglePricingCard(
          parts[0],
          '',
          parts[1],
          _getIconForPricingType(parts[0]),
        );
      }
      return _buildSinglePricingCard('Price', '', item, Icons.attach_money);
    }).toList();
  }

  Widget _buildPricingCardFromMap(String label, dynamic value) {
    String displayValue = '';
    if (value is Map) {
      final amount = value['amount'];
      final currency = value['currency'] ?? 'AED';
      displayValue = amount != null ? '$currency $amount' : 'Contact for price';
    } else {
      displayValue = value.toString();
    }

    return _buildSinglePricingCard(
      _formatKey(label),
      '',
      displayValue,
      _getIconForPricingType(label),
    );
  }

  Widget _buildSinglePricingCard(
    String title,
    String subtitle,
    String price,
    IconData icon,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.purple.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: AppColors.purple, size: 22),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                if (subtitle.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                  ),
                ],
              ],
            ),
          ),
          if (price.isNotEmpty)
            Text(
              price,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.green[700],
              ),
            ),
        ],
      ),
    );
  }

  IconData _getIconForPricingType(String type) {
    final lowerType = type.toLowerCase();
    if (lowerType.contains('license')) return Icons.description;
    if (lowerType.contains('trading')) return Icons.business_center;
    if (lowerType.contains('registration')) return Icons.app_registration;
    if (lowerType.contains('desk') || lowerType.contains('package')) {
      return Icons.desk;
    }
    if (lowerType.contains('visa')) return Icons.badge;
    if (lowerType.contains('office')) return Icons.domain;
    if (lowerType.contains('renewal')) return Icons.refresh;
    return Icons.attach_money;
  }

  Widget _buildLicenseTypeCard(String type) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.purple.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: AppColors.purple.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              _getLicenseTypeIcon(type),
              color: AppColors.purple,
              size: 18,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              type,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getLicenseTypeIcon(String type) {
    final lowerType = type.toLowerCase();
    if (lowerType.contains('trade')) return Icons.store;
    if (lowerType.contains('service')) return Icons.room_service;
    if (lowerType.contains('industrial') ||
        lowerType.contains('manufacturing')) {
      return Icons.factory;
    }
    if (lowerType.contains('education')) return Icons.school;
    if (lowerType.contains('general')) return Icons.business;
    if (lowerType.contains('professional')) return Icons.work;
    if (lowerType.contains('commercial')) return Icons.shopping_bag;
    return Icons.description;
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
