import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/services_provider.dart';
import 'service_type_page.dart';
import '../theme.dart';

class ServicesPage extends ConsumerStatefulWidget {
  const ServicesPage({super.key});
  @override
  ConsumerState<ServicesPage> createState() => _ServicesPageState();
}

class _ServicesPageState extends ConsumerState<ServicesPage> {
  final _search = TextEditingController();

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

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 280,
            pinned: true,
            floating: false,
            backgroundColor: AppColors.purple,
            flexibleSpace: FlexibleSpaceBar(
              title: const Text(
                'Services',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  shadows: [Shadow(color: Colors.black38, blurRadius: 8)],
                ),
              ),
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    'https://images.unsplash.com/photo-1552664730-d307ca884978?w=1600&h=800&fit=crop',
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: AppColors.purple.withOpacity(0.3),
                      );
                    },
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withOpacity(0.3),
                          AppColors.purple.withOpacity(0.85),
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
                        color: Colors.white.withOpacity(0.95),
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.3,
                      ),
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
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.purple.withOpacity(.08),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Expanded(
                            child: Text(
                              'Need a custom solution?',
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Contact us at support@wazeet.com',
                                  ),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.purple,
                              foregroundColor: Colors.white,
                            ),
                            child: const Text('Contact Us'),
                          ),
                        ],
                      ),
                    ),
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
                      side: BorderSide(color: Colors.grey.shade200),
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
                            int.parse(category.color),
                          ).withOpacity(0.1),
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
                          color: Colors.grey.shade600,
                          fontSize: 13,
                        ),
                      ),
                      trailing: Icon(
                        Icons.arrow_forward_ios,
                        size: 16,
                        color: Colors.grey.shade400,
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
