import 'package:flutter/material.dart';
import '../ui/theme.dart';
import '../ui/widgets/promotional_banner.dart';
import '../ui/widgets/service_square_button.dart';
import '../ui/widgets/event_card.dart';
import 'company_setup_page.dart';

class HomeTab extends StatelessWidget {
  const HomeTab({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        const SliverToBoxAdapter(
          child: PromotionalBanner(
            title: 'Scale your business in Dubai',
            subtitle: 'Company setup • Banking • Visas • Compliance',
            height: 200,
            imageUrl:
                'https://images.unsplash.com/photo-1507679799987-c73779587ccf?w=1600&h=800&fit=crop',
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'DUBAI SERVICES',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 12),
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
                  'FEATURED EVENTS',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 182,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.only(right: 16),
                    itemBuilder: (_, i) => SizedBox(
                      width: 280,
                      child: EventCard(
                        title: _events[i]['title'] as String,
                        date: _events[i]['date'] as String,
                        location: _events[i]['location'] as String,
                        description: _events[i]['description'] as String,
                        onRegister: () {},
                      ),
                    ),
                    separatorBuilder: (_, __) => const SizedBox(width: 12),
                    itemCount: _events.length,
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

const _events = [
  {
    'title': 'Dubai Global Tech Summit',
    'date': 'March 20, 2024',
    'location': 'Dubai World Trade Centre',
    'description': 'Connect with global tech leaders and innovators.',
  },
  {
    'title': 'Entrepreneurship Workshop Dubai',
    'date': 'April 5, 2024',
    'location': 'DIFC Innovation Hub',
    'description': 'Learn essential entrepreneurship skills from experts.',
  },
  {
    'title': 'Entrepreneur Summit',
    'date': 'May 15, 2024',
    'location': 'Emirates Towers',
    'description': 'Network with successful entrepreneurs and investors.',
  },
];
