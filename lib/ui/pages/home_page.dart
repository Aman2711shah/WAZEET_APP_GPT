import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wazeet/company_setup_flow.dart';
import '../../providers/services_provider.dart';
import 'service_type_page.dart';
import 'freezone_selection_page.dart';
import 'freezone_browser_page.dart';
import 'freezone_investment_map_page.dart';
import '../theme.dart';

class HomePage extends ConsumerWidget {
  final Function(int)? onNavigateToTab;

  const HomePage({super.key, this.onNavigateToTab});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final serviceCategories = ref.watch(servicesProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 320,
            pinned: true,
            floating: false,
            backgroundColor: AppColors.purple,
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 12),
                child: GestureDetector(
                  onTap: () => _showProfileMessage(context),
                  child: CircleAvatar(
                    radius: 20,
                    backgroundColor: Colors.white,
                    child: Text(
                      'D',
                      style: TextStyle(
                        fontSize: 18,
                        color: AppColors.purple,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              title: const Text(
                '✨ WAZEET',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  shadows: [Shadow(color: Colors.black38, blurRadius: 8)],
                ),
              ),
              background: Stack(
                fit: StackFit.expand,
                children: [
                  // Gradient background instead of image
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          const Color(0xFF6200EE),
                          const Color(0xFF9D4EDD),
                          const Color(0xFFE0AAFF),
                        ],
                      ),
                    ),
                  ),
                  // Decorative circles
                  Positioned(
                    top: -50,
                    right: -50,
                    child: Container(
                      width: 200,
                      height: 200,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withValues(alpha: 0.1),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: -80,
                    left: -80,
                    child: Container(
                      width: 250,
                      height: 250,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withValues(alpha: 0.08),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 100,
                    left: 30,
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withValues(alpha: 0.12),
                      ),
                    ),
                  ),
                  // Content overlay
                  Positioned(
                    left: 20,
                    right: 20,
                    bottom: 70,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Welcome Back! 👋',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            height: 1.2,
                            shadows: [
                              Shadow(
                                color: Colors.black.withValues(alpha: 0.3),
                                blurRadius: 10,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.3),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.rocket_launch,
                                color: Colors.white,
                                size: 18,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Your Business Journey Starts Here',
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.95),
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.3,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Quick Stats Card
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.purple,
                          AppColors.purple.withValues(alpha: 0.7),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.purple.withValues(alpha: 0.3),
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Your Business Journey',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: _buildStatItem(
                                '3',
                                'Active Services',
                                Icons.check_circle,
                              ),
                            ),
                            Container(
                              width: 1,
                              height: 40,
                              color: Colors.white.withValues(alpha: 0.3),
                            ),
                            Expanded(
                              child: _buildStatItem(
                                '5',
                                'Pending Tasks',
                                Icons.pending_actions,
                              ),
                            ),
                            Container(
                              width: 1,
                              height: 40,
                              color: Colors.white.withValues(alpha: 0.3),
                            ),
                            Expanded(
                              child: _buildStatItem(
                                '12',
                                'Documents',
                                Icons.description,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Quick Actions
                  Row(
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  AppColors.purple.withValues(alpha: 0.15),
                                  AppColors.purple.withValues(alpha: 0.05),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              Icons.flash_on,
                              color: AppColors.purple,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 10),
                          const Text(
                            'Quick Actions',
                            style: TextStyle(
                              fontSize: 19,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppColors.purple.withValues(alpha: 0.1),
                              AppColors.purple.withValues(alpha: 0.05),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: TextButton.icon(
                          onPressed: () {
                            // Navigate to services tab (index 1)
                            onNavigateToTab?.call(1);
                          },
                          icon: Icon(
                            Icons.arrow_forward,
                            color: AppColors.purple,
                            size: 16,
                          ),
                          label: Text(
                            'View All',
                            style: TextStyle(
                              color: AppColors.purple,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 3,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 0.95,
                    children: [
                      _buildQuickActionCard(
                        context,
                        'Company\nSetup',
                        Icons.apartment,
                        Colors.orange,
                        () => _openCompanySetupModal(context),
                      ),
                      _buildQuickActionCard(
                        context,
                        'Visa\nServices',
                        Icons.card_travel,
                        Colors.blue,
                        () {
                          try {
                            final visaCategory = serviceCategories.firstWhere(
                              (cat) => cat.id == 'visa',
                            );
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    ServiceTypePage(category: visaCategory),
                              ),
                            );
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Service category not available'),
                              ),
                            );
                          }
                        },
                      ),
                      _buildQuickActionCard(
                        context,
                        'Find Your\nFree Zone',
                        Icons.explore,
                        AppColors.purple,
                        () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const FreezoneBrowserPage(),
                            ),
                          );
                        },
                      ),
                      _buildQuickActionCard(
                        context,
                        'Tax\nServices',
                        Icons.receipt_long,
                        Colors.deepPurple,
                        () {
                          try {
                            final taxCategory = serviceCategories.firstWhere(
                              (cat) => cat.id == 'tax',
                            );
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    ServiceTypePage(category: taxCategory),
                              ),
                            );
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Service category not available'),
                              ),
                            );
                          }
                        },
                      ),
                      _buildQuickActionCard(
                        context,
                        'Accounting',
                        Icons.calculate,
                        Colors.teal,
                        () {
                          try {
                            final accountingCategory = serviceCategories
                                .firstWhere((cat) => cat.id == 'accounting');
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    ServiceTypePage(category: accountingCategory),
                              ),
                            );
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Service category not available'),
                              ),
                            );
                          }
                        },
                      ),
                      _buildQuickActionCard(
                        context,
                        'Freezone\nFinder',
                        Icons.location_city,
                        Colors.pink,
                        () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  const FreezoneSelectionPage(),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),

                  // Tips & Insights
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.amber.withValues(alpha: 0.2),
                              Colors.amber.withValues(alpha: 0.08),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.lightbulb,
                          color: Colors.amber,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 10),
                      const Text(
                        'Tips & Insights',
                        style: TextStyle(
                          fontSize: 19,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 160,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        _buildAskAdvisorCard(context),
                        _buildTipCard(
                          '�️',
                          'Investment Map',
                          'Anchor tenants & revenue proxies across UAE free zones',
                          Colors.deepPurple,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const FreezoneInvestmentMapPage(),
                              ),
                            );
                          },
                        ),
                        _buildTipCard(
                          '�💼',
                          'Corporate Tax',
                          'UAE Corporate Tax rate: 9% for taxable income above AED 375,000',
                          Colors.blue,
                          onTap: () => _openCorporateTaxInfo(context),
                        ),
                        _buildTipCard(
                          '📊',
                          'Tax Deadline',
                          'Corporate tax filing deadline: Dec 31, 2025',
                          Colors.orange,
                          onTap: () => _openCorporateTaxDeadlineInfo(context),
                        ),
                        _buildTipCard(
                          '✨',
                          'Golden Visa',
                          'Eligible for Golden Visa? Check requirements now',
                          Colors.amber,
                          onTap: () => _openGoldenVisaInfo(context),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 28),

                  // Recent Activity
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.blue.withValues(alpha: 0.15),
                              Colors.blue.withValues(alpha: 0.05),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.history,
                          color: Colors.blue,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 10),
                      const Text(
                        'Recent Activity',
                        style: TextStyle(
                          fontSize: 19,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildActivityCard(
                    'Employment Visa Renewal',
                    'In Progress',
                    'Expected completion: 3 days',
                    Icons.card_travel,
                    Colors.blue,
                    0.7,
                  ),
                  _buildActivityCard(
                    'VAT Registration',
                    'Documents Required',
                    '2 documents pending',
                    Icons.receipt_long,
                    Colors.orange,
                    0.3,
                  ),
                  _buildActivityCard(
                    'Trade License Renewal',
                    'Completed',
                    'Completed on Oct 25, 2025',
                    Icons.check_circle,
                    Colors.green,
                    1.0,
                  ),
                  const SizedBox(height: 24),

                  // Help & Support
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.purple.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.support_agent,
                            color: AppColors.purple,
                            size: 28,
                          ),
                        ),
                        const SizedBox(width: 16),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Need Help?',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Our support team is here 24/7',
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Contact: support@wazeet.com'),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.purple,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text('Contact'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Find Your Free Zone entry card (replacing AI Advisor button)
  Widget _buildAskAdvisorCard(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const FreezoneBrowserPage()),
        );
      },
      borderRadius: BorderRadius.circular(18),
      child: Container(
        width: 290,
        height: 140,
        margin: const EdgeInsets.only(right: 14),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.purple,
              AppColors.purple.withValues(alpha: 0.85),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: AppColors.purple.withValues(alpha: 0.35),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.explore, color: Colors.white),
              ),
              const SizedBox(height: 8),
              const Text(
                'Find Your Free Zone',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Browse by Emirate or Industry, filter, sort, and compare zones in real time.',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.95),
                  fontSize: 12.5,
                  height: 1.35,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // (AI Advisor dialog removed as the entry is now the Free Zone browser)

  Widget _buildStatItem(String value, String label, IconData icon) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(width: 6),
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.9),
            fontSize: 12,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildQuickActionCard(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.white, color.withValues(alpha: 0.02)],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.15), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.1),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    color.withValues(alpha: 0.15),
                    color.withValues(alpha: 0.08),
                  ],
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: color.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(icon, color: color, size: 30),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.2,
                ),
                maxLines: 2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityCard(
    String title,
    String status,
    String subtitle,
    IconData icon,
    Color color,
    double progress,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.white, color.withValues(alpha: 0.02)],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.2), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.08),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          color.withValues(alpha: 0.15),
                          color.withValues(alpha: 0.08),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: color.withValues(alpha: 0.2),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Icon(icon, color: color, size: 24),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15.5,
                            letterSpacing: 0.2,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          subtitle,
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 12.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          color.withValues(alpha: 0.15),
                          color.withValues(alpha: 0.1),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: color.withValues(alpha: 0.3),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      status,
                      style: TextStyle(
                        color: color,
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (progress < 1.0)
              Container(
                height: 6,
                decoration: BoxDecoration(color: Colors.grey.shade100),
                child: FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: progress,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [color, color.withValues(alpha: 0.7)],
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTipCard(
    String emoji,
    String title,
    String description,
    Color color, {
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: 290,
        height: 140, // Fix: ensure consistent height to avoid overflow
        margin: const EdgeInsets.only(right: 14),
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [color.withValues(alpha: 0.85), color],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.35),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Decorative circle
            Positioned(
              top: -20,
              right: -20,
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.1),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(emoji, style: const TextStyle(fontSize: 22)),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.3,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Flexible(
                    child: Text(
                      description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.95),
                        fontSize: 13,
                        height: 1.3,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openCorporateTaxInfo(BuildContext context) async {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (_) => FractionallySizedBox(
        heightFactor: 0.95,
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          child: Material(
            color: Colors.white,
            child: SafeArea(
              top: false,
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.blue.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.business_center,
                            color: Colors.blue,
                            size: 28,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Text(
                            'UAE Corporate Tax Overview 2025',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close_rounded),
                          onPressed: () => Navigator.of(context).maybePop(),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),

                    // Tags
                    Row(
                      children: [
                        _chip('Federal Decree-Law 47/2022', Colors.blue),
                        const SizedBox(width: 8),
                        _chip('Effective: 1 June 2023', Colors.teal),
                      ],
                    ),

                    const SizedBox(height: 16),
                    _sectionTitle('Legislative Basis'),
                    _bodyText(
                      'Federal Decree-Law No. 47 of 2022 on the Taxation of Corporations and Businesses. Effective from 1 June 2023, applicable to all Emirates under the Federal Tax Authority (FTA). For calendar-year businesses, the regime applies from 1 January 2024 onwards.',
                    ),

                    const SizedBox(height: 14),
                    _sectionTitle('Scope & Taxable Persons'),
                    _bullets([
                      'Resident Entities: UAE-resident juridical persons (companies incorporated or effectively managed in the UAE)',
                      'Non-Resident Entities: Entities with a permanent establishment (PE) or UAE-sourced income',
                      'Individuals: Taxable only if business activities exceed AED 1 million annual turnover',
                    ]),

                    const SizedBox(height: 14),
                    _sectionTitle('Tax Rates & Thresholds'),
                    _buildRateCard(
                      '0%',
                      'Taxable income up to AED 375,000',
                      Colors.green,
                    ),
                    const SizedBox(height: 8),
                    _buildRateCard(
                      '9%',
                      'Taxable income exceeding AED 375,000',
                      Colors.orange,
                    ),
                    const SizedBox(height: 8),
                    _buildRateCard(
                      '15%',
                      'Minimum top-up tax (from 2025) for multinational groups with global revenues ≥ €750M (OECD Pillar Two)',
                      Colors.red,
                    ),

                    const SizedBox(height: 14),
                    _sectionTitle('Free Zones & QFZP'),
                    _bodyText(
                      'Free-zone entities must register for corporate tax even if expecting 0% rate. Eligibility for 0% requires:',
                    ),
                    const SizedBox(height: 6),
                    _bullets([
                      'Earns qualifying income (from transactions with other free-zone entities or foreign customers)',
                      'Maintains sufficient economic substance in the UAE',
                      'Complies with transfer-pricing and audit requirements',
                    ]),
                    const SizedBox(height: 6),
                    _bodyText(
                      'Non-qualifying income (e.g., from UAE mainland customers) is taxed at 9%. Reference: Cabinet Decision No. 55 of 2023.',
                    ),

                    const SizedBox(height: 14),
                    _sectionTitle('Registration, Filing & Compliance'),
                    _bullets([
                      'All taxable persons must register with the FTA and obtain a Tax Registration Number (TRN)',
                      'Filing Deadline: Within 9 months of the end of each financial year',
                      'Record Retention: Minimum 7 years',
                      'Audit Requirement: Mandatory for Qualifying Free Zone Persons and entities above specified thresholds',
                    ]),

                    const SizedBox(height: 14),
                    _sectionTitle('Exemptions & Special Rules'),
                    _bullets([
                      'Extractive Industries: Remain outside the federal regime; taxed at the Emirate level',
                      'Participation Exemption: Dividend and capital-gain exemptions under qualifying shareholding criteria',
                      'Other Exempt Entities: Government entities, pension funds, and approved public benefit organisations',
                    ]),

                    const SizedBox(height: 14),
                    _sectionTitle('Penalties & Non-Compliance'),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.red.shade200),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.warning_amber_rounded,
                                color: Colors.red.shade700,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Consequences',
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  color: Colors.red.shade700,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          _bullets([
                            'Administrative penalties for failure to register, file, or maintain records',
                            'Loss of QFZP status → retrospective 9% tax liability',
                          ]),
                          const SizedBox(height: 6),
                          Text(
                            'Key Message: Timely submission and accurate reporting are essential to retain tax incentives',
                            style: TextStyle(
                              color: Colors.red.shade800,
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 14),
                    _sectionTitle('Practical Implications'),
                    _bullets([
                      'Exports: Qualify for 0% rate if QFZP conditions met',
                      'Mainland Trading: Subject to 9% tax on profits',
                      'Requirements: Ensure adequate economic substance (office, staff, operations)',
                      'Maintain audited accounts and transfer-pricing documentation for FTA inspection',
                    ]),

                    const SizedBox(height: 14),
                    _sectionTitle('Key Takeaways'),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.green.shade200),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.check_circle,
                                color: Colors.green.shade700,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Competitive & Aligned',
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  color: Colors.green.shade700,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          _bullets([
                            'UAE\'s Corporate Tax regime is competitive and aligned with global standards',
                            'Most SMEs in Free Zones can achieve 0% effective tax with proper planning and substance',
                            'Businesses should review financial structures and consult qualified advisors under Federal Decree-Law No. 47 of 2022',
                          ]),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),
                    _sectionTitle('Resources'),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: [
                        _primaryButton(
                          'Visit FTA Portal',
                          () => _openUrl(context, 'https://tax.gov.ae'),
                        ),
                        _secondaryButton(
                          'EmaraTax Login',
                          () =>
                              _openUrl(context, 'https://eservices.tax.gov.ae'),
                        ),
                        _secondaryButton(
                          'Download PDF Guide',
                          () => _openUrl(
                            context,
                            '${Uri.base.origin}/assets/docs/UAE_Corporate_Tax_Overview_2025.pdf',
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 28),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRateCard(String rate, String description, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              rate,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: 16,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              description,
              style: const TextStyle(
                fontSize: 13,
                height: 1.4,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _openGoldenVisaInfo(BuildContext context) async {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (_) => FractionallySizedBox(
        heightFactor: 0.95,
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          child: Material(
            color: Colors.white,
            child: SafeArea(
              top: false,
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.amber.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.stars_rounded,
                            color: Colors.amber,
                            size: 28,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Text(
                            'UAE Golden Visa 2025',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close_rounded),
                          onPressed: () => Navigator.of(context).maybePop(),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),

                    // Tags
                    Row(
                      children: [
                        _chip('5 or 10 Years', Colors.amber),
                        const SizedBox(width: 8),
                        _chip('Renewable', Colors.green),
                      ],
                    ),

                    const SizedBox(height: 16),
                    _sectionTitle('What is Golden Visa?'),
                    _bodyText(
                      'A long-term residence visa in the United Arab Emirates that allows eligible foreigners to live, work, or study in the UAE without the need for a local sponsor. Valid for 5 or 10 years and automatically renewable if eligibility conditions remain satisfied.',
                    ),

                    const SizedBox(height: 14),
                    _sectionTitle('Purpose'),
                    _bodyText(
                      'To attract investors, entrepreneurs, professionals, researchers, and outstanding students to contribute to UAE\'s economic growth and innovation.',
                    ),

                    const SizedBox(height: 14),
                    _sectionTitle('Eligible Categories'),

                    _buildCategoryCard(
                      'Investors',
                      'Investment of at least AED 2 million in UAE public investment or business capital',
                      'Can include property investment; capital must not be loaned; full ownership required',
                      Icons.account_balance,
                      Colors.blue,
                    ),
                    const SizedBox(height: 8),

                    _buildCategoryCard(
                      'Real Estate Investors',
                      'Property ownership worth at least AED 2 million',
                      'Can include mortgaged property if 50% or more value is paid',
                      Icons.home_work,
                      Colors.indigo,
                    ),
                    const SizedBox(height: 8),

                    _buildCategoryCard(
                      'Entrepreneurs',
                      'Existing business or startup with capital ≥ AED 500,000 or approved innovative project',
                      'Accredited by UAE business incubators or local authorities',
                      Icons.business_center,
                      Colors.purple,
                    ),
                    const SizedBox(height: 8),

                    _buildCategoryCard(
                      'Skilled Professionals',
                      'Bachelor\'s degree or higher + valid UAE work contract',
                      'Min. AED 30,000/month salary. Fields: Medicine, Engineering, IT, Business, Education, Law, Culture',
                      Icons.work,
                      Colors.teal,
                    ),
                    const SizedBox(height: 8),

                    _buildCategoryCard(
                      'Exceptional Talents',
                      'Recognition in art, culture, sport, or science by UAE authorities',
                      'Evidence: Awards, patents, or published research work',
                      Icons.emoji_events,
                      Colors.orange,
                    ),
                    const SizedBox(height: 8),

                    _buildCategoryCard(
                      'Outstanding Students',
                      'High academic performance (e.g., GPA ≥ 3.8 or equivalent)',
                      'From recognized UAE universities or top global universities',
                      Icons.school,
                      Colors.pink,
                    ),

                    const SizedBox(height: 14),
                    _sectionTitle('Key Benefits'),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.green.shade200),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.check_circle,
                                color: Colors.green.shade700,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Golden Visa Advantages',
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  color: Colors.green.shade700,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          _bullets([
                            '5 or 10-year residency with renewal',
                            'No need for employer or local sponsor',
                            'Spouse, children (of any age), and domestic workers included',
                            'Freedom to start or own businesses in UAE',
                            'Multiple entry visa for initial 6 months for setup',
                            'No personal income tax on residents',
                          ]),
                        ],
                      ),
                    ),

                    const SizedBox(height: 14),
                    _sectionTitle('Application Process'),
                    _bodyText(
                      'Apply through Federal Authority for Identity, Citizenship, Customs & Port Security (ICP) or Dubai GDRFA.',
                    ),
                    const SizedBox(height: 6),
                    _bullets([
                      'Verify eligibility based on category',
                      'Submit documents (passport, visa, investment proof, etc.)',
                      'Pay applicable fees',
                      'Undergo background and medical checks',
                      'Receive approval and Emirates ID',
                    ]),
                    const SizedBox(height: 6),
                    _bodyText(
                      'Processing Time: 2 to 6 weeks depending on category',
                    ),

                    const SizedBox(height: 14),
                    _sectionTitle('Important Notes'),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade50,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.orange.shade200),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.info_outline,
                                color: Colors.orange.shade700,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Key Requirements',
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  color: Colors.orange.shade700,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          _bullets([
                            'Investments must be personal funds, not loans',
                            'Government updates thresholds periodically',
                            'Continuous eligibility must be proven at renewal',
                            'Only apply through official portals (ICP or GDRFA)',
                          ]),
                        ],
                      ),
                    ),

                    const SizedBox(height: 14),
                    _sectionTitle('Risks & Warnings'),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.red.shade200),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.warning_amber_rounded,
                                color: Colors.red.shade700,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Beware of Scams',
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  color: Colors.red.shade700,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          _bullets([
                            'Beware of unauthorized agents offering \'lifetime\' visas for small fees',
                            'Only apply through official portals (ICP or GDRFA)',
                            'False documentation or misrepresentation can lead to rejection or penalties',
                          ]),
                        ],
                      ),
                    ),

                    const SizedBox(height: 14),
                    _sectionTitle('For Business Owners'),
                    _bodyText(
                      'Ideal for UAE free-zone company owners, investors, and entrepreneurs.',
                    ),
                    const SizedBox(height: 6),
                    _bullets([
                      'Freedom to operate business across UAE',
                      'Residence security for long-term planning',
                      'Ease of banking, property purchase, and family relocation',
                    ]),

                    const SizedBox(height: 16),
                    _sectionTitle('Official Resources'),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: [
                        _primaryButton(
                          'ICP Portal',
                          () => _openUrl(
                            context,
                            'https://icp.gov.ae/en/golden-residency/',
                          ),
                        ),
                        _secondaryButton(
                          'Dubai GDRFA',
                          () => _openUrl(context, 'https://www.gdrfad.gov.ae/'),
                        ),
                        _secondaryButton(
                          'UAE Updates',
                          () => _openUrl(
                            context,
                            'https://www.thenationalnews.com/uae/2025/10/23/uae-golden-visa-updates/',
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 28),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryCard(
    String title,
    String requirement,
    String notes,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w700,
                    color: color,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  requirement,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  notes,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _openCorporateTaxDeadlineInfo(BuildContext context) async {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (_) => FractionallySizedBox(
        heightFactor: 0.94,
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          child: Material(
            color: Colors.white,
            child: SafeArea(
              top: false,
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.orange.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.bar_chart,
                            color: Colors.orange,
                            size: 28,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Text(
                            'Corporate Tax Filing Deadline',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close_rounded),
                          onPressed: () => Navigator.of(context).maybePop(),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),

                    // Deadline chip
                    Row(
                      children: [
                        _chip('Deadline: Dec 31, 2025', Colors.orange),
                        const SizedBox(width: 8),
                        _chip('Rule: File within 9 months', Colors.deepOrange),
                      ],
                    ),

                    const SizedBox(height: 16),

                    _sectionTitle('Summary'),
                    _bodyText(
                      'The Dec 31, 2025 filing deadline applies to companies whose first tax period ends on March 31, 2025. Businesses must file and pay corporate tax within nine months after the financial year-end through the EmaraTax portal to avoid penalties.',
                    ),

                    const SizedBox(height: 14),
                    _sectionTitle('Applicable To'),
                    _bodyText(
                      'Businesses in the UAE with a financial year ending on March 31, 2025 (nine months filing window).',
                    ),

                    const SizedBox(height: 14),
                    _sectionTitle('Filing Rule'),
                    _bullets([
                      'Corporate Tax Return must be filed within nine (9) months from the end of the relevant financial year.',
                      'Example: Financial year end Mar 31, 2025 → Return due Dec 31, 2025.',
                    ]),

                    const SizedBox(height: 14),
                    _sectionTitle('Penalties for Late Filing'),
                    _bullets([
                      'FTA notice: Late submission or payment may attract administrative penalties.',
                      'Estimated penalties: AED 500/month for first 12 months; AED 1,000/month thereafter.',
                      'Risk: Loss of Qualifying Free Zone Person (QFZP) status and retroactive 9% taxation.',
                    ]),

                    const SizedBox(height: 14),
                    _sectionTitle('Compliance Checklist'),
                    _bullets([
                      'Confirm financial year-end and tax period in EmaraTax.',
                      'Ensure registration for Corporate Tax (even for 0% entities).',
                      'Prepare audited financial statements (if applicable).',
                      'Classify qualifying vs non-qualifying income for free zone entities.',
                      'Maintain records for a minimum of 7 years.',
                      'Settle tax payment before due date to avoid transfer delays.',
                    ]),

                    const SizedBox(height: 14),
                    _sectionTitle('Implications'),
                    _bullets([
                      'Free Zone entities: Must file return even if enjoying 0% tax; missing deadlines risks losing preferential status.',
                      'Mainland companies: 9% corporate tax applies above AED 375,000 profit threshold.',
                      'Multinationals: 15% minimum top-up tax applies for global revenue above €750M from 2025.',
                    ]),

                    const SizedBox(height: 16),
                    _sectionTitle('FTA Contact'),
                    _contactTile(
                      context,
                      Icons.call,
                      'Hotline (UAE): 80082923',
                      'tel:80082923',
                    ),
                    _contactTile(
                      context,
                      Icons.call,
                      'Hotline (Intl): +971 600 599 994',
                      'tel:+971600599994',
                    ),
                    _contactTile(
                      context,
                      Icons.email_outlined,
                      'info@tax.gov.ae',
                      'mailto:info@tax.gov.ae',
                    ),

                    const SizedBox(height: 16),
                    _sectionTitle('Resources'),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: [
                        _primaryButton(
                          'Open FTA Guideline',
                          () => _openUrl(
                            context,
                            'https://tax.gov.ae/en/media.centre/news/federal.tax.authority.urges.submission.of.corporate.tax.returns.and.settlement.of.corporate.tax.liabilities.within.nine.months.from.the.end.of.the.tax.period.aspx',
                          ),
                        ),
                        _secondaryButton(
                          'Open EmaraTax Portal',
                          () =>
                              _openUrl(context, 'https://eservices.tax.gov.ae'),
                        ),
                        _secondaryButton(
                          'Download Overview PDF',
                          () => _openUrl(
                            context,
                            '${Uri.base.origin}/assets/docs/UAE_Corporate_Tax_Overview_2025.pdf',
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 28),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // UI helpers
  Widget _chip(String label, Color base) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
    decoration: BoxDecoration(
      color: base.withValues(alpha: 0.12),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: base.withValues(alpha: 0.2)),
    ),
    child: Text(
      label,
      style: TextStyle(
        color: (base is MaterialColor ? base.shade700 : base),
        fontWeight: FontWeight.w600,
        fontSize: 12.5,
      ),
    ),
  );

  Widget _sectionTitle(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 4),
    child: Text(
      text,
      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
    ),
  );

  Widget _bodyText(String text) => Text(
    text,
    style: const TextStyle(color: Colors.black87, height: 1.4, fontSize: 13.5),
  );

  Widget _bullets(List<String> items) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      for (final i in items)
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 3),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('•  ', style: TextStyle(height: 1.4)),
              Expanded(child: _bodyText(i)),
            ],
          ),
        ),
    ],
  );

  Widget _contactTile(
    BuildContext ctx,
    IconData icon,
    String text,
    String link,
  ) => ListTile(
    contentPadding: EdgeInsets.zero,
    leading: CircleAvatar(
      radius: 18,
      backgroundColor: Colors.orange.withValues(alpha: 0.12),
      child: Icon(icon, color: Colors.orange),
    ),
    title: Text(
      text,
      style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w600),
    ),
    onTap: () => _openUrl(ctx, link),
  );

  Widget _primaryButton(String label, VoidCallback onPressed) =>
      ElevatedButton.icon(
        onPressed: onPressed,
        icon: const Icon(Icons.open_in_new_rounded),
        label: Text(label),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.orange,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );

  Widget _secondaryButton(String label, VoidCallback onPressed) =>
      OutlinedButton.icon(
        onPressed: onPressed,
        icon: const Icon(Icons.link_rounded),
        label: Text(label),
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.orange.shade700,
          side: BorderSide(color: Colors.orange.shade200),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );

  Future<void> _openUrl(BuildContext ctx, String url) async {
    final uri = Uri.parse(url);
    final ok = await launchUrl(uri, webOnlyWindowName: '_blank');
    if (!ok && ctx.mounted) {
      ScaffoldMessenger.of(
        ctx,
      ).showSnackBar(SnackBar(content: Text('Could not open: $url')));
    }
  }

  void _showProfileMessage(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Tap "More" in the bottom navigation to access your profile settings',
        ),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _openCompanySetupModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (_) => FractionallySizedBox(
        heightFactor: 0.96,
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          child: Material(
            color: Colors.white,
            child: const ProviderScope(child: CompanySetupFlow()),
          ),
        ),
      ),
    );
  }
}
