import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/services_provider.dart';
import 'service_type_page.dart';
import '../responsive.dart';
import '../theme/responsive_text.dart';
import '../widgets/back_to_top_button.dart';
import '../widgets/custom_solution_panel.dart';

class ServicesPage extends ConsumerStatefulWidget {
  const ServicesPage({super.key});
  @override
  ConsumerState<ServicesPage> createState() => _ServicesPageState();
}

class _ServicesPageState extends ConsumerState<ServicesPage> {
  final _search = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    final allCategories = ref.watch(servicesProvider);
    final filteredCategories = _search.text.isEmpty
        ? allCategories
        : allCategories.where((category) {
            return category.name.toLowerCase().contains(
              _search.text.toLowerCase(),
            );
          }).toList();

    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      floatingActionButton: BackToTopButton(controller: _scrollController),
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          SliverAppBar(
            expandedHeight: Responsive.heroHeight(context),
            pinned: true,
            floating: false,
            backgroundColor: scheme.primary,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                'Services',
                style: TextStyle(
                  color: scheme.onPrimary,
                  fontWeight: FontWeight.bold,
                  fontSize: rFont(context, sm: 16, md: 18, lg: 20),
                  shadows: const [Shadow(color: Colors.black38, blurRadius: 8)],
                ),
              ),
              background: SafeArea(
                top: true,
                child: Stack(
                  clipBehavior: Clip.hardEdge,
                  fit: StackFit.expand,
                  children: [
                    Image.network(
                      'https://images.unsplash.com/photo-1552664730-d307ca884978?w=1600&h=800&fit=crop',
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: scheme.primary.withValues(alpha: 0.3),
                        );
                      },
                    ),
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black.withValues(alpha: 0.35),
                            scheme.primary.withValues(alpha: 0.5),
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      left: 16,
                      right: 16,
                      bottom: 56,
                      child: Text(
                        'Professional business services in Dubai',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.95),
                          fontSize: rFont(context, sm: 12, md: 13, lg: 14),
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.3,
                        ),
                        maxLines: 2,
                        softWrap: true,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Compliance Seals
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: Row(
                  children: [
                    const _ComplianceSeal(
                      label: 'Built on UAE Standards',
                      icon: Icons.verified,
                      color: Colors.green,
                    ),
                    const SizedBox(width: 12),
                    const _ComplianceSeal(
                      label: 'GDPR-ready',
                      icon: Icons.shield,
                      color: Colors.blue,
                    ),
                    const SizedBox(width: 12),
                    const _ComplianceSeal(
                      label: 'Secure Payments',
                      icon: Icons.lock,
                      color: Colors.deepPurple,
                    ),
                  ],
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Search
                  TextField(
                    controller: _search,
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.search),
                      hintText: 'Search for services',
                    ),
                    onChanged: (_) => setState(() {}),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                if (index == filteredCategories.length) {
                  // CTA at the end
                  return Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                    child: const CustomSolutionPanel(),
                  );
                }

                final category = filteredCategories[index];
                final totalServices = category.serviceTypes.fold(
                  0,
                  (sum, type) => sum + type.subServices.length,
                );

                return Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                  child: Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(color: scheme.outlineVariant),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      leading: Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: Color(
                            int.tryParse(category.color) ?? 0xFF6200EE,
                          ).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Center(
                          child: Text(
                            category.icon,
                            style: const TextStyle(fontSize: 24),
                          ),
                        ),
                      ),
                      title: Text(
                        category.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      subtitle: Text(
                        '$totalServices services available',
                        style: TextStyle(
                          color: scheme.onSurfaceVariant,
                          fontSize: 13,
                        ),
                      ),
                      trailing: Icon(
                        Icons.arrow_forward_ios,
                        size: 16,
                        color: scheme.onSurfaceVariant.withValues(alpha: 0.7),
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                ServiceTypePage(category: category),
                          ),
                        );
                      },
                    ),
                  ),
                );
              },
              childCount: filteredCategories.length + 1, // +1 for CTA
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------- Helper Widgets ----------------------

// Compliance Seal Widget
class _ComplianceSeal extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;

  const _ComplianceSeal({
    required this.label,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

// Verified Badge Widget (for future use)
class VerifiedBadge extends StatelessWidget {
  final double size;

  const VerifiedBadge({super.key, this.size = 16});

  @override
  Widget build(BuildContext context) {
    return Icon(Icons.verified, color: Colors.blue, size: size);
  }
}
