// lib/community/events_repository.dart
import 'dart:convert';
import 'dart:developer' as developer;
import 'package:http/http.dart' as http;
import 'models.dart';

class EventsRepository {
  final String _apiKey;
  final String _cseId;
  final Map<String, _CachedResult<Paginated<EventItem>>> _cache = {};
  static const _cacheDuration = Duration(minutes: 15);

  EventsRepository({required String apiKey, required String cseId})
    : _apiKey = apiKey,
      _cseId = cseId;

  /// Fetch events for a given industry and date range
  Future<Paginated<EventItem>> list({
    String? industry,
    DateTime? from,
    DateTime? to,
    int start = 1,
  }) async {
    final fromDate = from ?? DateTime.now();
    final toDate = to ?? fromDate.add(const Duration(days: 90));

    final cacheKey =
        '${industry ?? "all"}|${fromDate.toIso8601String()}|$start';

    // Check cache
    if (_cache.containsKey(cacheKey)) {
      final cached = _cache[cacheKey]!;
      if (DateTime.now().difference(cached.timestamp) < _cacheDuration) {
        return cached.data;
      }
    }

    try {
      final query = _buildQuery(industry, fromDate, toDate);
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
        throw Exception('Failed to fetch events: ${response.statusCode}');
      }

      final json = jsonDecode(response.body) as Map<String, dynamic>;
      final items =
          (json['items'] as List<dynamic>?)
              ?.map((item) => _parseEvent(item as Map<String, dynamic>))
              .toList() ??
          [];

      final totalResults =
          int.tryParse(json['searchInformation']?['totalResults'] ?? '0') ?? 0;
      final nextStart = start + 10;

      final result = Paginated<EventItem>(
        items: items,
        nextPageToken: nextStart <= totalResults ? '$nextStart' : null,
        totalResults: totalResults,
      );

      // Cache result
      _cache[cacheKey] = _CachedResult(data: result, timestamp: DateTime.now());

      return result;
    } catch (e, stack) {
      developer.log(
        'Error fetching events: $e',
        name: 'EventsRepository',
        error: e,
        stackTrace: stack,
      );
      rethrow;
    }
  }

  EventItem _parseEvent(Map<String, dynamic> json) {
    // Try to extract event data from search result
    final title = json['title'] ?? '';
    final snippet = json['snippet'] ?? '';
    final link = json['link'] ?? '';

    // Try to extract date from snippet or metadata
    DateTime startDate =
        _extractDate(snippet) ?? DateTime.now().add(const Duration(days: 7));

    return EventItem(
      id: json['cacheId'] ?? link,
      title: title,
      start: startDate,
      end: null,
      organizer: json['displayLink'] ?? '',
      location: 'Dubai, UAE',
      imageUrl: json['pagemap']?['cse_image']?[0]?['src'],
      description: snippet,
      sourceUrl: link,
    );
  }

  DateTime? _extractDate(String text) {
    // Simple date extraction - can be enhanced
    final datePatterns = [
      RegExp(r'(\d{4})-(\d{2})-(\d{2})'), // YYYY-MM-DD
      RegExp(r'(\d{1,2})/(\d{1,2})/(\d{4})'), // MM/DD/YYYY
      RegExp(r'(\w+)\s+(\d{1,2}),?\s+(\d{4})'), // Month DD, YYYY
    ];

    for (final pattern in datePatterns) {
      final match = pattern.firstMatch(text);
      if (match != null) {
        try {
          if (pattern == datePatterns[0]) {
            return DateTime.parse(match.group(0)!);
          } else if (pattern == datePatterns[1]) {
            final month = int.parse(match.group(1)!);
            final day = int.parse(match.group(2)!);
            final year = int.parse(match.group(3)!);
            return DateTime(year, month, day);
          } else if (pattern == datePatterns[2]) {
            final monthName = match.group(1)!;
            final day = int.parse(match.group(2)!);
            final year = int.parse(match.group(3)!);
            final month = _monthNameToNumber(monthName);
            if (month != null) {
              return DateTime(year, month, day);
            }
          }
        } catch (e) {
          // Continue trying other patterns
        }
      }
    }

    return null;
  }

  int? _monthNameToNumber(String name) {
    const months = {
      'january': 1,
      'jan': 1,
      'february': 2,
      'feb': 2,
      'march': 3,
      'mar': 3,
      'april': 4,
      'apr': 4,
      'may': 5,
      'june': 6,
      'jun': 6,
      'july': 7,
      'jul': 7,
      'august': 8,
      'aug': 8,
      'september': 9,
      'sep': 9,
      'sept': 9,
      'october': 10,
      'oct': 10,
      'november': 11,
      'nov': 11,
      'december': 12,
      'dec': 12,
    };
    return months[name.toLowerCase()];
  }

  String _buildQuery(String? industry, DateTime from, DateTime to) {
    final baseQuery = 'business events networking Dubai UAE';

    if (industry == null || industry == 'All Industries') {
      return Uri.encodeComponent(baseQuery);
    }

    // Map industries to event types
    final industryTerms = _getIndustryTerms(industry);
    final fullQuery = '$baseQuery $industryTerms';

    return Uri.encodeComponent(fullQuery);
  }

  String _getIndustryTerms(String industry) {
    final termMap = {
      'Technology': 'tech startup innovation conference',
      'Finance': 'fintech banking investment summit',
      'Real Estate': 'property real estate expo',
      'Healthcare': 'healthcare medical conference',
      'Retail': 'retail ecommerce trade show',
      'Manufacturing': 'manufacturing industrial exhibition',
      'Hospitality': 'hospitality tourism conference',
      'Education': 'education training workshop',
      'Transportation': 'logistics transport summit',
      'Media': 'media digital marketing conference',
    };

    return termMap[industry] ?? '$industry conference';
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
