/// Model for trending hashtag data
class TrendingTag {
  final String tag;
  final int count;

  const TrendingTag({required this.tag, required this.count});

  factory TrendingTag.fromJson(Map<String, dynamic> json) {
    return TrendingTag(
      tag: json['tag'] as String? ?? '',
      count: json['count'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {'tag': tag, 'count': count};
  }

  @override
  String toString() => 'TrendingTag(tag: $tag, count: $count)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TrendingTag && other.tag == tag && other.count == count;
  }

  @override
  int get hashCode => Object.hash(tag, count);

  /// Formats count with K suffix (e.g., 1200 -> "1.2K")
  String get formattedCount {
    if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(1)}K';
    }
    return count.toString();
  }
}

/// Model for business news item
class NewsItem {
  final String title;
  final String source;
  final String url;
  final String snippet;
  final DateTime? publishedAt;

  const NewsItem({
    required this.title,
    required this.source,
    required this.url,
    required this.snippet,
    this.publishedAt,
  });

  factory NewsItem.fromJson(Map<String, dynamic> json) {
    DateTime? parsedDate;
    if (json['publishedAt'] != null) {
      try {
        parsedDate = DateTime.parse(json['publishedAt'] as String);
      } catch (_) {
        // Ignore parse errors
      }
    }

    return NewsItem(
      title: json['title'] as String? ?? 'Untitled',
      source: json['source'] as String? ?? 'Unknown Source',
      url: json['url'] as String? ?? '',
      snippet: json['snippet'] as String? ?? '',
      publishedAt: parsedDate,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'source': source,
      'url': url,
      'snippet': snippet,
      'publishedAt': publishedAt?.toIso8601String(),
    };
  }

  @override
  String toString() => 'NewsItem(title: $title, source: $source, url: $url)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is NewsItem && other.url == url;
  }

  @override
  int get hashCode => url.hashCode;

  /// Returns a human-readable "time ago" string
  String get timeAgo {
    if (publishedAt == null) return 'Recently';

    final now = DateTime.now();
    final difference = now.difference(publishedAt!);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}

/// Model for business event
class EventItem {
  final String title;
  final String url;
  final String organizer;
  final DateTime? whenStart;
  final DateTime? whenEnd;
  final String? venue;
  final String? city;
  final String? industry;

  const EventItem({
    required this.title,
    required this.url,
    required this.organizer,
    this.whenStart,
    this.whenEnd,
    this.venue,
    this.city,
    this.industry,
  });

  factory EventItem.fromJson(Map<String, dynamic> json) {
    DateTime? parseDate(dynamic value) {
      if (value == null) return null;
      try {
        if (value is String) {
          return DateTime.parse(value);
        }
      } catch (_) {
        // Ignore parse errors
      }
      return null;
    }

    return EventItem(
      title: json['title'] as String? ?? 'Untitled Event',
      url: json['url'] as String? ?? '',
      organizer: json['organizer'] as String? ?? 'TBA',
      whenStart: parseDate(json['whenStart']),
      whenEnd: parseDate(json['whenEnd']),
      venue: json['venue'] as String?,
      city: json['city'] as String?,
      industry: json['industry'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'url': url,
      'organizer': organizer,
      'whenStart': whenStart?.toIso8601String(),
      'whenEnd': whenEnd?.toIso8601String(),
      'venue': venue,
      'city': city,
      'industry': industry,
    };
  }

  @override
  String toString() => 'EventItem(title: $title, city: $city, url: $url)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is EventItem && other.url == url;
  }

  @override
  int get hashCode => url.hashCode;

  /// Returns formatted date range string
  String get dateRange {
    if (whenStart == null) return 'Date TBA';

    final startStr = _formatDate(whenStart!);
    if (whenEnd != null && whenEnd != whenStart) {
      final endStr = _formatDate(whenEnd!);
      return '$startStr - $endStr';
    }

    return startStr;
  }

  String _formatDate(DateTime date) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  /// Returns location string (venue + city)
  String get location {
    if (venue != null && city != null) {
      return '$venue, $city';
    } else if (city != null) {
      return city!;
    } else if (venue != null) {
      return venue!;
    }
    return 'Location TBA';
  }
}
