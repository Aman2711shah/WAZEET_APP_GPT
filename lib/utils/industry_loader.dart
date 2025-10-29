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

  IndustryData({
    required this.industry,
    this.industryArabic,
    required this.activities,
  });

  static Future<List<IndustryData>> loadFromAsset(String assetPath) async {
    final raw = await rootBundle.loadString(assetPath);
    final List<dynamic> json = jsonDecode(raw);
    return json.map((e) {
      final acts =
          (e['business_activities'] as List<dynamic>?)
              ?.map((a) => a['Activity Name'] as String)
              .toList() ??
          [];
      return IndustryData(
        industry: e['industry'] as String,
        industryArabic: e['industry_arabic'] as String?,
        activities: acts,
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
  final raw = await rootBundle.loadString(assetPath);
  final List<dynamic> json = jsonDecode(raw);

  final activityMap = <String, String>{};

  for (final industry in json) {
    final activities = industry['business_activities'] as List<dynamic>?;
    if (activities != null) {
      for (final activity in activities) {
        final name = activity['Activity Name'] as String?;
        final description = activity['Description'] as String?;
        if (name != null && description != null) {
          activityMap[name] = description;
        }
      }
    }
  }

  final result = activityMap.entries
      .map((e) => ActivityData(name: e.key, description: e.value))
      .toList();

  result.sort((a, b) => a.name.compareTo(b.name));

  return result;
}
