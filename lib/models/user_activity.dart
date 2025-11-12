import 'package:flutter/material.dart';

class UserActivity {
  // Icon mapping for const icon data
  static const _iconMap = <String, IconData>{
    'task': Icons.task_alt,
    'task_alt': Icons.task_alt,
    'service': Icons.business_center,
    'business_center': Icons.business_center,
    'payment': Icons.payment,
    'check_circle': Icons.check_circle,
    'pending': Icons.pending,
    'access_time': Icons.access_time,
    'upload_file': Icons.upload_file,
    'description': Icons.description,
    'assignment': Icons.assignment,
    'account_balance': Icons.account_balance,
    'receipt': Icons.receipt,
    'credit_card': Icons.credit_card,
    'done': Icons.done,
    'hourglass_empty': Icons.hourglass_empty,
    'error': Icons.error,
    'warning': Icons.warning,
    'info': Icons.info,
    'help_outline': Icons.help_outline,
  };

  final String id;
  final String title;
  final String status;
  final String subtitle;
  final String iconName;
  final IconData icon;
  final Color color;
  final double progress;
  final DateTime createdAt;
  final DateTime? completedAt;

  UserActivity({
    required this.id,
    required this.title,
    required this.status,
    required this.subtitle,
    required this.iconName,
    required this.icon,
    required this.color,
    required this.progress,
    required this.createdAt,
    this.completedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'status': status,
      'subtitle': subtitle,
      'iconName': iconName,
      // Use toARGB32() to avoid deprecated Color.value access
      'colorValue': color.toARGB32(),
      'progress': progress,
      'createdAt': createdAt.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
    };
  }

  factory UserActivity.fromJson(Map<String, dynamic> json) {
    final String iconKey = json['iconName'] as String? ?? 'help_outline';
    return UserActivity(
      id: json['id'] as String,
      title: json['title'] as String,
      status: json['status'] as String,
      subtitle: json['subtitle'] as String,
      iconName: iconKey,
      icon: _iconMap[iconKey] ?? Icons.help_outline,
      color: Color(json['colorValue'] as int),
      progress: (json['progress'] as num).toDouble(),
      createdAt: DateTime.parse(json['createdAt'] as String),
      completedAt: json['completedAt'] != null
          ? DateTime.parse(json['completedAt'] as String)
          : null,
    );
  }
}
