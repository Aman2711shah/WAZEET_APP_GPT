// lib/community/news_repository.dart
import 'dart:convert';
import 'dart:developer' as developer;
import 'package:http/http.dart' as http;
import 'models.dart';

class NewsRepository {
  final String _apiKey;
  final String _cseId;
  final Map<String, _CachedResult<Paginated<NewsItem>>> _cache = {};
  static const _cacheDuration = Duration(minutes: 10);

  NewsRepository({required String apiKey, required String cseId})
    : _apiKey = apiKey,
      _cseId = cseId;

  /// Fetch news articles for a given industry
  Future<Paginated<NewsItem>> fetchNews({
    String? industry,
    int start = 1,
  }) async {
    final cacheKey = '${industry ?? "all"}|$start';

    // Check cache
    if (_cache.containsKey(cacheKey)) {
      final cached = _cache[cacheKey]!;
      if (DateTime.now().difference(cached.timestamp) < _cacheDuration) {
        return cached.data;
      }
    }

    try {
      final query = _buildQuery(industry);
      final url = Uri.parse(
        'https://www.googleapis.com/customsearch/v1'
        '?key=$_apiKey'
        '&cx=$_cseId'
        '&q=$query'
        '&start=$start'
        '&num=10',
      );

      final response = await http.get(url);

      if (response.statusCode != 200) {
        throw Exception('Failed to fetch news: ${response.statusCode}');
      }

      final json = jsonDecode(response.body) as Map<String, dynamic>;
      final items =
          (json['items'] as List<dynamic>?)
              ?.map((item) => NewsItem.fromJson(item as Map<String, dynamic>))
              .toList() ??
          [];

      final totalResults =
          int.tryParse(json['searchInformation']?['totalResults'] ?? '0') ?? 0;
      final nextStart = start + 10;

      final result = Paginated<NewsItem>(
        items: items,
        nextPageToken: nextStart <= totalResults ? '$nextStart' : null,
        totalResults: totalResults,
      );

      // Cache result
      _cache[cacheKey] = _CachedResult(data: result, timestamp: DateTime.now());

      return result;
    } catch (e, stack) {
      developer.log(
        'Error fetching news: $e',
        name: 'NewsRepository',
        error: e,
        stackTrace: stack,
      );
      rethrow;
    }
  }

  String _buildQuery(String? industry) {
    final baseQuery = 'business news Dubai UAE';

    if (industry == null || industry == 'All Industries') {
      return Uri.encodeComponent(baseQuery);
    }

    // Map industries to search terms
    final industryKeywords = _getIndustryKeywords(industry);
    final fullQuery = '$baseQuery $industryKeywords';

    return Uri.encodeComponent(fullQuery);
  }

  String _getIndustryKeywords(String industry) {
    // Map common industries to search-friendly keywords
    final keywordMap = {
      'Technology': 'tech startup software AI',
      'Finance': 'fintech banking investment',
      'Real Estate': 'property development construction',
      'Healthcare': 'medical health pharma',
      'Retail': 'ecommerce retail shopping',
      'Manufacturing': 'manufacturing industrial production',
      'Hospitality': 'hotel restaurant tourism',
      'Education': 'education learning training',
      'Transportation': 'logistics transport shipping',
      'Media': 'media entertainment digital',
    };

    return keywordMap[industry] ?? industry.toLowerCase();
  }

  void clearCache() {
    _cache.clear();
  }
}

class _CachedResult<T> {
  final T data;
  final DateTime timestamp;

  _CachedResult({required this.data, required this.timestamp});
}
