// lib/community/models.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class UserProfile {
  final String uid;
  final String displayName;
  final String photoURL;
  final String headline;
  final List<String> industries;
  final String location;
  final DateTime createdAt;
  final DateTime lastActiveAt;
  final int connectionsCount;
  final bool isDiscoverable;
  int mutualConnectionsCount;

  UserProfile({
    required this.uid,
    required this.displayName,
    required this.photoURL,
    required this.headline,
    required this.industries,
    required this.location,
    required this.createdAt,
    required this.lastActiveAt,
    required this.connectionsCount,
    this.isDiscoverable = true,
    this.mutualConnectionsCount = 0,
  });

  factory UserProfile.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserProfile(
      uid: doc.id,
      displayName: data['displayName'] ?? '',
      photoURL: data['photoURL'] ?? '',
      headline: data['headline'] ?? '',
      industries: List<String>.from(data['industries'] ?? []),
      location: data['location'] ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      lastActiveAt:
          (data['lastActiveAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      connectionsCount: data['connectionsCount'] ?? 0,
      isDiscoverable: data['isDiscoverable'] ?? true,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'displayName': displayName,
      'photoURL': photoURL,
      'headline': headline,
      'industries': industries,
      'location': location,
      'createdAt': Timestamp.fromDate(createdAt),
      'lastActiveAt': Timestamp.fromDate(lastActiveAt),
      'connectionsCount': connectionsCount,
      'isDiscoverable': isDiscoverable,
    };
  }
}

enum ConnectionState {
  pending,
  accepted,
  ignored,
  blocked;

  String toFirestore() => name;

  static ConnectionState fromFirestore(String value) {
    return ConnectionState.values.firstWhere(
      (e) => e.name == value,
      orElse: () => ConnectionState.pending,
    );
  }
}

class Connection {
  final String docId;
  final String a;
  final String b;
  final ConnectionState state;
  final DateTime createdAt;
  final DateTime updatedAt;

  Connection({
    required this.docId,
    required this.a,
    required this.b,
    required this.state,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Connection.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Connection(
      docId: doc.id,
      a: data['a'] ?? '',
      b: data['b'] ?? '',
      state: ConnectionState.fromFirestore(data['state'] ?? 'pending'),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'a': a,
      'b': b,
      'state': state.toFirestore(),
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }
}

class NewsItem {
  final String id;
  final String title;
  final String source;
  final String? imageUrl;
  final String snippet;
  final String url;
  final DateTime publishedAt;

  NewsItem({
    required this.id,
    required this.title,
    required this.source,
    this.imageUrl,
    required this.snippet,
    required this.url,
    required this.publishedAt,
  });

  factory NewsItem.fromJson(Map<String, dynamic> json) {
    return NewsItem(
      id: json['cacheId'] ?? json['link'] ?? '',
      title: json['title'] ?? '',
      source: json['displayLink'] ?? json['source'] ?? '',
      imageUrl: json['pagemap']?['cse_image']?[0]?['src'] ?? json['image'],
      snippet: json['snippet'] ?? '',
      url: json['link'] ?? '',
      publishedAt: json['publishedAt'] != null
          ? DateTime.parse(json['publishedAt'])
          : DateTime.now(),
    );
  }

  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(publishedAt);

    if (difference.inDays > 365) {
      return '${(difference.inDays / 365).floor()}y ago';
    } else if (difference.inDays > 30) {
      return '${(difference.inDays / 30).floor()}mo ago';
    } else if (difference.inDays > 0) {
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

class EventItem {
  final String id;
  final String title;
  final DateTime start;
  final DateTime? end;
  final String organizer;
  final String location;
  final String? imageUrl;
  final String? description;
  final String sourceUrl;

  EventItem({
    required this.id,
    required this.title,
    required this.start,
    this.end,
    required this.organizer,
    required this.location,
    this.imageUrl,
    this.description,
    required this.sourceUrl,
  });

  factory EventItem.fromJson(Map<String, dynamic> json) {
    return EventItem(
      id: json['id'] ?? json['link'] ?? '',
      title: json['title'] ?? json['summary'] ?? '',
      start: json['start'] != null
          ? DateTime.parse(json['start'])
          : DateTime.now(),
      end: json['end'] != null ? DateTime.parse(json['end']) : null,
      organizer: json['organizer'] ?? json['creator'] ?? '',
      location: json['location'] ?? json['venue'] ?? '',
      imageUrl: json['imageUrl'] ?? json['image'],
      description: json['description'] ?? json['snippet'],
      sourceUrl: json['link'] ?? json['htmlLink'] ?? '',
    );
  }

  String get formattedDate {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final startDay = DateTime(start.year, start.month, start.day);

    if (startDay == today) {
      return 'Today ${_formatTime(start)}';
    } else if (startDay == today.add(const Duration(days: 1))) {
      return 'Tomorrow ${_formatTime(start)}';
    } else {
      return '${_monthNames[start.month - 1]} ${start.day}, ${start.year}';
    }
  }

  String _formatTime(DateTime dt) {
    final hour = dt.hour > 12 ? dt.hour - 12 : (dt.hour == 0 ? 12 : dt.hour);
    final minute = dt.minute.toString().padLeft(2, '0');
    final period = dt.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $period';
  }

  static const _monthNames = [
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
}

class Paginated<T> {
  final List<T> items;
  final String? nextPageToken;
  final int totalResults;

  Paginated({required this.items, this.nextPageToken, this.totalResults = 0});

  bool get hasMore => nextPageToken != null && nextPageToken!.isNotEmpty;
}
