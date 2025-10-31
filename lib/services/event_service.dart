import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/event.dart';

/// Provider for EventService singleton
final eventServiceProvider = Provider<EventService>((ref) {
  return EventService();
});

/// Provider for upcoming events stream
final upcomingEventsProvider = StreamProvider<List<Event>>((ref) {
  final service = ref.watch(eventServiceProvider);
  return service.getUpcomingEventsStream();
});

/// Provider for events by category stream
final eventsByCategoryProvider = StreamProvider.family<List<Event>, String>((
  ref,
  category,
) {
  final service = ref.watch(eventServiceProvider);
  return service.getEventsByCategoryStream(category);
});

/// Service for managing discovered events from Firestore
class EventService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'discoveredEvents';

  /// Get all events as a stream (real-time updates)
  Stream<List<Event>> getEventsStream() {
    return _firestore
        .collection(_collection)
        .orderBy('date', descending: false)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) => Event.fromFirestore(doc)).toList();
        });
  }

  /// Get only upcoming events as a stream
  Stream<List<Event>> getUpcomingEventsStream() {
    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);

    return _firestore
        .collection(_collection)
        .where('date', isGreaterThanOrEqualTo: _formatDate(todayStart))
        .orderBy('date', descending: false)
        .limit(20)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) => Event.fromFirestore(doc)).toList();
        });
  }

  /// Get events by category as a stream
  Stream<List<Event>> getEventsByCategoryStream(String category) {
    return _firestore
        .collection(_collection)
        .where('category', isEqualTo: category)
        .orderBy('date', descending: false)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) => Event.fromFirestore(doc)).toList();
        });
  }

  /// Get a single event by ID
  Future<Event?> getEventById(String id) async {
    try {
      final doc = await _firestore.collection(_collection).doc(id).get();
      if (doc.exists) {
        return Event.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      print('Error getting event by ID: $e');
      return null;
    }
  }

  /// Get all events (one-time fetch)
  Future<List<Event>> getAllEvents() async {
    try {
      final snapshot = await _firestore
          .collection(_collection)
          .orderBy('date', descending: false)
          .get();
      return snapshot.docs.map((doc) => Event.fromFirestore(doc)).toList();
    } catch (e) {
      print('Error getting all events: $e');
      return [];
    }
  }

  /// Get upcoming events (one-time fetch)
  Future<List<Event>> getUpcomingEvents() async {
    try {
      final now = DateTime.now();
      final todayStart = DateTime(now.year, now.month, now.day);

      final snapshot = await _firestore
          .collection(_collection)
          .where('date', isGreaterThanOrEqualTo: _formatDate(todayStart))
          .orderBy('date', descending: false)
          .limit(20)
          .get();
      return snapshot.docs.map((doc) => Event.fromFirestore(doc)).toList();
    } catch (e) {
      print('Error getting upcoming events: $e');
      return [];
    }
  }

  /// Search events by name
  Stream<List<Event>> searchEventsByName(String query) {
    if (query.isEmpty) {
      return getUpcomingEventsStream();
    }

    return _firestore
        .collection(_collection)
        .orderBy('eventName')
        .snapshots()
        .map((snapshot) {
          final events = snapshot.docs
              .map((doc) => Event.fromFirestore(doc))
              .toList();
          // Client-side filtering for case-insensitive search
          return events
              .where(
                (event) =>
                    event.eventName.toLowerCase().contains(
                      query.toLowerCase(),
                    ) ||
                    event.description.toLowerCase().contains(
                      query.toLowerCase(),
                    ),
              )
              .toList();
        });
  }

  /// Get distinct categories
  Future<List<String>> getCategories() async {
    try {
      final snapshot = await _firestore.collection(_collection).get();
      final categories = snapshot.docs
          .map((doc) => (doc.data()['category'] as String?) ?? 'Other')
          .toSet()
          .toList();
      categories.sort();
      return categories;
    } catch (e) {
      print('Error getting categories: $e');
      return ['Networking', 'Workshop', 'Conference', 'Competition', 'Other'];
    }
  }

  /// Increment attendees count (when user registers)
  Future<void> incrementAttendees(String eventId) async {
    try {
      await _firestore.collection(_collection).doc(eventId).update({
        'attendees': FieldValue.increment(1),
      });
    } catch (e) {
      print('Error incrementing attendees: $e');
    }
  }

  /// Format date to YYYY-MM-DD string for Firestore queries
  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}
