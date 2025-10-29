import 'package:cloud_firestore/cloud_firestore.dart';

/// Helper class to create sample data in Firestore for testing
class FirestoreDataSeeder {
  static Future<void> seedSampleData() async {
    final firestore = FirebaseFirestore.instance;

    // Sample activities - Comprehensive list of business activities
    final activities = [
      // Trading & Commerce
      'General Trading',
      'Import & Export',
      'E-commerce',
      'Wholesale Trading',
      'Retail Trading',
      'Trading of Building Materials',
      'Trading of Electronics',
      'Trading of Textiles',
      'Trading of Food Products',
      'Trading of Medical Equipment',
      'Trading of Industrial Equipment',
      'Trading of Automotive Parts',

      // Professional Services
      'Consultancy Services',
      'Management Consultancy',
      'Business Development Consultancy',
      'HR Consultancy',
      'Legal Consultancy',
      'Financial Consultancy',
      'Tax Consultancy',
      'Accounting Services',
      'Auditing Services',
      'Bookkeeping Services',

      // Technology & IT
      'IT Services',
      'Software Development',
      'Web Development',
      'Mobile App Development',
      'IT Consultancy',
      'Cloud Services',
      'Cybersecurity Services',
      'Data Analytics',
      'Artificial Intelligence Services',
      'Blockchain Services',
      'Digital Transformation Services',

      // Marketing & Media
      'Marketing & Advertising',
      'Digital Marketing',
      'Social Media Marketing',
      'Brand Management',
      'Public Relations',
      'Event Management',
      'Media Production',
      'Content Creation',
      'Graphic Design Services',
      'Photography Services',
      'Video Production',

      // Real Estate & Construction
      'Real Estate',
      'Real Estate Brokerage',
      'Property Management',
      'Real Estate Development',
      'Construction',
      'Civil Engineering',
      'Architectural Services',
      'Interior Design',
      'MEP Services',
      'Project Management',
      'Facility Management',

      // Manufacturing & Production
      'Manufacturing',
      'Industrial Manufacturing',
      'Food Manufacturing',
      'Textile Manufacturing',
      'Electronics Manufacturing',
      'Chemical Manufacturing',
      'Packaging Services',
      'Assembly Services',

      // Food & Hospitality
      'Food & Beverage',
      'Restaurant Services',
      'Catering Services',
      'Food Processing',
      'Hotel Management',
      'Tourism Services',
      'Event Catering',

      // Healthcare & Wellness
      'Healthcare Services',
      'Medical Services',
      'Dental Services',
      'Pharmacy Services',
      'Medical Laboratory Services',
      'Healthcare Consultancy',
      'Wellness Services',
      'Fitness Services',

      // Education & Training
      'Educational Services',
      'Training Services',
      'Corporate Training',
      'E-learning Services',
      'Coaching Services',
      'Educational Consultancy',
      'Vocational Training',

      // Financial Services
      'Financial Services',
      'Investment Services',
      'Insurance Services',
      'Banking Services',
      'Financial Advisory',
      'Wealth Management',
      'Payment Services',
      'Fintech Services',

      // Transportation & Logistics
      'Transportation',
      'Logistics Services',
      'Freight Forwarding',
      'Shipping Services',
      'Warehousing Services',
      'Courier Services',
      'Supply Chain Management',
      'Fleet Management',

      // Tourism & Travel
      'Tourism & Travel',
      'Travel Agency',
      'Tour Operating',
      'Visa Services',
      'Ticketing Services',
      'Tourism Consultancy',

      // Energy & Environment
      'Energy Services',
      'Renewable Energy',
      'Solar Energy Services',
      'Environmental Consultancy',
      'Waste Management',
      'Recycling Services',
      'Water Treatment Services',

      // Automotive
      'Automotive Services',
      'Car Rental Services',
      'Vehicle Maintenance',
      'Auto Parts Trading',
      'Car Wash Services',

      // Beauty & Personal Care
      'Beauty Services',
      'Salon Services',
      'Spa Services',
      'Personal Care Services',
      'Cosmetics Trading',

      // Agriculture & Food Production
      'Agricultural Services',
      'Farming Activities',
      'Agricultural Trading',
      'Aquaculture',
      'Horticulture Services',

      // Legal & Compliance
      'Legal Services',
      'Law Firm Services',
      'Notary Services',
      'Compliance Services',
      'Intellectual Property Services',

      // Security Services
      'Security Services',
      'Security Consultancy',
      'Security Systems Installation',
      'Guard Services',

      // Telecommunications
      'Telecommunication Services',
      'Telecom Consultancy',
      'Network Services',
      'Communication Services',

      // Entertainment & Recreation
      'Entertainment Services',
      'Recreation Services',
      'Sports Services',
      'Gaming Services',
      'Cinema Services',

      // Printing & Publishing
      'Printing Services',
      'Publishing Services',
      'Design and Printing',
      'Digital Printing',

      // Cleaning & Maintenance
      'Cleaning Services',
      'Maintenance Services',
      'Pest Control Services',
      'Building Maintenance',

      // Recruitment & Staffing
      'Recruitment Services',
      'Staffing Services',
      'Headhunting Services',
      'Manpower Supply',

      // Other Services
      'Research and Development',
      'Laboratory Services',
      'Testing and Inspection',
      'Translation Services',
      'Secretarial Services',
      'Administrative Services',
      'Call Center Services',
      'Document Clearing Services',
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
