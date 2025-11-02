import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:xml/xml.dart' as xml;
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
  final http.Client _client;

  BusinessNewsService({http.Client? client})
    : _client = client ?? http.Client();

  /// Fetches live business news via RSS feeds:
  /// - Google News search RSS (general business + industry)
  /// - Google News search RSS filtered by site:bloomberg.com
  /// - Google News search RSS filtered by site:reuters.com
  /// Returns a merged, de-duplicated, and recency-sorted list.
  Future<List<BusinessNewsItem>> fetchNews({
    String? industry,
    int limit = 20,
  }) async {
    final query = _normalizeIndustry(industry) ?? 'Business';

    final tasks = <Future<List<BusinessNewsItem>>>[
      _fetchGoogleNewsRss(query: '$query business'),
      _fetchGoogleNewsRss(query: 'site:bloomberg.com $query'),
      _fetchGoogleNewsRss(query: 'site:reuters.com $query'),
    ];

    List<List<BusinessNewsItem>> results;
    try {
      results = await Future.wait(tasks);
    } catch (_) {
      // Network or parsing error -> fail soft
      results = const [];
    }

    final merged = <BusinessNewsItem>[];
    for (final list in results) {
      merged.addAll(list);
    }

    // De-duplicate by canonicalized URL + headline
    final seen = <String>{};
    final deduped = <BusinessNewsItem>[];
    for (final item in merged) {
      final key =
          '${item.source.toLowerCase()}::${_canonicalUrl(item.url)}::${item.headline.toLowerCase()}';
      if (seen.add(key)) {
        // Ensure industry is set to the requested one (helps filtering in UI)
        deduped.add(
          BusinessNewsItem(
            industry: _normalizeIndustry(industry) ?? item.industry,
            headline: item.headline,
            source: item.source,
            publishedAt: item.publishedAt,
            url: item.url,
            thumbnailUrl: item.thumbnailUrl,
            logoUrl: item.logoUrl ?? _logoForSource(item.source),
          ),
        );
      }
    }

    deduped.sort((a, b) => b.publishedAt.compareTo(a.publishedAt));
    if (limit > 0 && deduped.length > limit) {
      return deduped.sublist(0, limit);
    }
    return deduped;
  }

  Future<List<BusinessNewsItem>> _fetchGoogleNewsRss({
    required String query,
  }) async {
    final uri = Uri.https('news.google.com', '/rss/search', <String, String>{
      'q': query,
      'hl': 'en-US',
      'gl': 'US',
      'ceid': 'US:en',
    });

    try {
      final res = await _client.get(uri);
      if (res.statusCode != 200) return [];

      final doc = xml.XmlDocument.parse(res.body);
      final items = <BusinessNewsItem>[];
      final inferredIndustry = _inferIndustryFromQuery(query);
      for (final item in doc.findAllElements('item')) {
        final title = item.getElement('title')?.innerText.trim() ?? '';
        final link = item.getElement('link')?.innerText.trim() ?? '';
        final pubDateStr = item.getElement('pubDate')?.innerText.trim();
        final sourceEl = item.getElement('source');
        final source = (sourceEl?.innerText.trim().isNotEmpty ?? false)
            ? sourceEl!.innerText.trim()
            : 'Google News';

        final publishedAt = _parseDate(pubDateStr) ?? DateTime.now();
        final thumb = _extractMediaThumb(item);

        items.add(
          BusinessNewsItem(
            industry: inferredIndustry,
            headline: _stripTitleSuffix(title),
            source: source,
            publishedAt: publishedAt,
            url: link,
            thumbnailUrl: thumb,
            logoUrl: _logoForSource(source),
          ),
        );
      }
      return items;
    } catch (_) {
      return [];
    }
  }

  String _canonicalUrl(String url) {
    try {
      final u = Uri.parse(url);
      // strip tracking/query
      return u.replace(queryParameters: const {}).toString();
    } catch (_) {
      return url;
    }
  }

  String _inferIndustryFromQuery(String q) {
    final lower = q.toLowerCase();
    final candidates = <String>[
      'technology',
      'finance',
      'real estate',
      'healthcare',
      'energy',
      'construction',
      'retail',
      'logistics',
      'business',
    ];
    for (final c in candidates) {
      if (lower.contains(c)) return _toTitleCase(c);
    }
    return 'Business';
  }

  String? _normalizeIndustry(String? industry) {
    if (industry == null || industry.isEmpty || industry == 'All Industries') {
      return null;
    }
    return _toTitleCase(industry);
  }

  String _toTitleCase(String v) {
    return v
        .split(' ')
        .where((e) => e.isNotEmpty)
        .map((w) => w[0].toUpperCase() + w.substring(1).toLowerCase())
        .join(' ');
  }

  String? _extractMediaThumb(xml.XmlElement item) {
    // Try <media:content url="..."> or <enclosure url="...">
    final media = item.findElements('media:content');
    if (media.isNotEmpty) {
      final url = media.first.getAttribute('url');
      if (url != null && url.isNotEmpty) return url;
    }
    final group = item.findElements('media:group');
    if (group.isNotEmpty) {
      final contents = group.first.findElements('media:content');
      if (contents.isNotEmpty) {
        final url = contents.first.getAttribute('url');
        if (url != null && url.isNotEmpty) return url;
      }
    }
    final enclosure = item.findElements('enclosure');
    if (enclosure.isNotEmpty) {
      final url = enclosure.first.getAttribute('url');
      if (url != null && url.isNotEmpty) return url;
    }
    return null;
  }

  DateTime? _parseDate(String? raw) {
    if (raw == null || raw.isEmpty) return null;
    // Try ISO8601
    final iso = DateTime.tryParse(raw);
    if (iso != null) return iso.toLocal();
    // Try common RSS formats
    final patterns = <String>[
      'EEE, dd MMM yyyy HH:mm:ss Z',
      'EEE, dd MMM yyyy HH:mm Z',
      'dd MMM yyyy HH:mm:ss Z',
    ];
    for (final p in patterns) {
      try {
        return DateFormat(p, 'en_US').parseUtc(raw).toLocal();
      } catch (_) {
        // continue
      }
    }
    return null;
  }

  String _stripTitleSuffix(String title) {
    // Google News titles often end with " - Publisher"
    final idx = title.lastIndexOf(' - ');
    if (idx > 0 && idx >= title.length - 60) {
      return title.substring(0, idx).trim();
    }
    return title.trim();
  }

  String? _logoForSource(String? source) {
    if (source == null) return null;
    final s = source.toLowerCase();
    if (s.contains('google')) {
      return 'https://upload.wikimedia.org/wikipedia/commons/0/0b/Google_News_icon.png';
    }
    if (s.contains('bloomberg')) {
      return 'https://upload.wikimedia.org/wikipedia/commons/7/72/Bloomberg_logo.svg';
    }
    if (s.contains('reuters')) {
      return 'https://upload.wikimedia.org/wikipedia/commons/5/59/Reuters_Logo.svg';
    }
    return null;
  }
}
