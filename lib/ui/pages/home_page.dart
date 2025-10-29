import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wazeet/company_setup_flow.dart';
import '../../providers/services_provider.dart';
import 'service_type_page.dart';
import '../widgets/gradient_header.dart';
import '../theme.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final serviceCategories = ref.watch(servicesProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          GradientHeader(
            title: 'Welcome Back! 👋',
            trailing: GestureDetector(
              onTap: () => _showProfileMessage(context),
              child: CircleAvatar(
                backgroundColor: Colors.white,
                child: Text(
                  'D',
                  style: TextStyle(
                    color: AppColors.purple,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
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
                          AppColors.purple.withOpacity(0.7),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.purple.withOpacity(0.3),
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
                              color: Colors.white.withOpacity(0.3),
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
                              color: Colors.white.withOpacity(0.3),
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
                      const Text(
                        'Quick Actions',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      TextButton(
                        onPressed: () {
                          // Navigate to services tab
                          DefaultTabController.of(context).animateTo(1);
                        },
                        child: Text(
                          'View All',
                          style: TextStyle(color: AppColors.purple),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
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
                        },
                      ),
                      _buildQuickActionCard(
                        context,
                        'Banking',
                        Icons.account_balance,
                        Colors.green,
                        () {
                          final bankingCategory = serviceCategories.firstWhere(
                            (cat) => cat.id == 'banking',
                          );
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  ServiceTypePage(category: bankingCategory),
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
                        },
                      ),
                      _buildQuickActionCard(
                        context,
                        'Accounting',
                        Icons.calculate,
                        Colors.teal,
                        () {
                          final accountingCategory = serviceCategories
                              .firstWhere((cat) => cat.id == 'accounting');
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  ServiceTypePage(category: accountingCategory),
                            ),
                          );
                        },
                      ),
                      _buildQuickActionCard(
                        context,
                        'PRO\nServices',
                        Icons.business_center,
                        Colors.pink,
                        () {
                          final proCategory = serviceCategories.firstWhere(
                            (cat) => cat.id == 'pro',
                          );
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  ServiceTypePage(category: proCategory),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Recent Activity
                  const Text(
                    'Recent Activity',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
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

                  // Tips & Insights
                  const Text(
                    'Tips & Insights',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 160,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        _buildTipCard(
                          '💼',
                          'Business Tip',
                          'Start your UAE business in 3 simple steps with WAZEET',
                          Colors.blue,
                        ),
                        _buildTipCard(
                          '📊',
                          'Tax Deadline',
                          'Corporate tax filing deadline: Dec 31, 2025',
                          Colors.orange,
                        ),
                        _buildTipCard(
                          '✨',
                          'Golden Visa',
                          'Eligible for Golden Visa? Check requirements now',
                          Colors.amber,
                        ),
                      ],
                    ),
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
                            color: AppColors.purple.withOpacity(0.1),
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
          style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 12),
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
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
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
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    color: color,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          if (progress < 1.0) ...[
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: progress,
                backgroundColor: Colors.grey.shade200,
                valueColor: AlwaysStoppedAnimation<Color>(color),
                minHeight: 6,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTipCard(
    String emoji,
    String title,
    String description,
    Color color,
  ) {
    return Container(
      width: 280,
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color.withOpacity(0.8), color],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 32)),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: TextStyle(
              color: Colors.white.withOpacity(0.95),
              fontSize: 13,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
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
