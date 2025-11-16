import 'package:flutter/material.dart';
import '../ui/widgets/promotional_banner.dart';
import '../ui/widgets/event_card.dart';

class SummitsTab extends StatelessWidget {
  const SummitsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        const PromotionalBanner(
          title: 'Meet investors and mentors',
          subtitle: 'Upcoming business summits across the UAE',
          height: 160,
          imageUrl:
              'https://images.unsplash.com/photo-1518600506278-4e8ef466b810?w=1600&h=800&fit=crop',
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Upcoming Events',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              ),
              const SizedBox(height: 16),
              EventCard(
                title: 'Dubai Entrepreneurs Summit 2024',
                date: 'March 15-17, 2024',
                location: 'DIFC, Dubai',
                description:
                    'Connect with leading entrepreneurs and investors from across the MENA region.',
                onRegister: () {},
              ),
              const SizedBox(height: 12),
              EventCard(
                title: 'Tech Innovation Conference',
                date: 'April 22-23, 2024',
                location: 'Dubai World Trade Centre',
                description:
                    'Explore the latest in AI, blockchain, and fintech innovations.',
                onRegister: () {},
              ),
              const SizedBox(height: 12),
              EventCard(
                title: 'Women in Business Forum',
                date: 'May 10, 2024',
                location: 'Emirates Towers',
                description:
                    'Empowering women entrepreneurs with networking and mentorship opportunities.',
                onRegister: () {},
              ),
              const SizedBox(height: 24),
              const Text(
                'Past Events',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              ),
              const SizedBox(height: 16),
              EventCard(
                title: 'Startup Pitch Competition 2023',
                date: 'December 5, 2023',
                location: 'Dubai Internet City',
                description:
                    'Witnessed amazing pitches from 50+ startups competing for funding.',
                onRegister: null, // Past event, no registration
              ),
            ],
          ),
        ),
      ],
    );
  }
}
