import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Model for user statistics
class UserStats {
  final int activeServices;
  final int pendingTasks;
  final int documents;
  final List<UserActivity> recentActivity;

  const UserStats({
    this.activeServices = 0,
    this.pendingTasks = 0,
    this.documents = 0,
    this.recentActivity = const [],
  });
}

/// Model for user activity
class UserActivity {
  final String id;
  final String title;
  final String status;
  final String subtitle;
  final double progress;
  final DateTime timestamp;

  const UserActivity({
    required this.id,
    required this.title,
    required this.status,
    required this.subtitle,
    required this.progress,
    required this.timestamp,
  });
}

/// Provider for user statistics
final userStatsProvider =
    StateNotifierProvider<UserStatsNotifier, UserStats>((ref) {
  return UserStatsNotifier();
});

/// Notifier to manage user statistics
class UserStatsNotifier extends StateNotifier<UserStats> {
  UserStatsNotifier() : super(const UserStats()) {
    _loadStats();
  }

  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  /// Load user statistics from Firestore
  Future<void> _loadStats() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        // No user, keep default zero stats
        state = const UserStats();
        return;
      }

      // Fetch service requests for this user
      final serviceRequests = await _firestore
          .collection('service_requests')
          .where('userId', isEqualTo: user.uid)
          .get();

      // Count active services (not completed or cancelled)
      final activeServices = serviceRequests.docs
          .where((doc) {
            final status = doc.data()['status']?.toString().toLowerCase() ?? '';
            return status != 'completed' &&
                status != 'complete' &&
                status != 'cancelled';
          })
          .length;

      // Count pending tasks (submitted or processing)
      final pendingTasks = serviceRequests.docs
          .where((doc) {
            final status = doc.data()['status']?.toString().toLowerCase() ?? '';
            return status == 'submitted' ||
                status == 'processing' ||
                status == 'under_process';
          })
          .length;

      // Fetch documents for this user
      final documentsQuery = await _firestore
          .collection('documents')
          .where('userId', isEqualTo: user.uid)
          .get();

      final documents = documentsQuery.docs.length;

      // Build recent activity list
      final recentActivity = serviceRequests.docs
          .map((doc) {
            final data = doc.data();
            return UserActivity(
              id: doc.id,
              title: data['serviceName']?.toString() ?? 'Service Request',
              status: _formatStatus(data['status']?.toString() ?? 'submitted'),
              subtitle: _getSubtitle(data),
              progress: _getProgress(data['status']?.toString() ?? 'submitted'),
              timestamp: (data['timestamp'] as Timestamp?)?.toDate() ??
                  DateTime.now(),
            );
          })
          .toList()
        ..sort((a, b) => b.timestamp.compareTo(a.timestamp)); // Most recent first

      state = UserStats(
        activeServices: activeServices,
        pendingTasks: pendingTasks,
        documents: documents,
        recentActivity: recentActivity.take(3).toList(), // Top 3
      );
    } catch (e) {
      debugPrint('Error loading user stats: $e');
      // Keep default empty stats on error
      state = const UserStats();
    }
  }

  String _formatStatus(String status) {
    switch (status.toLowerCase()) {
      case 'processing':
      case 'under_process':
        return 'In Progress';
      case 'approved':
      case 'completed':
      case 'complete':
        return 'Completed';
      case 'submitted':
        return 'Submitted';
      default:
        return 'Pending';
    }
  }

  String _getSubtitle(Map<String, dynamic> data) {
    final status = data['status']?.toString().toLowerCase() ?? '';
    
    if (status == 'completed' || status == 'complete') {
      final completedDate = (data['completedDate'] as Timestamp?)?.toDate();
      if (completedDate != null) {
        return 'Completed on ${_formatDate(completedDate)}';
      }
      return 'Completed';
    }
    
    if (status == 'processing' || status == 'under_process') {
      final estimatedDays = data['estimatedDays'] as int? ?? 3;
      return 'Expected completion: $estimatedDays days';
    }
    
    final docsRequired = data['documentsRequired'] as int? ?? 0;
    if (docsRequired > 0) {
      return '$docsRequired documents pending';
    }
    
    return 'Awaiting processing';
  }

  double _getProgress(String status) {
    switch (status.toLowerCase()) {
      case 'submitted':
        return 0.2;
      case 'processing':
      case 'under_process':
        return 0.6;
      case 'approved':
        return 0.9;
      case 'completed':
      case 'complete':
        return 1.0;
      default:
        return 0.1;
    }
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

  /// Refresh statistics
  Future<void> refresh() async {
    await _loadStats();
  }
}
