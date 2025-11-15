import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/services_provider.dart';
import '../../models/service_item.dart';
import '../../utils/icon_mapper.dart';
import 'service_type_page.dart';
import 'sub_service_detail_page.dart';
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
    final query = _search.text.trim().toLowerCase();

    // Search alias support to capture common phrases (e.g., "dependent visa")
    const Map<String, List<String>> aliasMap = {
      'dependent visa': ['family sponsorship', 'family visa', 'sponsor family'],
      'dependent': ['family sponsorship', 'family visa'],
      'corporate tax': ['corporate tax', 'tax registration', 'tax filing'],
      'tax': ['corporate tax', 'vat', 'tax registration', 'tax filing'],
      'visa renewal': ['residence visa renewal', 'visit visa extension'],
    };

    bool matchesText(String haystack, String q) {
      if (haystack.isEmpty || q.isEmpty) return false;
      final text = haystack.toLowerCase();
      if (text.contains(q)) return true;
      final aliases = aliasMap[q];
      if (aliases == null) return false;
      return aliases.any((a) => text.contains(a));
    }

    // When searching, collect sub-service results instead of only filtering categories
    final List<_SearchResult> searchResults = <_SearchResult>[];
    if (query.isNotEmpty) {
      for (final category in allCategories) {
        for (final type in category.serviceTypes) {
          final typeMatches =
              matchesText(type.name, query) ||
              (type.description != null &&
                  matchesText(type.description!, query));

          for (final sub in type.subServices) {
            final subMatches =
                matchesText(sub.name, query) ||
                (sub.description != null &&
                    matchesText(sub.description!, query));

            if (subMatches ||
                typeMatches ||
                matchesText(category.name, query)) {
              // Score: direct sub name match > type match > description/category match
              var score = 0;
              if (matchesText(sub.name, query)) score += 3;
              if (typeMatches) score += 2;
              if (sub.description != null &&
                  matchesText(sub.description!, query)) {
                score += 1;
              }
              if (matchesText(category.name, query)) score += 1;

              searchResults.add(
                _SearchResult(
                  category: category,
                  type: type,
                  sub: sub,
                  score: score,
                ),
              );
            }
          }
        }
      }

      // Deduplicate exact same sub-service and sort by score desc
      final seen = <String>{};
      searchResults.retainWhere((r) => seen.add(r.sub.id));
      searchResults.sort((a, b) => b.score.compareTo(a.score));
    }

    // If not searching, show all categories
    final filteredCategories = query.isEmpty
        ? allCategories
        : allCategories
              .where((c) => c.name.toLowerCase().contains(query))
              .toList();

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
          if (query.isEmpty) ...[
            // Default category list view
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
                          child: Icon(
                            getIconData(category.icon),
                            color: Color(
                              int.tryParse(category.color) ?? 0xFF6200EE,
                            ),
                            size: 26,
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
          ] else ...[
            // Search results view (sub-services)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                child: Text(
                  '${searchResults.length} result${searchResults.length == 1 ? '' : 's'} for "$query"',
                  style: TextStyle(
                    color: scheme.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            if (searchResults.isEmpty)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                  child: Text(
                    'No matching services found. Try a different term (e.g., "corporate tax", "dependent visa").',
                    style: TextStyle(color: scheme.onSurfaceVariant),
                  ),
                ),
              )
            else
              SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  final r = searchResults[index];
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
                              int.tryParse(r.category.color) ?? 0xFF6200EE,
                            ).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            getIconData(r.sub.icon ?? r.category.icon),
                            color: Color(
                              int.tryParse(r.category.color) ?? 0xFF6200EE,
                            ),
                            size: 26,
                          ),
                        ),
                        title: Text(
                          r.sub.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${r.type.name} • ${r.category.name}',
                              style: TextStyle(
                                color: scheme.onSurfaceVariant,
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'From ${r.sub.standardCostDisplay} • ${r.sub.standard.timeline}',
                              style: TextStyle(
                                color: scheme.onSurfaceVariant,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => SubServiceDetailPage(
                                subService: r.sub,
                                serviceTypeName: r.type.name,
                                categoryIcon: r.category.icon,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  );
                }, childCount: searchResults.length),
              ),
          ],
        ],
      ),
    );
  }
}

// ---------------------- Helper Widgets ----------------------

// Local result model for search view
class _SearchResult {
  final ServiceCategory category;
  final ServiceType type;
  final SubService sub;
  final int score;

  _SearchResult({
    required this.category,
    required this.type,
    required this.sub,
    required this.score,
  });
}

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
