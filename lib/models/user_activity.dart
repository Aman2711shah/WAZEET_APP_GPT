import 'package:flutter/material.dart';

class UserActivity {
  final String id;
  final String title;
  final String status;
  final String subtitle;
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
      'iconCodePoint': icon.codePoint,
      // Use toARGB32() to avoid deprecated Color.value access
      'colorValue': color.toARGB32(),
      'progress': progress,
      'createdAt': createdAt.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
    };
  }

  factory UserActivity.fromJson(Map<String, dynamic> json) {
    return UserActivity(
      id: json['id'] as String,
      title: json['title'] as String,
      status: json['status'] as String,
      subtitle: json['subtitle'] as String,
      icon: IconData(json['iconCodePoint'] as int, fontFamily: 'MaterialIcons'),
      color: Color(json['colorValue'] as int),
      progress: (json['progress'] as num).toDouble(),
      createdAt: DateTime.parse(json['createdAt'] as String),
      completedAt: json['completedAt'] != null
          ? DateTime.parse(json['completedAt'] as String)
          : null,
    );
  }
}
