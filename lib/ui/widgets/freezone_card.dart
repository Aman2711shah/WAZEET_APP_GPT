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
    // Light mode only - dark mode removed
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: isSelected ? 8 : 3,
      shadowColor: isSelected
          ? AppColors.primary.withValues(alpha: 0.4)
          : Colors.black26,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: isSelected
            ? BorderSide(color: AppColors.primary, width: 2.5)
            : BorderSide.none,
      ),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: isSelected
              ? LinearGradient(
                  colors: [
                    AppColors.primary.withValues(alpha: 0.05),
                    Colors.white,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
        ),
        child: InkWell(
          onTap: compareMode ? null : onTap,
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            children: [
              // Decorative corner circle
              Positioned(
                right: -20,
                top: -20,
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.primary.withValues(alpha: 0.03),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header with name and badges
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (compareMode)
                          Container(
                            margin: const EdgeInsets.only(right: 12),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppColors.primary.withValues(alpha: 0.1)
                                  : Colors.grey.withValues(alpha: 0.05),
                              borderRadius: BorderRadius.circular(8),
                            ),
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
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.grey[900],
                                        letterSpacing: -0.5,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withValues(
                                    alpha: 0.1,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  zone.abbreviation,
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.primary,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Badges row with enhanced design
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _buildBadge(
                          _getEmirateDisplayName(zone.emirate),
                          AppColors.primary.withValues(alpha: 0.15),
                          AppColors.primary,
                          Icons.location_city,
                        ),
                        ..._getDynamicBadges(),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Starting price with enhanced design
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.green[50]!,
                            Colors.green[100]!.withValues(alpha: 0.3),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.green[200]!, width: 1),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.green[600],
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.attach_money,
                              size: 18,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Starting from',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[700],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                zone.startingPriceFormatted,
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green[800],
                                  letterSpacing: -0.5,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Quick info chips with enhanced design
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: [
                        _buildInfoChip(
                          Icons.business_center,
                          '${zone.licenseTypes.length} license types',
                          Colors.blue,
                        ),
                        _buildInfoChip(
                          Icons.people,
                          '${_getMaxVisas()} visas',
                          Colors.purple,
                        ),
                        if (zone.remoteSetup == true)
                          _buildInfoChip(
                            Icons.cloud_done,
                            'Remote setup',
                            Colors.teal,
                          ),
                      ],
                    ),

                    const SizedBox(height: 18),

                    // Divider
                    Container(
                      height: 1,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.transparent,
                            Colors.grey[300]!,
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 18),

                    // Key advantages (top 3) with enhanced design
                    ...zone.keyAdvantages
                        .take(3)
                        .map(
                          (advantage) => Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  margin: const EdgeInsets.only(top: 2),
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: Colors.green[50],
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.check_circle,
                                    size: 16,
                                    color: Colors.green[600],
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    advantage,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey[800],
                                      height: 1.4,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                    if (!compareMode) ...[
                      const SizedBox(height: 12),

                      // View details button with gradient
                      Align(
                        alignment: Alignment.centerRight,
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                AppColors.primary,
                                AppColors.primary.withValues(alpha: 0.8),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(25),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary.withValues(alpha: 0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: ElevatedButton(
                            onPressed: onTap,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 12,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(25),
                              ),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'View Details',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 15,
                                    color: Colors.white,
                                  ),
                                ),
                                SizedBox(width: 8),
                                Icon(
                                  Icons.arrow_forward,
                                  size: 18,
                                  color: Colors.white,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBadge(
    String text,
    Color bgColor,
    Color textColor, [
    IconData? icon,
  ]) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: textColor.withValues(alpha: 0.2),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 14, color: textColor),
            const SizedBox(width: 4),
          ],
          Text(
            text,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: textColor,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _getDynamicBadges() {
    final badges = <Widget>[];

    // Low Cost badge
    final price = zone.startingPrice;
    if (price != null && price < 10000) {
      badges.add(
        _buildBadge(
          'Low Cost',
          Colors.green[100]!,
          Colors.green[700]!,
          Icons.local_offer,
        ),
      );
    }

    // Top Rated badge
    if (zone.rating != null && zone.rating! >= 4.5) {
      badges.add(
        _buildBadge(
          'Top Rated',
          Colors.amber[100]!,
          Colors.amber[900]!,
          Icons.star,
        ),
      );
    }

    // Dual License badge
    if (zone.dualLicense == true) {
      badges.add(
        _buildBadge(
          'Dual License',
          Colors.purple[100]!,
          Colors.purple[700]!,
          Icons.business,
        ),
      );
    }

    // Women Entrepreneur badge
    final womenEntrepreneur =
        zone.specialFeatures?['women_entrepreneur_offers'] != null;
    if (womenEntrepreneur) {
      badges.add(
        _buildBadge(
          'Women Entrepreneur',
          Colors.pink[100]!,
          Colors.pink[700]!,
          Icons.workspace_premium,
        ),
      );
    }

    return badges;
  }

  Widget _buildInfoChip(IconData icon, String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(
              fontSize: 13,
              color: color.withValues(alpha: 0.9),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  int _getMaxVisas() {
    try {
      final allocation = zone.visaAllocation;
      int maxVisas = 0;
      // Handle cases where values may not be ints (dynamic / num / null)
      for (final value in allocation.values) {
        final v = switch (value) {
          int i => i,
          num n => n.toInt(),
          _ => null,
        };
        if (v != null && v > maxVisas) {
          maxVisas = v;
        }
      }
      return maxVisas;
    } catch (e) {
      return 0;
    }
  }

  String _getEmirateDisplayName(String? emirate) {
    if (emirate == null || emirate.isEmpty) return 'UAE';
    final normalized = emirate.trim().toLowerCase().replaceAll(' ', '_');
    final map = {
      'abu_dhabi': 'Abu Dhabi',
      'dubai': 'Dubai',
      'sharjah': 'Sharjah',
      'ras_al_khaimah': 'RAK',
      'ajman': 'Ajman',
      'fujairah': 'Fujairah',
      'umm_al_quwain': 'UAQ',
    };
    return map[normalized] ?? emirate;
  }
}
