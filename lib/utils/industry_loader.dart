import 'dart:convert';
import 'package:flutter/services.dart';

class ActivityData {
  final String name;
  final String description;

  ActivityData({required this.name, required this.description});
}

class IndustryData {
  final String industry;
  final String? industryArabic;
  final List<String> activities;
  final Map<String, String> activityDescriptions;

  IndustryData({
    required this.industry,
    this.industryArabic,
    required this.activities,
    this.activityDescriptions = const {},
  });

  static Future<List<IndustryData>> loadFromAsset(
    String assetPath, {
    bool includeDescriptions = false,
  }) async {
    final raw = await rootBundle.loadString(assetPath);
    final List<dynamic> json = jsonDecode(raw);

    // Check if this is the new flat format (array of activities directly)
    if (json.isNotEmpty &&
        json.first is Map &&
        json.first.containsKey('code')) {
      // New format: flat array of activities
      final actsByCategory = <String, List<Map<String, dynamic>>>{};

      for (final item in json) {
        if (item is! Map<String, dynamic>) continue;

        final category = (item['category'] as String?) ?? 'Other';
        actsByCategory.putIfAbsent(category, () => []);
        actsByCategory[category]!.add(item);
      }

      return actsByCategory.entries.map((entry) {
        final acts = <String>[];
        final descriptions = <String, String>{};

        for (final activity in entry.value) {
          final name = activity['name'] as String?;
          if (name != null && name.isNotEmpty) {
            acts.add(name);
            if (includeDescriptions) {
              final description = activity['description'] as String?;
              if (description != null && description.isNotEmpty) {
                descriptions[name] = description;
              }
            }
          }
        }

        return IndustryData(
          industry: entry.key,
          industryArabic: null,
          activities: acts,
          activityDescriptions: descriptions,
        );
      }).toList();
    }

    // Old format: array of industries with business_activities
    return json.map((e) {
      final businessActivities = e['business_activities'] as List<dynamic>?;
      final acts = <String>[];
      final descriptions = <String, String>{};

      if (businessActivities != null) {
        for (final activity in businessActivities) {
          final name = activity['Activity Name'] as String?;
          if (name != null) {
            acts.add(name);
            if (includeDescriptions) {
              final description = activity['Description'] as String?;
              if (description != null) {
                descriptions[name] = description;
              }
            }
          }
        }
      }

      return IndustryData(
        industry: e['industry'] as String,
        industryArabic: e['industry_arabic'] as String?,
        activities: acts,
        activityDescriptions: descriptions,
      );
    }).toList();
  }
}

Future<List<String>> loadAllActivities(String assetPath) async {
  final data = await IndustryData.loadFromAsset(assetPath);
  final acts = <String>{};
  for (final ind in data) {
    acts.addAll(ind.activities);
  }
  return acts.toList()..sort();
}

Future<List<ActivityData>> loadAllActivitiesWithDescriptions(
  String assetPath,
) async {
  final data = await IndustryData.loadFromAsset(
    assetPath,
    includeDescriptions: true,
  );

  final activityMap = <String, String>{};

  for (final industry in data) {
    activityMap.addAll(industry.activityDescriptions);
  }

  final result = activityMap.entries
      .map((e) => ActivityData(name: e.key, description: e.value))
      .toList();

  result.sort((a, b) => a.name.compareTo(b.name));

  return result;
}
