import 'package:flutter/material.dart';
import '../ui/theme.dart';
import '../ui/widgets/gradient_header.dart';
import '../ui/widgets/search_bar.dart';
import '../ui/widgets/service_square_button.dart';
import 'company_setup_page.dart';

class ServicesTab extends StatelessWidget {
  const ServicesTab({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        const GradientHeader(title: 'Services'),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const AppSearchBar(hint: 'Search'),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: ServiceSquareButton(
                      color: AppColors.blue,
                      icon: Icons.trending_up,
                      label: 'BUSINESS\nGROWTH',
                      onTap: () {},
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ServiceSquareButton(
                      color: AppColors.green,
                      icon: Icons.groups_2,
                      label: 'COMMUNITY\nENGAGEMENT',
                      onTap: () {},
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ServiceSquareButton(
                      color: AppColors.gold,
                      icon: Icons.apartment,
                      label: 'COMPANY\nSET-UP',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const CompanySetupPage(),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Text(
                'Other Services',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 12),
              _other('Legal & Compliance', Icons.gavel),
              _other('Marketing & PR', Icons.campaign_outlined),
              const SizedBox(height: 24),
              _ctaCard(context),
            ],
          ),
        ),
      ],
    );
  }

  Widget _other(String title, IconData icon) {
    return Card(
      child: ListTile(
        leading: Icon(icon),
        title: Text(title),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {},
      ),
    );
  }

  Widget _ctaCard(BuildContext context) {
    return Card(
      color: AppColors.purple.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Need a custom solution?',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 8),
            const Text(
              'Get in touch with our experts for personalized advice.',
            ),
            const SizedBox(height: 12),
            ElevatedButton(onPressed: () {}, child: const Text('Contact Us')),
          ],
        ),
      ),
    );
  }
}
