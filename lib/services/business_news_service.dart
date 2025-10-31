import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/business_news.dart';

/// Provider for BusinessNewsService singleton
final businessNewsServiceProvider = Provider<BusinessNewsService>((ref) {
  return BusinessNewsService();
});

/// Provider to fetch business news, optionally filtered by industry
final businessNewsByIndustryProvider =
    FutureProvider.family<List<BusinessNewsItem>, String?>((
      ref,
      industry,
    ) async {
      final svc = ref.watch(businessNewsServiceProvider);
      return svc.fetchNews(industry: industry);
    });

class BusinessNewsService {
  /// TODO: Replace with real integrations (Google News / Bloomberg / Reuters)
  /// For now, returns curated sample items for UI.
  Future<List<BusinessNewsItem>> fetchNews({String? industry}) async {
    // Simulated delay
    await Future.delayed(const Duration(milliseconds: 350));

    final items = <BusinessNewsItem>[
      BusinessNewsItem(
        industry: 'Technology',
        headline: 'AI investments surge as enterprises adopt GenAI at scale',
        source: 'Google News',
        publishedAt: DateTime.now().subtract(const Duration(hours: 2)),
        url: 'https://news.google.com/',
        thumbnailUrl:
            'https://images.unsplash.com/photo-1518779578993-ec3579fee39f?w=400',
        logoUrl:
            'https://upload.wikimedia.org/wikipedia/commons/0/0b/Google_News_icon.png',
      ),
      BusinessNewsItem(
        industry: 'Finance',
        headline: 'Markets rally as central banks signal rate cuts into 2026',
        source: 'Bloomberg',
        publishedAt: DateTime.now().subtract(
          const Duration(hours: 3, minutes: 12),
        ),
        url: 'https://www.bloomberg.com',
        thumbnailUrl:
            'https://images.unsplash.com/photo-1526304640581-d334cdbbf45e?w=400',
        logoUrl:
            'https://upload.wikimedia.org/wikipedia/commons/7/72/Bloomberg_logo.svg',
      ),
      BusinessNewsItem(
        industry: 'Real Estate',
        headline: 'Commercial property sees renewed demand in GCC hubs',
        source: 'Reuters',
        publishedAt: DateTime.now().subtract(const Duration(hours: 6)),
        url: 'https://www.reuters.com',
        thumbnailUrl:
            'https://images.unsplash.com/photo-1460317442991-0ec209397118?w=400',
        logoUrl:
            'https://upload.wikimedia.org/wikipedia/commons/5/59/Reuters_Logo.svg',
      ),
      BusinessNewsItem(
        industry: 'Healthcare',
        headline: 'Healthtech funding rebounds with focus on telemedicine',
        source: 'Google News',
        publishedAt: DateTime.now().subtract(const Duration(hours: 8)),
        url: 'https://news.google.com/',
        thumbnailUrl:
            'https://images.unsplash.com/photo-1582719478250-c89cae4dc85b?w=400',
      ),
      BusinessNewsItem(
        industry: 'Energy',
        headline: 'Renewables expansion accelerates amid record investments',
        source: 'Reuters',
        publishedAt: DateTime.now().subtract(const Duration(hours: 10)),
        url: 'https://www.reuters.com',
        thumbnailUrl:
            'https://images.unsplash.com/photo-1509395176047-4a66953fd231?w=400',
      ),
      BusinessNewsItem(
        industry: 'Construction',
        headline: 'Mega-projects reshape urban skylines across MENA',
        source: 'Bloomberg',
        publishedAt: DateTime.now().subtract(const Duration(hours: 12)),
        url: 'https://www.bloomberg.com',
        thumbnailUrl:
            'https://images.unsplash.com/photo-1469474968028-56623f02e42e?w=400',
      ),
      BusinessNewsItem(
        industry: 'Retail',
        headline: 'E-commerce growth normalizes; omnichannel drives margins',
        source: 'Google News',
        publishedAt: DateTime.now().subtract(const Duration(hours: 15)),
        url: 'https://news.google.com/',
        thumbnailUrl:
            'https://images.unsplash.com/photo-1522199794611-8e2a7a3b89d9?w=400',
      ),
      BusinessNewsItem(
        industry: 'Logistics',
        headline: 'Supply chains leaner with nearshoring and smart warehousing',
        source: 'Reuters',
        publishedAt: DateTime.now().subtract(const Duration(hours: 18)),
        url: 'https://www.reuters.com',
        thumbnailUrl:
            'https://images.unsplash.com/photo-1543362906-acfc16c67564?w=400',
      ),
    ];

    if (industry == null || industry == 'All Industries' || industry.isEmpty) {
      return items;
    }
    final lower = industry.toLowerCase();
    return items.where((e) => e.industry.toLowerCase() == lower).toList();
  }
}
