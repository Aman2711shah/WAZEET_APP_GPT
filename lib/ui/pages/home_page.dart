import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wazeet/company_setup_flow.dart';
import '../../providers/services_provider.dart';
import '../../providers/user_profile_provider.dart';
import '../../providers/user_activity_provider.dart';
import 'service_type_page.dart';
import 'freezone_browser_page.dart';
import 'freezone_investment_map_page.dart';
import 'ai_business_chat_page.dart';
import 'edit_profile_page.dart';
import '../widgets/hero/hero_header.dart';
import '../theme.dart';
import '../animations/page_transitions.dart';
import '../../features/tax_calculator/ai_tax_calculator_screen.dart';

class HomePage extends ConsumerWidget {
  final Function(int)? onNavigateToTab;

  const HomePage({super.key, this.onNavigateToTab});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final serviceCategories = ref.watch(servicesProvider);
    final profile = ref.watch(userProfileProvider);
    final userActivities = ref.watch(userActivityProvider);
    final userName = profile?.name ?? 'User';

    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 220,
            pinned: true,
            floating: false,
            backgroundColor: scheme.primary,
            actions: [
              // Profile icon in top right corner
              Padding(
                padding: EdgeInsets.only(right: AppSpacing.md),
                child: GestureDetector(
                  onTap: () {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (context.mounted) {
                        context.pushWithSlide(const EditProfilePage());
                      }
                    });
                  },
                  child: CircleAvatar(
                    radius: 20,
                    backgroundColor: Colors.white,
                    child: Text(
                      userName.isNotEmpty ? userName[0].toUpperCase() : 'U',
                      style: TextStyle(
                        fontSize: 18,
                        color: scheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  // Gradient background
                  Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Color(0xFF6D28D9),
                          Color(0xFF7C3AED),
                          Color.fromARGB(255, 134, 111, 206),
                        ],
                      ),
                    ),
                  ),
                  // Upper soft glow & sheen
                  const _HeroTopOverlay(),
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
                  // Hero Header - No overlap!
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 24,
                    child: HeroHeader(
                      title: 'Welcome Back!',
                      brand: 'WAZEET',
                      subtitle: 'Your Business Journey Starts',
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                    ),
                  ),
                  // Bottom fade / curved transition
                  const _HeroBottomFade(),
                ],
              ),
              titlePadding: EdgeInsets.zero,
              title: const SizedBox.shrink(), // Hide default title
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Quick Actions Header
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(AppSpacing.sm),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppColors.purple.withValues(alpha: 0.2),
                              AppColors.purple.withValues(alpha: 0.1),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(AppRadius.md),
                        ),
                        child: Icon(
                          Icons.flash_on_rounded,
                          color: AppColors.purple,
                          size: 24,
                        ),
                      ),
                      SizedBox(width: AppSpacing.md),
                      Text(
                        'Quick Actions',
                        style: AppTextStyle.headlineSmall.copyWith(
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.white
                              : AppColors.text,
                        ),
                      ),
                      const Spacer(),
                      TextButton.icon(
                        onPressed: () {
                          // Navigate to services tab (index 1)
                          onNavigateToTab?.call(1);
                        },
                        icon: Icon(Icons.arrow_forward_rounded, size: 18),
                        label: Text('View All'),
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.purple,
                          backgroundColor: AppColors.purple.withValues(
                            alpha: 0.1,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppRadius.md),
                          ),
                          padding: EdgeInsets.symmetric(
                            horizontal: AppSpacing.md,
                            vertical: AppSpacing.sm,
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
                        'Find Your\nFree Zone',
                        Icons.explore,
                        scheme.primary,
                        () {
                          context.pushWithSlide(const FreezoneBrowserPage());
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
                          // Open AI Tax Calculator screen
                          context.pushWithSlide(const AiTaxCalculatorScreen());
                        },
                      ),
                      _buildQuickActionCard(
                        context,
                        'AI Business\nExpert',
                        Icons.smart_toy,
                        const Color(0xFF06B6D4), // cyan
                        () {
                          context.pushWithSlide(const AIBusinessChatPage());
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),

                  // Tips & Insights Section
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(AppSpacing.sm),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppColors.gold.withValues(alpha: 0.25),
                              AppColors.gold.withValues(alpha: 0.12),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(AppRadius.md),
                        ),
                        child: Icon(
                          Icons.lightbulb_rounded,
                          color: AppColors.gold,
                          size: 24,
                        ),
                      ),
                      SizedBox(width: AppSpacing.md),
                      Text(
                        'Tips & Insights',
                        style: AppTextStyle.headlineSmall.copyWith(
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.white
                              : AppColors.text,
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
                          '🗺️',
                          'Investment Map',
                          'Explore investment opportunities across UAE freezones',
                          Colors.purple,
                          onTap: () {
                            context.pushWithSlide(
                              const FreezoneInvestmentMapPage(),
                            );
                          },
                        ),
                        _buildTipCard(
                          '💼',
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
                        padding: EdgeInsets.all(AppSpacing.sm),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppColors.blue.withValues(alpha: 0.2),
                              AppColors.blue.withValues(alpha: 0.1),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(AppRadius.md),
                        ),
                        child: Icon(
                          Icons.history_rounded,
                          color: AppColors.blue,
                          size: 24,
                        ),
                      ),
                      SizedBox(width: AppSpacing.md),
                      Text(
                        'Recent Activity',
                        style: AppTextStyle.headlineSmall.copyWith(
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.white
                              : AppColors.text,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  userActivities.when(
                    data: (activities) {
                      if (activities.isEmpty) {
                        return _buildEmptyActivityState(context);
                      }
                      return Column(
                        children: activities
                            .map(
                              (activity) => _buildActivityCard(
                                context,
                                activity.title,
                                activity.status,
                                activity.subtitle,
                                activity.icon,
                                activity.color,
                                activity.progress,
                              ),
                            )
                            .toList(),
                      );
                    },
                    loading: () => const Center(
                      child: Padding(
                        padding: EdgeInsets.all(24.0),
                        child: CircularProgressIndicator(),
                      ),
                    ),
                    error: (error, stack) => _buildEmptyActivityState(context),
                  ),
                  const SizedBox(height: 24),

                  // Help & Support
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: scheme.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: scheme.outlineVariant),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: scheme.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.support_agent,
                            color: scheme.primary,
                            size: 28,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Need Help?',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: scheme.onSurface,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Our support team is here 24/7',
                                style: TextStyle(
                                  color: scheme.onSurfaceVariant,
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
                            backgroundColor: scheme.primary,
                            foregroundColor: scheme.onPrimary,
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
    final scheme = Theme.of(context).colorScheme;
    return InkWell(
      onTap: () {
        context.pushWithSlide(const FreezoneBrowserPage());
      },
      borderRadius: BorderRadius.circular(18),
      child: Container(
        width: 290,
        height: 140,
        margin: const EdgeInsets.only(right: 14),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [scheme.primary, scheme.primary.withValues(alpha: 0.85)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: scheme.primary.withValues(alpha: 0.35),
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

  Widget _buildQuickActionCard(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                isDark ? AppColors.darkCard : Colors.white,
                color.withValues(alpha: isDark ? 0.08 : 0.03),
              ],
            ),
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(
              color: color.withValues(alpha: isDark ? 0.2 : 0.15),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.15),
                blurRadius: 16,
                offset: Offset(0, AppSpacing.xs),
                spreadRadius: 0,
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      color.withValues(alpha: 0.2),
                      color.withValues(alpha: 0.12),
                    ],
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: color.withValues(alpha: 0.3),
                      blurRadius: 12,
                      offset: Offset(0, AppSpacing.xs),
                    ),
                  ],
                ),
                child: Icon(icon, color: color, size: 32),
              ),
              SizedBox(height: AppSpacing.md),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: AppSpacing.sm),
                child: Text(
                  title,
                  textAlign: TextAlign.center,
                  style: AppTextStyle.labelLarge.copyWith(
                    color: isDark ? AppColors.darkText : AppColors.text,
                    fontSize: 13,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyActivityState(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            isDark ? AppColors.darkCard : Colors.white,
            isDark
                ? AppColors.darkCard.withValues(alpha: 0.5)
                : Colors.grey.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(
          color: isDark
              ? AppColors.darkBorder
              : AppColors.borderLight.withValues(alpha: 0.5),
          width: 1.5,
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.blue.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.inbox_outlined,
              size: 48,
              color: AppColors.blue.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'No Recent Activity',
            style: AppTextStyle.titleMedium.copyWith(
              color: isDark ? AppColors.darkText : AppColors.text,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Your recent activities will appear here',
            style: AppTextStyle.bodySmall.copyWith(
              color: isDark
                  ? AppColors.darkTextSecondary
                  : AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildActivityCard(
    BuildContext context,
    String title,
    String status,
    String subtitle,
    IconData icon,
    Color color,
    double progress,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: EdgeInsets.only(bottom: AppSpacing.md),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            isDark ? AppColors.darkCard : Colors.white,
            color.withValues(alpha: isDark ? 0.08 : 0.03),
          ],
        ),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(
          color: color.withValues(alpha: isDark ? 0.25 : 0.2),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.12),
            blurRadius: 12,
            offset: Offset(0, AppSpacing.xs),
            spreadRadius: 0,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.all(AppSpacing.md),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          color.withValues(alpha: 0.2),
                          color.withValues(alpha: 0.12),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(AppRadius.md),
                      boxShadow: [
                        BoxShadow(
                          color: color.withValues(alpha: 0.25),
                          blurRadius: 8,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Icon(icon, color: color, size: 26),
                  ),
                  SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: AppTextStyle.titleMedium.copyWith(
                            color: isDark ? AppColors.darkText : AppColors.text,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        SizedBox(height: AppSpacing.xs),
                        Text(
                          subtitle,
                          style: AppTextStyle.bodySmall.copyWith(
                            color: isDark
                                ? Colors.white.withValues(alpha: .82)
                                : AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.sm,
                    ),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          color.withValues(alpha: 0.18),
                          color.withValues(alpha: 0.12),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(AppRadius.md),
                      border: Border.all(
                        color: color.withValues(alpha: 0.35),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      status,
                      style: AppTextStyle.labelSmall.copyWith(
                        color: isDark ? Colors.white : color,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (progress < 1.0)
              Container(
                height: 5,
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.darkBorder.withValues(alpha: 0.5)
                      : AppColors.borderLight,
                ),
                child: FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: progress,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [color, color.withValues(alpha: 0.75)],
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
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        child: Container(
          width: 290,
          height: 140,
          margin: EdgeInsets.only(right: AppSpacing.md),
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [color.withValues(alpha: 0.9), color],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(AppRadius.xl),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.4),
                blurRadius: 16,
                offset: Offset(0, AppSpacing.sm),
                spreadRadius: 0,
              ),
            ],
          ),
          child: Stack(
            children: [
              // Decorative circles
              Positioned(
                top: -25,
                right: -25,
                child: Container(
                  width: 110,
                  height: 110,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.12),
                  ),
                ),
              ),
              Positioned(
                bottom: -15,
                left: -15,
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.08),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(AppSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.25),
                        borderRadius: BorderRadius.circular(AppRadius.md),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 8,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Text(emoji, style: TextStyle(fontSize: 24)),
                    ),
                    SizedBox(height: AppSpacing.sm),
                    Text(
                      title,
                      style: AppTextStyle.titleMedium.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: AppSpacing.xs),
                    Flexible(
                      child: Text(
                        description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyle.bodySmall.copyWith(
                          color: Colors.white.withValues(alpha: 0.95),
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
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
            color: Theme.of(context).colorScheme.surface,
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
            color: Theme.of(context).colorScheme.surface,
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
            color: Theme.of(context).colorScheme.surface,
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

  Widget _bodyText(String text) =>
      Text(text, style: const TextStyle(height: 1.4, fontSize: 13.5));

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
            color: Theme.of(context).colorScheme.surface,
            child: const ProviderScope(child: CompanySetupFlow()),
          ),
        ),
      ),
    );
  }
}

// Top overlay with subtle radial glow & sheen bar
class _HeroTopOverlay extends StatelessWidget {
  const _HeroTopOverlay();
  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Stack(
        children: [
          // Large soft radial glow
          Positioned(
            top: -120,
            left: -60,
            child: Container(
              width: 260,
              height: 260,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    Colors.white.withValues(alpha: .35),
                    Colors.white.withValues(alpha: .08),
                    Colors.transparent,
                  ],
                  stops: const [0, .55, 1],
                ),
              ),
            ),
          ),
          // Shimmer bar (static subtle sheen)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 72,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.white.withValues(alpha: .35),
                    Colors.white.withValues(alpha: .12),
                    Colors.transparent,
                  ],
                  stops: const [0, .55, 1],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Bottom fade giving a smooth transition & hint of curvature
class _HeroBottomFade extends StatelessWidget {
  const _HeroBottomFade();
  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: IgnorePointer(
        child: Container(
          height: 90,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
              colors: [
                Colors.white.withValues(alpha: .65),
                Colors.white.withValues(alpha: .35),
                Colors.white.withValues(alpha: .08),
                Colors.transparent,
              ],
              stops: const [0, .35, .7, 1],
            ),
          ),
          child: CustomPaint(
            painter: _ArcPainter(color: Colors.white.withValues(alpha: .4)),
          ),
        ),
      ),
    );
  }
}

class _ArcPainter extends CustomPainter {
  final Color color;
  _ArcPainter({required this.color});
  @override
  void paint(Canvas canvas, Size size) {
    final path = Path();
    // Draw a soft upward arc to imply depth
    path.moveTo(0, size.height);
    path.quadraticBezierTo(
      size.width * .5,
      size.height - 42,
      size.width,
      size.height,
    );
    path.lineTo(size.width, size.height);
    path.close();
    final paint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.bottomCenter,
        end: Alignment.topCenter,
        colors: [color.withValues(alpha: .55), color.withValues(alpha: .05)],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _ArcPainter oldDelegate) => false;
}
