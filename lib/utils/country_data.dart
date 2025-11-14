class Country {
  final String code; // ISO 3166-1 alpha-2
  final String name;
  final String dialCode; // with leading +
  const Country({
    required this.code,
    required this.name,
    required this.dialCode,
  });
}

/// Convert a 2-letter country code to a flag emoji using Unicode regional indicators.
String flagEmoji(String countryCode) {
  final code = countryCode.toUpperCase();
  if (code.length != 2) return '🏳️';
  final int base = 0x1F1E6; // regional indicator for 'A'
  final int aCode = 'A'.codeUnitAt(0);
  final int first = base + code.codeUnitAt(0) - aCode;
  final int second = base + code.codeUnitAt(1) - aCode;
  return String.fromCharCode(first) + String.fromCharCode(second);
}

// Curated list of common countries with dial codes. Extend as needed.
const List<Country> countries = [
  Country(code: 'AE', name: 'United Arab Emirates', dialCode: '+971'),
  Country(code: 'IN', name: 'India', dialCode: '+91'),
  Country(code: 'US', name: 'United States', dialCode: '+1'),
  Country(code: 'GB', name: 'United Kingdom', dialCode: '+44'),
  Country(code: 'CA', name: 'Canada', dialCode: '+1'),
  Country(code: 'SA', name: 'Saudi Arabia', dialCode: '+966'),
  Country(code: 'QA', name: 'Qatar', dialCode: '+974'),
  Country(code: 'OM', name: 'Oman', dialCode: '+968'),
  Country(code: 'KW', name: 'Kuwait', dialCode: '+965'),
  Country(code: 'BH', name: 'Bahrain', dialCode: '+973'),
  Country(code: 'EG', name: 'Egypt', dialCode: '+20'),
  Country(code: 'PK', name: 'Pakistan', dialCode: '+92'),
  Country(code: 'BD', name: 'Bangladesh', dialCode: '+880'),
  Country(code: 'LK', name: 'Sri Lanka', dialCode: '+94'),
  Country(code: 'NP', name: 'Nepal', dialCode: '+977'),
  Country(code: 'PH', name: 'Philippines', dialCode: '+63'),
  Country(code: 'CN', name: 'China', dialCode: '+86'),
  Country(code: 'JP', name: 'Japan', dialCode: '+81'),
  Country(code: 'KR', name: 'South Korea', dialCode: '+82'),
  Country(code: 'SG', name: 'Singapore', dialCode: '+65'),
  Country(code: 'MY', name: 'Malaysia', dialCode: '+60'),
  Country(code: 'ID', name: 'Indonesia', dialCode: '+62'),
  Country(code: 'TH', name: 'Thailand', dialCode: '+66'),
  Country(code: 'VN', name: 'Vietnam', dialCode: '+84'),
  Country(code: 'AU', name: 'Australia', dialCode: '+61'),
  Country(code: 'NZ', name: 'New Zealand', dialCode: '+64'),
  Country(code: 'DE', name: 'Germany', dialCode: '+49'),
  Country(code: 'FR', name: 'France', dialCode: '+33'),
  Country(code: 'IT', name: 'Italy', dialCode: '+39'),
  Country(code: 'ES', name: 'Spain', dialCode: '+34'),
  Country(code: 'NL', name: 'Netherlands', dialCode: '+31'),
  Country(code: 'TR', name: 'Turkey', dialCode: '+90'),
  Country(code: 'RU', name: 'Russia', dialCode: '+7'),
  Country(code: 'UA', name: 'Ukraine', dialCode: '+380'),
  Country(code: 'IR', name: 'Iran', dialCode: '+98'),
  Country(code: 'IQ', name: 'Iraq', dialCode: '+964'),
  Country(code: 'JO', name: 'Jordan', dialCode: '+962'),
  Country(code: 'LB', name: 'Lebanon', dialCode: '+961'),
  Country(code: 'IL', name: 'Israel', dialCode: '+972'),
  Country(code: 'YE', name: 'Yemen', dialCode: '+967'),
  Country(code: 'ZA', name: 'South Africa', dialCode: '+27'),
  Country(code: 'NG', name: 'Nigeria', dialCode: '+234'),
  Country(code: 'KE', name: 'Kenya', dialCode: '+254'),
  Country(code: 'GH', name: 'Ghana', dialCode: '+233'),
  Country(code: 'MA', name: 'Morocco', dialCode: '+212'),
  Country(code: 'DZ', name: 'Algeria', dialCode: '+213'),
  Country(code: 'TN', name: 'Tunisia', dialCode: '+216'),
  Country(code: 'BR', name: 'Brazil', dialCode: '+55'),
  Country(code: 'MX', name: 'Mexico', dialCode: '+52'),
  Country(code: 'AR', name: 'Argentina', dialCode: '+54'),
  Country(code: 'CL', name: 'Chile', dialCode: '+56'),
  Country(code: 'CO', name: 'Colombia', dialCode: '+57'),
  Country(code: 'PE', name: 'Peru', dialCode: '+51'),
];
