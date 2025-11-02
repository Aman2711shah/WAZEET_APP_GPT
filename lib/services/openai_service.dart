import 'package:flutter/foundation.dart';

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:wazeet/config/app_config.dart';

class OpenAIService {
  static const String _apiUrl = 'https://api.openai.com/v1/chat/completions';

  /// Get AI-powered free zone recommendations based on business setup details
  static Future<String> getFreezoneRecommendations({
    required List<String> businessActivities,
    required int shareholdersCount,
    required int visaCount,
    required int licenseTenureYears,
    required String entityType,
    required String emirate,
  }) async {
    try {
      final prompt = _buildPrompt(
        businessActivities: businessActivities,
        shareholdersCount: shareholdersCount,
        visaCount: visaCount,
        licenseTenureYears: licenseTenureYears,
        entityType: entityType,
        emirate: emirate,
      );

      // Check if API key is configured
      if (!AppConfig.hasOpenAiKey) {
        debugPrint('OpenAI API key not configured, using fallback recommendations');
        return _getFallbackRecommendation(
          businessActivities: businessActivities,
          emirate: emirate,
        );
      }

      final response = await http.post(
        Uri.parse(_apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${AppConfig.openAiApiKey}',
        },
        body: jsonEncode({
          'model': 'gpt-4',
          'messages': [
            {
              'role': 'system',
              'content':
                  'You are a UAE business setup expert specializing in free zone recommendations. Provide detailed, accurate, and cost-optimized recommendations for entrepreneurs looking to establish their business in UAE free zones. Focus on pricing, benefits, and suitability based on their specific requirements.',
            },
            {'role': 'user', 'content': prompt},
          ],
          'temperature': 0.7,
          'max_tokens': 1500,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final recommendation = data['choices'][0]['message']['content'];
        return recommendation;
      } else {
        throw Exception(
          'Failed to get recommendations: ${response.statusCode}',
        );
      }
    } catch (e) {
      debugPrint('Error getting AI recommendations: $e');
      return _getFallbackRecommendation(
        businessActivities: businessActivities,
        emirate: emirate,
      );
    }
  }

  static String _buildPrompt({
    required List<String> businessActivities,
    required int shareholdersCount,
    required int visaCount,
    required int licenseTenureYears,
    required String entityType,
    required String emirate,
  }) {
    return '''
I need recommendations for the most suitable and cost-optimized UAE free zones based on the following business setup requirements:

**Business Details:**
- Business Activities: ${businessActivities.join(', ')}
- Number of Shareholders: $shareholdersCount
- Number of Visas Required: $visaCount
- License Tenure: $licenseTenureYears year(s)
- Entity Type: $entityType
- Preferred Emirate: $emirate

**Please provide:**
1. **Top 3 Recommended Free Zones** with detailed reasoning for each
2. **Estimated Pricing Breakdown** for each free zone including:
   - License fees
   - Visa costs
   - Office space requirements and costs
   - Setup fees
   - Annual renewal costs
3. **Cost Comparison** between the options
4. **Key Benefits** of each free zone for these specific activities
5. **Total Estimated First Year Cost** for each option
6. **Best Value Recommendation** with justification

Format the response in a clear, structured way with sections and bullet points for easy reading.
''';
  }

  static String _getFallbackRecommendation({
    required List<String> businessActivities,
    required String emirate,
  }) {
    // Fallback recommendations if API fails
    final activitiesLower = businessActivities
        .map((e) => e.toLowerCase())
        .toList();

    String zone1 = 'DMCC (Dubai Multi Commodities Centre)';
    String zone2 = 'IFZA (International Free Zone Authority)';
    String zone3 = 'RAKEZ (Ras Al Khaimah Economic Zone)';

    if (activitiesLower.any(
      (a) => a.contains('tech') || a.contains('software') || a.contains('it'),
    )) {
      zone1 = 'Dubai Silicon Oasis';
      zone2 = 'DTEC (Dubai Technology Entrepreneur Campus)';
      zone3 = 'Sharjah Research Technology and Innovation Park';
    } else if (activitiesLower.any(
      (a) =>
          a.contains('trading') || a.contains('import') || a.contains('export'),
    )) {
      zone1 = 'Jebel Ali Free Zone (JAFZA)';
      zone2 = 'Dubai CommerCity';
      zone3 = 'Hamriyah Free Zone';
    } else if (activitiesLower.any(
      (a) =>
          a.contains('media') ||
          a.contains('creative') ||
          a.contains('marketing'),
    )) {
      zone1 = 'Dubai Media City';
      zone2 = 'twofour54 Abu Dhabi';
      zone3 = 'Dubai Production City';
    }

    if (emirate.toLowerCase().contains('abu dhabi')) {
      zone2 = 'ADGM (Abu Dhabi Global Market)';
      zone3 = 'Masdar City Free Zone';
    } else if (emirate.toLowerCase().contains('ras al khaimah')) {
      zone1 = 'RAKEZ Business Zone';
      zone3 = 'RAK Maritime City';
    }

    return '''
**Recommended Free Zones for Your Business:**

**1. $zone1**
• Well-suited for your business activities
• Estimated first-year cost: AED 15,000 - 25,000
• Includes: Trade license, office space, and visa processing
• Benefits: Strong business ecosystem, easy setup process

**2. $zone2**
• Cost-effective option with good infrastructure
• Estimated first-year cost: AED 12,000 - 20,000
• Includes: Basic license package and flexi-desk options
• Benefits: Lower setup costs, flexible office solutions

**3. $zone3**
• Competitive pricing for startups
• Estimated first-year cost: AED 10,000 - 18,000
• Includes: Standard license and shared facilities
• Benefits: Budget-friendly, quick processing

**Note:** AI recommendations are temporarily unavailable. These are general estimates. Please contact our business consultants for detailed, up-to-date pricing and personalized guidance.

For accurate quotes and to proceed with setup, we recommend scheduling a consultation with our free zone experts.
''';
  }
}
