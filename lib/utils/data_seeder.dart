import 'package:cloud_firestore/cloud_firestore.dart';

/// Helper class to create sample data in Firestore for testing
class FirestoreDataSeeder {
  static Future<void> seedSampleData() async {
    final firestore = FirebaseFirestore.instance;

    // Sample activities
    final activities = [
      'General Trading',
      'Import & Export',
      'Consultancy Services',
      'IT Services',
      'Marketing & Advertising',
      'Real Estate',
      'E-commerce',
      'Manufacturing',
      'Food & Beverage',
      'Healthcare Services',
      'Educational Services',
      'Financial Services',
      'Tourism & Travel',
      'Transportation',
      'Construction',
    ];

    // Sample freezones
    final freezones = [
      'IFZA (ADGM)',
      'RAKEZ',
      'SHAMS',
      'DMCC',
      'JAFZA',
      'Dubai South',
      'AJMAN Free Zone',
      'RAK ICC',
      'FUJAIRAH FREE ZONE',
      'UAE Mainland',
      'Abu Dhabi Global Market',
      'Dubai International Financial Centre',
      'Sharjah Airport International Free Zone',
    ];

    try {
      // Seed activities
      final activitiesRef = firestore.collection('activities');
      for (int i = 0; i < activities.length; i++) {
        await activitiesRef.doc('activity_$i').set({
          'name': activities[i],
          'description': 'Business activity: ${activities[i]}',
          'created_at': FieldValue.serverTimestamp(),
        });
      }

      // Seed freezones
      final freezonesRef = firestore.collection('freezones');
      for (int i = 0; i < freezones.length; i++) {
        await freezonesRef.doc('freezone_$i').set({
          'name': freezones[i],
          'description': 'Free zone: ${freezones[i]}',
          'created_at': FieldValue.serverTimestamp(),
        });
      }

      print('Sample data seeded successfully!');
    } catch (e) {
      print('Error seeding data: $e');
    }
  }
}
