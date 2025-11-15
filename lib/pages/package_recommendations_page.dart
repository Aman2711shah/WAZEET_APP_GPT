import 'package:flutter/material.dart';
import '../models/freezone_package_recommendation.dart';

/// Screen that displays recommended freezone packages sorted by total cost
///
/// Shows a list of packages matching the user's requirements:
/// - Number of activities
/// - Visa requirements (investor, manager, employment)
/// - Office type preference
/// - Jurisdiction type (Freezone/Mainland)
class PackageRecommendationsPage extends StatelessWidget {
  final List<FreezonePackageRecommendation> packages;
  final int totalVisas;
  final int noOfActivities;

  const PackageRecommendationsPage({
    super.key,
    required this.packages,
    required this.totalVisas,
    required this.noOfActivities,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        title: const Text(
          'Package Recommendations',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
      ),
      body: packages.isEmpty ? _buildEmptyState() : _buildPackageList(),
    );
  }

  /// Show message when no packages match the criteria
  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 80, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              'No packages found',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Colors.grey.shade800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'We couldn\'t find any packages matching your requirements. Please try adjusting your selections.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade600, height: 1.4),
            ),
          ],
        ),
      ),
    );
  }

  /// Build the scrollable list of package recommendations
  Widget _buildPackageList() {
    return Column(
      children: [
        // 🔍 DEBUG: Show package count at the very top
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(6),
          color: Colors.yellow.shade100,
          child: Text(
            '🔍 DEBUG: Total packages received: ${packages.length}',
            textAlign: TextAlign.center,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
          ),
        ),
        // Header with summary
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF6D5DF6), Color(0xFF9B7BF7)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(16),
              bottomRight: Radius.circular(16),
            ),
          ),
          child: SafeArea(
            bottom: false,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${packages.length} Packages Found',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Sorted by total cost (cheapest first)',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    _buildInfoChip(
                      icon: Icons.business_center,
                      label: '$noOfActivities Activities',
                    ),
                    const SizedBox(width: 8),
                    _buildInfoChip(
                      icon: Icons.people,
                      label: '$totalVisas Visas',
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        // Package cards list
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: packages.length,
            itemBuilder: (context, index) {
              final package = packages[index];
              final isTopChoice = index == 0;
              return _PackageCard(
                package: package,
                index: index,
                isTopChoice: isTopChoice,
              );
            },
          ),
        ),
      ],
    );
  }

  /// Small chip for displaying requirements summary
  Widget _buildInfoChip({required IconData icon, required String label}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.white),
          const SizedBox(width: 5),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

/// Individual package card showing details and cost breakdown
class _PackageCard extends StatefulWidget {
  final FreezonePackageRecommendation package;
  final int index;
  final bool isTopChoice;

  const _PackageCard({
    required this.package,
    required this.index,
    required this.isTopChoice,
  });

  @override
  State<_PackageCard> createState() => _PackageCardState();
}

class _PackageCardState extends State<_PackageCard> {
  bool _showDetails = false;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      elevation: widget.isTopChoice ? 4 : 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: widget.isTopChoice
            ? const BorderSide(color: Color(0xFF6D5DF6), width: 2)
            : BorderSide.none,
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () => setState(() => _showDetails = !_showDetails),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with badge and freezone name
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Rank badge
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: widget.isTopChoice
                          ? const Color(0xFF6D5DF6)
                          : Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(7),
                    ),
                    child: Center(
                      child: Text(
                        '${widget.index + 1}',
                        style: TextStyle(
                          color: widget.isTopChoice
                              ? Colors.white
                              : Colors.grey.shade700,
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  // Freezone and product info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.package.freezone,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          widget.package.product,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Top choice badge
                  if (widget.isTopChoice)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF6D5DF6),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Text(
                        'BEST VALUE',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              // Total cost (prominent) - Using model's totalCost, NOT recalculated
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: widget.isTopChoice
                      ? const Color(0xFF6D5DF6).withOpacity(0.1)
                      : Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: widget.isTopChoice
                        ? const Color(0xFF6D5DF6).withOpacity(0.3)
                        : Colors.grey.shade200,
                    width: 2,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.account_balance_wallet,
                      color: widget.isTopChoice
                          ? const Color(0xFF6D5DF6)
                          : Colors.grey.shade600,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Total Package Cost',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey.shade600,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.3,
                            ),
                          ),
                          const SizedBox(height: 3),
                          // Display totalCost from model (already calculated in service)
                          Text(
                            'AED ${widget.package.totalCost.toStringAsFixed(2)}',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                              color: widget.isTopChoice
                                  ? const Color(0xFF6D5DF6)
                                  : Colors.grey.shade900,
                              letterSpacing: -0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      _showDetails
                          ? Icons.keyboard_arrow_up
                          : Icons.keyboard_arrow_down,
                      color: Colors.grey.shade600,
                      size: 20,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              // Quick info row
              Wrap(
                spacing: 8,
                runSpacing: 6,
                children: [
                  _buildInfoPill(
                    icon: Icons.work_outline,
                    label: '${widget.package.visaEligibility} Visa Quota',
                  ),
                  _buildInfoPill(
                    icon: Icons.business_center,
                    label: '${widget.package.activitiesAllowed} Activities',
                  ),
                  _buildInfoPill(
                    icon: Icons.location_on_outlined,
                    label: widget.package.jurisdiction,
                  ),
                ],
              ),
              // Expandable cost breakdown
              if (_showDetails) ...[
                const SizedBox(height: 12),
                const Divider(),
                const SizedBox(height: 10),
                Text(
                  'Cost Breakdown',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Colors.grey.shade800,
                  ),
                ),
                const SizedBox(height: 10),
                ...widget.package.costBreakdown.entries
                    .where((entry) => entry.value > 0)
                    .map((entry) => _buildCostRow(entry.key, entry.value)),
                const SizedBox(height: 6),
                const Divider(),
                _buildCostRow('TOTAL', widget.package.totalCost, isTotal: true),
              ],
            ],
          ),
        ),
      ),
    );
  }

  /// Small pill showing quick info
  Widget _buildInfoPill({required IconData icon, required String label}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: Colors.grey.shade700),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey.shade700,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  /// Row showing individual cost item
  Widget _buildCostRow(String label, double amount, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: isTotal ? 14 : 12,
                fontWeight: isTotal ? FontWeight.w700 : FontWeight.w500,
                color: isTotal ? Colors.grey.shade900 : Colors.grey.shade700,
              ),
            ),
          ),
          Text(
            'AED ${amount.round().toStringAsFixed(0)}',
            style: TextStyle(
              fontSize: isTotal ? 15 : 12,
              fontWeight: isTotal ? FontWeight.w700 : FontWeight.w600,
              color: isTotal ? const Color(0xFF6D5DF6) : Colors.grey.shade800,
            ),
          ),
        ],
      ),
    );
  }
}
