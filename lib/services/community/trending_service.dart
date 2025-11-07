import 'package:cloud_functions/cloud_functions.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../../models/community_models.dart';

/// Service for fetching trending hashtags from Google CSE
class TrendingService {
  final _functions = FirebaseFunctions.instance;
  static const _cacheKey = 'wazeet.community.trending';
  static const _cacheTimestampKey = 'wazeet.community.trending.timestamp';
  static const _cacheDuration = Duration(hours: 4);

  /// Fetch trending hashtags with caching and retry logic
  Future<List<TrendingTag>> fetch({bool forceRefresh = false}) async {
    // Check cache first
    if (!forceRefresh) {
      final cached = await _getCached();
      if (cached != null) {
        return cached;
      }
    }

    // Fetch from Cloud Function with retry
    return _fetchWithRetry();
  }

  Future<List<TrendingTag>?> _getCached() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final timestamp = prefs.getInt(_cacheTimestampKey);
      if (timestamp != null) {
        final cacheAge = DateTime.now().millisecondsSinceEpoch - timestamp;
        if (cacheAge < _cacheDuration.inMilliseconds) {
          final json = prefs.getString(_cacheKey);
          if (json != null) {
            final List<dynamic> data = jsonDecode(json);
            return data.map((item) => TrendingTag.fromJson(item)).toList();
          }
        }
      }
    } catch (e) {
      // Ignore cache errors
    }
    return null;
  }

  Future<void> _setCache(List<TrendingTag> tags) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final json = jsonEncode(tags.map((tag) => tag.toJson()).toList());
      await prefs.setString(_cacheKey, json);
      await prefs.setInt(
        _cacheTimestampKey,
        DateTime.now().millisecondsSinceEpoch,
      );
    } catch (e) {
      // Ignore cache errors
    }
  }

  Future<List<TrendingTag>> _fetchWithRetry({int attempt = 0}) async {
    const maxAttempts = 3;

    try {
      final callable = _functions.httpsCallable('communityFetchHashtags');
      final result = await callable.call();

      final data = result.data as Map<String, dynamic>;
      final hashtagsData = data['hashtags'] as List<dynamic>;

      final tags = hashtagsData
          .map((item) => TrendingTag.fromJson(item))
          .toList();

      // Cache the results
      await _setCache(tags);

      return tags;
    } catch (e) {
      if (attempt < maxAttempts - 1) {
        // Exponential backoff: 1s, 2s, 4s
        await Future.delayed(Duration(seconds: 1 << attempt));
        return _fetchWithRetry(attempt: attempt + 1);
      }
      rethrow;
    }
  }

  /// Clear the cache
  Future<void> clearCache() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_cacheKey);
    await prefs.remove(_cacheTimestampKey);
  }
}
