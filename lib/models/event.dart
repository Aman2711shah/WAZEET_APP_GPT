import 'package:cloud_firestore/cloud_firestore.dart';

/// Represents a business event discovered automatically
class Event {
  final String id;
  final String eventName;
  final DateTime date;
  final String? time; // HH:MM format or null
  final EventLocation location;
  final String category; // Networking, Workshop, Conference, Competition, Other
  final String sourceURL;
  final String description;
  final int attendees;
  final DateTime discoveredAt;
  final DateTime lastUpdated;

  Event({
    required this.id,
    required this.eventName,
    required this.date,
    this.time,
    required this.location,
    required this.category,
    required this.sourceURL,
    required this.description,
    required this.attendees,
    required this.discoveredAt,
    required this.lastUpdated,
  });

  /// Create Event from Firestore document
  factory Event.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Event.fromJson(data, doc.id);
  }

  /// Create Event from JSON
  factory Event.fromJson(Map<String, dynamic> json, String docId) {
    return Event(
      id: docId,
      eventName: json['eventName'] ?? '',
      date: _parseDate(json['date']),
      time: json['time'],
      location: EventLocation.fromJson(json['location'] ?? {}),
      category: json['category'] ?? 'Other',
      sourceURL: json['sourceURL'] ?? '',
      description: json['description'] ?? '',
      attendees: json['attendees'] ?? 0,
      discoveredAt: _parseTimestamp(json['discoveredAt']),
      lastUpdated: _parseTimestamp(json['lastUpdated']),
    );
  }

  /// Convert Event to JSON
  Map<String, dynamic> toJson() {
    return {
      'eventName': eventName,
      'date': _formatDate(date),
      'time': time,
      'location': location.toJson(),
      'category': category,
      'sourceURL': sourceURL,
      'description': description,
      'attendees': attendees,
      'discoveredAt': Timestamp.fromDate(discoveredAt),
      'lastUpdated': Timestamp.fromDate(lastUpdated),
    };
  }

  /// Check if event is upcoming (in the future)
  bool get isUpcoming => date.isAfter(DateTime.now());

  /// Check if event is today
  bool get isToday {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  /// Get human-readable date string
  String get formattedDate {
    final now = DateTime.now();
    final difference = date.difference(now).inDays;

    if (isToday) return 'Today';
    if (difference == 1) return 'Tomorrow';
    if (difference < 7) return '${date.day}/${date.month}/${date.year}';
    return '${date.day}/${date.month}/${date.year}';
  }

  /// Parse date string (YYYY-MM-DD)
  static DateTime _parseDate(dynamic value) {
    if (value is String) {
      return DateTime.parse(value);
    } else if (value is Timestamp) {
      return value.toDate();
    }
    return DateTime.now();
  }

  /// Parse Firestore Timestamp
  static DateTime _parseTimestamp(dynamic value) {
    if (value is Timestamp) {
      return value.toDate();
    } else if (value is String) {
      return DateTime.parse(value);
    }
    return DateTime.now();
  }

  /// Format date to YYYY-MM-DD string
  static String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}

/// Represents the location of an event
class EventLocation {
  final String venue;
  final String? address;

  EventLocation({required this.venue, this.address});

  factory EventLocation.fromJson(Map<String, dynamic> json) {
    return EventLocation(
      venue: json['venue'] ?? 'TBA',
      address: json['address'],
    );
  }

  Map<String, dynamic> toJson() {
    return {'venue': venue, 'address': address};
  }

  /// Get display text for location
  String get displayText {
    if (address != null && address!.isNotEmpty) {
      return '$venue, $address';
    }
    return venue;
  }
}
