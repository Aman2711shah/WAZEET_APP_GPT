import 'package:flutter/material.dart';
import '../../models/freezone.dart';
import '../theme.dart';

class FreeZoneCard extends StatelessWidget {
  final FreeZone zone;
  final VoidCallback onTap;
  final bool compareMode;
  final bool isSelected;
  final ValueChanged<bool?>? onSelect;

  const FreeZoneCard({
    super.key,
    required this.zone,
    required this.onTap,
    this.compareMode = false,
    this.isSelected = false,
    this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isSelected
            ? BorderSide(color: AppColors.primary, width: 2)
            : BorderSide.none,
      ),
      child: InkWell(
        onTap: compareMode ? null : onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with name and badges
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (compareMode)
                    Padding(
                      padding: const EdgeInsets.only(right: 12),
                      child: Checkbox(
                        value: isSelected,
                        onChanged: onSelect,
                        activeColor: AppColors.primary,
                      ),
                    ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                zone.name,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          zone.abbreviation,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Badges row
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  _buildBadge(
                    _getEmirateDisplayName(zone.emirate),
                    AppColors.primary.withOpacity(0.1),
                    AppColors.primary,
                  ),
                  ..._getDynamicBadges(),
                ],
              ),

              const SizedBox(height: 12),

              // Starting price
              Row(
                children: [
                  Icon(Icons.attach_money, size: 18, color: Colors.green[700]),
                  const SizedBox(width: 4),
                  Text(
                    'Starting from ',
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                  Text(
                    zone.startingPriceFormatted,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.green[700],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Quick info icons
              Row(
                children: [
                  _buildInfoChip(
                    Icons.business_outlined,
                    '${zone.licenseTypes.length} license types',
                  ),
                  const SizedBox(width: 12),
                  _buildInfoChip(
                    Icons.people_outline,
                    '${_getMaxVisas()} visas',
                  ),
                  if (zone.remoteSetup == true) ...[
                    const SizedBox(width: 12),
                    _buildInfoChip(Icons.cloud_outlined, 'Remote setup'),
                  ],
                ],
              ),

              const SizedBox(height: 12),

              // Key advantages (top 2-3)
              ...zone.keyAdvantages
                  .take(3)
                  .map(
                    (advantage) => Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.check_circle,
                            size: 16,
                            color: Colors.green[600],
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              advantage,
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey[700],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

              const SizedBox(height: 8),

              // View details button
              if (!compareMode)
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: onTap,
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('View Details'),
                        SizedBox(width: 4),
                        Icon(Icons.arrow_forward, size: 16),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBadge(String text, Color bgColor, Color textColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
    );
  }

  List<Widget> _getDynamicBadges() {
    final badges = <Widget>[];

    // Low Cost badge
    final price = zone.startingPrice;
    if (price != null && price < 10000) {
      badges.add(
        _buildBadge('Low Cost', Colors.green[100]!, Colors.green[700]!),
      );
    }

    // Top Rated badge
    if (zone.rating != null && zone.rating! >= 4.5) {
      badges.add(
        _buildBadge('Top Rated', Colors.amber[100]!, Colors.amber[900]!),
      );
    }

    // Dual License badge
    if (zone.dualLicense == true) {
      badges.add(
        _buildBadge('Dual License', Colors.purple[100]!, Colors.purple[700]!),
      );
    }

    // Women Entrepreneur badge
    final womenEntrepreneur =
        zone.specialFeatures?['women_entrepreneur_offers'] != null;
    if (womenEntrepreneur) {
      badges.add(
        _buildBadge('Women Entrepreneur', Colors.pink[100]!, Colors.pink[700]!),
      );
    }

    return badges;
  }

  Widget _buildInfoChip(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: Colors.grey[600]),
        const SizedBox(width: 4),
        Text(text, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
      ],
    );
  }

  int _getMaxVisas() {
    try {
      final allocation = zone.visaAllocation;
      int maxVisas = 0;
      for (final value in allocation.values) {
        if (value is int && value > maxVisas) {
          maxVisas = value;
        }
      }
      return maxVisas;
    } catch (e) {
      return 0;
    }
  }

  String _getEmirateDisplayName(String emirate) {
    final map = {
      'abu_dhabi': 'Abu Dhabi',
      'dubai': 'Dubai',
      'sharjah': 'Sharjah',
      'ras_al_khaimah': 'RAK',
      'ajman': 'Ajman',
      'fujairah': 'Fujairah',
      'umm_al_quwain': 'UAQ',
    };
    return map[emirate] ?? emirate;
  }
}
