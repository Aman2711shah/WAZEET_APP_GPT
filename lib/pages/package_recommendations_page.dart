import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/freezone_package_recommendation.dart';
import '../ui/pages/applications_page.dart';

/// Screen that displays recommended freezone packages sorted by total cost
///
/// Shows a list of packages matching the user's requirements:
/// - Number of activities
/// - Visa requirements (investor, manager, employment)
/// - Office type preference
/// - Jurisdiction type (Freezone/Mainland)
class PackageRecommendationsPage extends StatefulWidget {
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
  State<PackageRecommendationsPage> createState() =>
      _PackageRecommendationsPageState();
}

class _PackageRecommendationsPageState
    extends State<PackageRecommendationsPage> {
  // Track which package the user has actively selected/highlighted.
  // Default to first (cheapest) package if any are available.
  int _selectedIndex = 0;

  void _handleSelect(int index) {
    if (_selectedIndex != index) {
      setState(() => _selectedIndex = index);
    }
  }

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
      body: widget.packages.isEmpty ? _buildEmptyState() : _buildPackageList(),
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
        // Header with summary
        Container(
          width: double.infinity,
          // Ultra compact header
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF6D5DF6), Color(0xFF9B7BF7)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(12),
              bottomRight: Radius.circular(12),
            ),
          ),
          child: SafeArea(
            bottom: false,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${widget.packages.length} Packages Found',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  'Sorted by total cost (cheapest first)',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontSize: 11,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    _buildInfoChip(
                      icon: Icons.business_center,
                      label: '${widget.noOfActivities} Activities',
                    ),
                    const SizedBox(width: 5),
                    _buildInfoChip(
                      icon: Icons.people,
                      label: '${widget.totalVisas} Visas',
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
            padding: const EdgeInsets.all(8),
            itemCount: widget.packages.length,
            itemBuilder: (context, index) {
              final package = widget.packages[index];
              // Selected card gets highlight styling regardless of rank.
              final isSelected = index == _selectedIndex;
              return _PackageCard(
                package: package,
                index: index,
                isSelected: isSelected,
                // Allow parent to know when user focuses a different package.
                onSelect: () => _handleSelect(index),
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
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: Colors.white),
          const SizedBox(width: 3),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 10,
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
  final bool isSelected; // Whether this card is currently selected/highlighted
  final VoidCallback onSelect; // Callback to notify parent of selection

  const _PackageCard({
    required this.package,
    required this.index,
    required this.isSelected,
    required this.onSelect,
  });

  @override
  State<_PackageCard> createState() => _PackageCardState();
}

class _PackageCardState extends State<_PackageCard> {
  bool _showDetails = false;

  /// Handle package selection and navigate to submission
  Future<void> _selectPackage(BuildContext context) async {
    // Check if user is authenticated
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please sign in to submit an application'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Package Selection'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'You are about to select:',
              style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
            ),
            const SizedBox(height: 8),
            Text(
              widget.package.freezone,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
            Text(
              widget.package.product,
              style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF6D5DF6).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Total Cost:',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  Text(
                    'AED ${widget.package.totalCost.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF6D5DF6),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'An application will be created and our team will contact you within 24 hours.',
              style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Confirm Selection'),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;

    // Show loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: Card(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Submitting your application...'),
              ],
            ),
          ),
        ),
      ),
    );

    try {
      // Create service request in Firestore
      final requestRef = await FirebaseFirestore.instance
          .collection('service_requests')
          .add({
            'serviceName': 'Company Formation',
            'serviceType':
                '${widget.package.freezone} - ${widget.package.product}',
            'tier': 'standard',
            'userId': user.uid,
            'userEmail': user.email ?? '',
            'userName': user.displayName ?? '',
            'status': 'pending',
            'createdAt': FieldValue.serverTimestamp(),
            'packageDetails': {
              'freezone': widget.package.freezone,
              'product': widget.package.product,
              'jurisdiction': widget.package.jurisdiction,
              'totalCost': widget.package.totalCost,
              'visaEligibility': widget.package.visaEligibility,
              'activitiesAllowed': widget.package.activitiesAllowed,
              'costBreakdown': widget.package.costBreakdown,
            },
            'documents': {},
            'details': 'Company setup application via package selection',
          });

      if (!context.mounted) return;

      // Close loading dialog
      Navigator.of(context).pop();

      // Show success and navigate
      await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          icon: const Icon(Icons.check_circle, color: Colors.green, size: 64),
          title: const Text('Application Submitted!'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Your application has been submitted successfully.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey.shade700),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    Text(
                      'Request ID',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      requestRef.id,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Our team will review your application and contact you within 24 hours.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop(); // Go back to setup flow
              },
              child: const Text('Close'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop(); // Go back to setup flow
                // Navigate to applications page
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) =>
                        ApplicationsPage(initialId: requestRef.id),
                  ),
                );
              },
              child: const Text('Track Application'),
            ),
          ],
        ),
      );
    } catch (e) {
      if (!context.mounted) return;

      // Close loading dialog
      Navigator.of(context).pop();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error submitting application: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 6),
      elevation: widget.isSelected ? 3 : 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: widget.isSelected
            ? const BorderSide(color: Color(0xFF6D5DF6), width: 2)
            : BorderSide.none,
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: () {
          widget.onSelect();
          setState(() => _showDetails = !_showDetails);
        },
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with badge and freezone name
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Rank badge
                  Container(
                    width: 22,
                    height: 22,
                    decoration: BoxDecoration(
                      color: widget.isSelected
                          ? const Color(0xFF6D5DF6)
                          : Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Center(
                      child: Text(
                        '${widget.index + 1}',
                        style: TextStyle(
                          color: widget.isSelected
                              ? Colors.white
                              : Colors.grey.shade700,
                          fontWeight: FontWeight.w700,
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 7),
                  // Freezone and product info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.package.freezone,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 1),
                        Text(
                          widget.package.product,
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Top choice badge
                  if (widget.isSelected)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 5,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF6D5DF6),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'BEST VALUE',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 8,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.4,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              // Total cost (prominent) - Using model's totalCost, NOT recalculated
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: widget.isSelected
                      ? const Color(0xFF6D5DF6).withValues(alpha: 0.1)
                      : Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(7),
                  border: Border.all(
                    color: widget.isSelected
                        ? const Color(0xFF6D5DF6).withValues(alpha: 0.3)
                        : Colors.grey.shade200,
                    width: 2,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.account_balance_wallet,
                      color: widget.isSelected
                          ? const Color(0xFF6D5DF6)
                          : Colors.grey.shade600,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Total Package Cost',
                            style: TextStyle(
                              fontSize: 9,
                              color: Colors.grey.shade600,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.2,
                            ),
                          ),
                          const SizedBox(height: 1),
                          // Display totalCost from model (already calculated in service)
                          Text(
                            'AED ${widget.package.totalCost.toStringAsFixed(2)}',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: widget.isSelected
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
                      size: 16,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 6),
              // Quick info row
              Wrap(
                spacing: 5,
                runSpacing: 4,
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
              // Select Package Button
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _selectPackage(context),
                  icon: const Icon(Icons.check_circle_outline, size: 16),
                  label: const Text(
                    'Select This Package',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: widget.isSelected
                        ? const Color(0xFF6D5DF6)
                        : Colors.grey.shade700,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              // Expandable cost breakdown
              if (_showDetails) ...[
                const SizedBox(height: 8),
                const Divider(),
                const SizedBox(height: 6),
                Text(
                  'Cost Breakdown',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Colors.grey.shade800,
                  ),
                ),
                const SizedBox(height: 6),
                ...widget.package.costBreakdown.entries
                    .where((entry) => entry.value > 0)
                    .map((entry) => _buildCostRow(entry.key, entry.value)),
                const SizedBox(height: 3),
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
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 3),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 10, color: Colors.grey.shade700),
          const SizedBox(width: 3),
          Text(
            label,
            style: TextStyle(
              fontSize: 9,
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
      padding: const EdgeInsets.symmetric(vertical: 1.5),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: isTotal ? 12 : 10,
                fontWeight: isTotal ? FontWeight.w700 : FontWeight.w500,
                color: isTotal ? Colors.grey.shade900 : Colors.grey.shade700,
              ),
            ),
          ),
          Text(
            'AED ${amount.round().toStringAsFixed(0)}',
            style: TextStyle(
              fontSize: isTotal ? 13 : 10,
              fontWeight: isTotal ? FontWeight.w700 : FontWeight.w600,
              color: isTotal ? const Color(0xFF6D5DF6) : Colors.grey.shade800,
            ),
          ),
        ],
      ),
    );
  }
}
