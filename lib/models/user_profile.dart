/// User profile model containing all editable profile information
class UserProfile {
  final String id;
  final String name;
  final String email;
  final String? title;
  final String? bio;
  final String? phone;
  final String? countryCode;
  final String? photoUrl;
  final String? linkedInUrl;
  final String? twitterUrl;
  final String? instagramUrl;
  final String? websiteUrl;
  final bool isDarkMode;
  final String? company;
  final String? location;
  // Company profile fields (optional)
  final String? companyTagline;
  final String? companySize; // e.g., "50–100 employees"
  final String? companyFounded; // e.g., "2019"
  final String? companyHeadquarters; // e.g., "Dubai, UAE"
  final String? companyLogoUrl;
  final String? designation;
  final String? qualification;
  final List<String> industries; // User's preferred industries
  final List<String> skills;
  final List<String> interests;
  final String? coverImageUrl;
  final int connectionsCount;
  final int followersCount;
  final int postsCount;
  final DateTime? joinedDate;
  final bool isVerified;

  const UserProfile({
    required this.id,
    required this.name,
    required this.email,
    this.title,
    this.bio,
    this.phone,
    this.countryCode,
    this.photoUrl,
    this.linkedInUrl,
    this.twitterUrl,
    this.instagramUrl,
    this.websiteUrl,
    this.isDarkMode = false,
    this.company,
    this.location,
    this.companyTagline,
    this.companySize,
    this.companyFounded,
    this.companyHeadquarters,
    this.companyLogoUrl,
    this.designation,
    this.qualification,
    this.industries = const [],
    this.skills = const [],
    this.interests = const [],
    this.coverImageUrl,
    this.connectionsCount = 0,
    this.followersCount = 0,
    this.postsCount = 0,
    this.joinedDate,
    this.isVerified = false,
  });

  UserProfile copyWith({
    String? id,
    String? name,
    String? email,
    String? title,
    String? bio,
    String? phone,
    String? countryCode,
    String? photoUrl,
    String? linkedInUrl,
    String? twitterUrl,
    String? instagramUrl,
    String? websiteUrl,
    bool? isDarkMode,
    String? company,
    String? location,
    String? companyTagline,
    String? companySize,
    String? companyFounded,
    String? companyHeadquarters,
    String? companyLogoUrl,
    String? designation,
    String? qualification,
    List<String>? industries,
    List<String>? skills,
    List<String>? interests,
    String? coverImageUrl,
    int? connectionsCount,
    int? followersCount,
    int? postsCount,
    DateTime? joinedDate,
    bool? isVerified,
  }) {
    return UserProfile(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      title: title ?? this.title,
      bio: bio ?? this.bio,
      phone: phone ?? this.phone,
      countryCode: countryCode ?? this.countryCode,
      photoUrl: photoUrl ?? this.photoUrl,
      linkedInUrl: linkedInUrl ?? this.linkedInUrl,
      twitterUrl: twitterUrl ?? this.twitterUrl,
      instagramUrl: instagramUrl ?? this.instagramUrl,
      websiteUrl: websiteUrl ?? this.websiteUrl,
      isDarkMode: isDarkMode ?? this.isDarkMode,
      company: company ?? this.company,
      location: location ?? this.location,
      companyTagline: companyTagline ?? this.companyTagline,
      companySize: companySize ?? this.companySize,
      companyFounded: companyFounded ?? this.companyFounded,
      companyHeadquarters: companyHeadquarters ?? this.companyHeadquarters,
      companyLogoUrl: companyLogoUrl ?? this.companyLogoUrl,
      designation: designation ?? this.designation,
      qualification: qualification ?? this.qualification,
      industries: industries ?? this.industries,
      skills: skills ?? this.skills,
      interests: interests ?? this.interests,
      coverImageUrl: coverImageUrl ?? this.coverImageUrl,
      connectionsCount: connectionsCount ?? this.connectionsCount,
      followersCount: followersCount ?? this.followersCount,
      postsCount: postsCount ?? this.postsCount,
      joinedDate: joinedDate ?? this.joinedDate,
      isVerified: isVerified ?? this.isVerified,
    );
  }

  String get initials {
    final names = name.split(' ');
    if (names.length >= 2) {
      return '${names[0][0]}${names[1][0]}'.toUpperCase();
    }
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'title': title,
      'bio': bio,
      'phone': phone,
      'countryCode': countryCode,
      'photoUrl': photoUrl,
      'linkedInUrl': linkedInUrl,
      'twitterUrl': twitterUrl,
      'instagramUrl': instagramUrl,
      'websiteUrl': websiteUrl,
      'isDarkMode': isDarkMode,
      'company': company,
      'location': location,
      'companyTagline': companyTagline,
      'companySize': companySize,
      'companyFounded': companyFounded,
      'companyHeadquarters': companyHeadquarters,
      'companyLogoUrl': companyLogoUrl,
      'designation': designation,
      'qualification': qualification,
      'industries': industries,
      'skills': skills,
      'interests': interests,
      'coverImageUrl': coverImageUrl,
      'connectionsCount': connectionsCount,
      'followersCount': followersCount,
      'postsCount': postsCount,
      'joinedDate': joinedDate?.toIso8601String(),
      'isVerified': isVerified,
    };
  }

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      title: json['title'] as String?,
      bio: json['bio'] as String?,
      phone: json['phone'] as String?,
      countryCode: json['countryCode'] as String?,
      photoUrl: json['photoUrl'] as String?,
      linkedInUrl: json['linkedInUrl'] as String?,
      twitterUrl: json['twitterUrl'] as String?,
      instagramUrl: json['instagramUrl'] as String?,
      websiteUrl: json['websiteUrl'] as String?,
      isDarkMode: json['isDarkMode'] as bool? ?? false,
      company: json['company'] as String?,
      location: json['location'] as String?,
      companyTagline: json['companyTagline'] as String?,
      companySize: json['companySize'] as String?,
      companyFounded: json['companyFounded'] as String?,
      companyHeadquarters: json['companyHeadquarters'] as String?,
      companyLogoUrl: json['companyLogoUrl'] as String?,
      designation: json['designation'] as String?,
      qualification: json['qualification'] as String?,
      industries: (json['industries'] as List<dynamic>?)?.cast<String>() ?? [],
      skills: (json['skills'] as List<dynamic>?)?.cast<String>() ?? [],
      interests: (json['interests'] as List<dynamic>?)?.cast<String>() ?? [],
      coverImageUrl: json['coverImageUrl'] as String?,
      connectionsCount: json['connectionsCount'] as int? ?? 0,
      followersCount: json['followersCount'] as int? ?? 0,
      postsCount: json['postsCount'] as int? ?? 0,
      joinedDate: json['joinedDate'] != null
          ? DateTime.parse(json['joinedDate'] as String)
          : null,
      isVerified: json['isVerified'] as bool? ?? false,
    );
  }
}

// Available industries
class Industry {
  final String id;
  final String name;
  final String icon;
  final String description;

  Industry({
    required this.id,
    required this.name,
    required this.icon,
    required this.description,
  });
}

// Predefined industries
final List<Industry> availableIndustries = [
  Industry(
    id: 'tech',
    name: 'Technology',
    icon: '💻',
    description: 'Software, IT, and Tech Startups',
  ),
  Industry(
    id: 'finance',
    name: 'Finance & Banking',
    icon: '💰',
    description: 'Banking, Investment, and Financial Services',
  ),
  Industry(
    id: 'retail',
    name: 'Retail & E-commerce',
    icon: '🛍️',
    description: 'Retail, Online Shopping, and Consumer Goods',
  ),
  Industry(
    id: 'realestate',
    name: 'Real Estate',
    icon: '🏢',
    description: 'Property, Construction, and Development',
  ),
  Industry(
    id: 'hospitality',
    name: 'Hospitality & Tourism',
    icon: '🏨',
    description: 'Hotels, Travel, and Tourism Services',
  ),
  Industry(
    id: 'healthcare',
    name: 'Healthcare',
    icon: '⚕️',
    description: 'Medical Services, Clinics, and Health Tech',
  ),
  Industry(
    id: 'education',
    name: 'Education',
    icon: '🎓',
    description: 'Schools, Training, and EdTech',
  ),
  Industry(
    id: 'food',
    name: 'Food & Beverage',
    icon: '🍽️',
    description: 'Restaurants, Catering, and Food Services',
  ),
  Industry(
    id: 'consulting',
    name: 'Consulting',
    icon: '📊',
    description: 'Business Consulting and Professional Services',
  ),
  Industry(
    id: 'media',
    name: 'Media & Marketing',
    icon: '📱',
    description: 'Advertising, PR, and Digital Marketing',
  ),
  Industry(
    id: 'logistics',
    name: 'Logistics & Transport',
    icon: '🚚',
    description: 'Shipping, Delivery, and Supply Chain',
  ),
  Industry(
    id: 'manufacturing',
    name: 'Manufacturing',
    icon: '🏭',
    description: 'Production, Industrial, and Manufacturing',
  ),
];
