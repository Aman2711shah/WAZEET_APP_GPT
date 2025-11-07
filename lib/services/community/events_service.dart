import 'package:cloud_functions/cloud_functions.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../../models/community_models.dart';

/// Service for fetching upcoming business events from Google CSE
class EventsService {
  final _functions = FirebaseFunctions.instance;
  static const _cacheKeyPrefix = 'wazeet.community.events';
  static const _cacheTimestampPrefix = 'wazeet.community.events.timestamp';
  static const _cacheDuration = Duration(hours: 4);

  /// Fetch upcoming events with optional industry filter
  Future<List<EventItem>> fetch({
    String? industry,
    bool forceRefresh = false,
  }) async {
    // Check cache first
    if (!forceRefresh) {
      final cached = await _getCached(industry);
      if (cached != null) {
        return cached;
      }
    }

    // Fetch from Cloud Function with retry
    return _fetchWithRetry(industry);
  }

  String _getCacheKey(String? industry) {
    return '$_cacheKeyPrefix:${industry ?? 'all'}';
  }

  String _getCacheTimestampKey(String? industry) {
    return '$_cacheTimestampPrefix:${industry ?? 'all'}';
  }

  Future<List<EventItem>?> _getCached(String? industry) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final timestamp = prefs.getInt(_getCacheTimestampKey(industry));
      if (timestamp != null) {
        final cacheAge = DateTime.now().millisecondsSinceEpoch - timestamp;
        if (cacheAge < _cacheDuration.inMilliseconds) {
          final json = prefs.getString(_getCacheKey(industry));
          if (json != null) {
            final List<dynamic> data = jsonDecode(json);
            return data.map((item) => EventItem.fromJson(item)).toList();
          }
        }
      }
    } catch (e) {
      // Ignore cache errors
    }
    return null;
  }

  Future<void> _setCache(String? industry, List<EventItem> items) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final json = jsonEncode(items.map((item) => item.toJson()).toList());
      await prefs.setString(_getCacheKey(industry), json);
      await prefs.setInt(
        _getCacheTimestampKey(industry),
        DateTime.now().millisecondsSinceEpoch,
      );
    } catch (e) {
      // Ignore cache errors
    }
  }

  Future<List<EventItem>> _fetchWithRetry(
    String? industry, {
    int attempt = 0,
  }) async {
    const maxAttempts = 3;

    try {
      final callable = _functions.httpsCallable('communityFetchEvents');
      final result = await callable.call({
        if (industry != null &&
            industry.isNotEmpty &&
            industry != 'All Industries')
          'industry': industry,
      });

      final data = result.data as Map<String, dynamic>;
      final eventsData = data['events'] as List<dynamic>;

      final items = eventsData.map((item) => EventItem.fromJson(item)).toList();

      // Cache the results
      await _setCache(industry, items);

      return items;
    } catch (e) {
      if (attempt < maxAttempts - 1) {
        // Exponential backoff: 1s, 2s, 4s
        await Future.delayed(Duration(seconds: 1 << attempt));
        return _fetchWithRetry(industry, attempt: attempt + 1);
      }
      rethrow;
    }
  }

  /// Clear the cache for a specific industry or all
  Future<void> clearCache({String? industry}) async {
    final prefs = await SharedPreferences.getInstance();
    if (industry != null) {
      await prefs.remove(_getCacheKey(industry));
      await prefs.remove(_getCacheTimestampKey(industry));
    } else {
      // Clear all events caches
      final keys = prefs.getKeys();
      for (final key in keys) {
        if (key.startsWith(_cacheKeyPrefix) ||
            key.startsWith(_cacheTimestampPrefix)) {
          await prefs.remove(key);
        }
      }
    }
  }
}
