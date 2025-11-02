import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/service_item.dart';
import 'sub_service_detail_page.dart';
import '../theme.dart';
import '../widgets/gradient_header.dart';

class ServiceTypePage extends ConsumerWidget {
  final ServiceCategory category;

  const ServiceTypePage({super.key, required this.category});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          GradientHeader(title: category.name, showBackButton: true),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: category.serviceTypes.length,
              itemBuilder: (context, index) {
                final serviceType = category.serviceTypes[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    leading: Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: Color(
                          int.parse(category.color),
                        ).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text(
                          category.icon,
                          style: const TextStyle(fontSize: 24),
                        ),
                      ),
                    ),
                    title: Text(
                      serviceType.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    subtitle: Text(
                      '${serviceType.subServices.length} services available',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 14,
                      ),
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SubServiceListPage(
                            serviceType: serviceType,
                            categoryIcon: category.icon,
                            categoryColor: category.color,
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class SubServiceListPage extends ConsumerWidget {
  final ServiceType serviceType;
  final String categoryIcon;
  final String categoryColor;

  const SubServiceListPage({
    super.key,
    required this.serviceType,
    required this.categoryIcon,
    required this.categoryColor,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          GradientHeader(title: serviceType.name, showBackButton: true),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: serviceType.subServices.length,
              itemBuilder: (context, index) {
                final subService = serviceType.subServices[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SubServiceDetailPage(
                            subService: subService,
                            serviceTypeName: serviceType.name,
                            categoryIcon: categoryIcon,
                          ),
                        ),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: Color(
                                    int.parse(categoryColor),
                                  ).withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Center(
                                  child: Text(
                                    categoryIcon,
                                    style: const TextStyle(fontSize: 20),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      subService.name,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'From ${subService.standardCostDisplay}',
                                      style: TextStyle(
                                        color: AppColors.purple,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const Icon(Icons.arrow_forward_ios, size: 16),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Icon(
                                Icons.access_time,
                                size: 16,
                                color: Colors.grey.shade600,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Standard: ${subService.standard.timeline}',
                                style: TextStyle(
                                  color: Colors.grey.shade600,
                                  fontSize: 13,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Icon(
                                Icons.description,
                                size: 16,
                                color: Colors.grey.shade600,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${subService.documentRequirements.length} docs',
                                style: TextStyle(
                                  color: Colors.grey.shade600,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
