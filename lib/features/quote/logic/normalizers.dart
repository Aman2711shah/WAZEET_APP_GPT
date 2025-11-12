double? parseMoney(dynamic v) {
  if (v == null) return null;
  if (v is num) return v.toDouble();
  final s = v.toString().trim().toLowerCase();
  if (s.isEmpty) return null;
  if (s == 'free') return 0.0;
  if (s == 'tbd' || s == 'not applicable' || s == 'not allowed') return null;
  // remove commas
  final cleaned = s.replaceAll(',', '');
  return double.tryParse(cleaned);
}

int parseActivitiesCount(String? s) {
  if (s == null) return 0;
  final m = RegExp(r'(\d+)').firstMatch(s);
  return m != null ? int.parse(m.group(1)!) : 0;
}

bool officeMatches(String? req, String wanted) {
  final norm = (req ?? '').toLowerCase();
  if (wanted == 'cowork') {
    return norm.contains('co-working') || norm.contains('co working') || norm.contains('flexi');
  }
  if (wanted == 'physical') {
    return norm.contains('physical') || norm.contains('dedicated') || norm.contains('serviced') || norm.contains('executive') || norm.contains('standard') || norm.contains('office');
  }
  return true;
}
