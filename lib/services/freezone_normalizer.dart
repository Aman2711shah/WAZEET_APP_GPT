/// Normalizes AI-generated freezone names to canonical IDs/slugs used in our dataset.
/// This ensures recommendations from the AI can be matched against Firestore data.
class FreezoneNormalizer {
  /// Map of common AI name patterns to canonical IDs
  static final Map<String, String> _nameToIdMap = {
    // RAK variants
    'rakez': 'rakez',
    'rak free trade zone': 'rakez',
    'rak freezone': 'rakez',
    'ras al khaimah economic zone': 'rakez',

    // Ajman variants
    'ajman free zone': 'ajman_free_zone',
    'ajman freezone': 'ajman_free_zone',
    'afz': 'ajman_free_zone',
    'ajman': 'ajman_free_zone',

    // Sharjah Airport variants
    'sharjah airport international free zone': 'saif_zone',
    'saif zone': 'saif_zone',
    'saif': 'saif_zone',
    'sharjah airport': 'saif_zone',

    // IFZA variants
    'ifza': 'ifza',
    'international free zone authority': 'ifza',

    // DMCC variants
    'dmcc': 'dmcc',
    'dubai multi commodities centre': 'dmcc',
    'dubai multi commodities center': 'dmcc',

    // Dubai CommerCity variants
    'dubai commercity': 'dubai_commercity',
    'commercity': 'dubai_commercity',

    // DAFZA variants
    'dafza': 'dafza',
    'dubai airport freezone': 'dafza',
    'dubai airport free zone': 'dafza',

    // Meydan variants
    'meydan': 'meydan_freezone',
    'meydan freezone': 'meydan_freezone',
    'meydan free zone': 'meydan_freezone',

    // DWTC variants
    'dwtc': 'dwtc',
    'dubai world trade centre': 'dwtc',
    'dubai world trade center': 'dwtc',

    // Fujairah variants
    'fujairah free zone': 'fujairah_free_zone',
    'fujairah freezone': 'fujairah_free_zone',

    // Add more as needed
  };

  /// Normalize a freezone name to its canonical ID
  /// Returns the normalized ID if found, otherwise returns the original name in lowercase
  static String normalize(String aiName) {
    final normalized = aiName.trim().toLowerCase();

    // Direct lookup
    if (_nameToIdMap.containsKey(normalized)) {
      return _nameToIdMap[normalized]!;
    }

    // Fuzzy matching - check if any key is contained in the name
    for (final entry in _nameToIdMap.entries) {
      if (normalized.contains(entry.key) || entry.key.contains(normalized)) {
        return entry.value;
      }
    }

    // Fallback: return sanitized version
    return normalized.replaceAll(' ', '_').replaceAll(RegExp(r'[^\w_]'), '');
  }

  /// Normalize a list of AI recommendation names to IDs
  static List<String> normalizeList(List<String> aiNames) {
    return aiNames.map(normalize).toList();
  }

  /// Check if a freezone matches the normalized ID
  static bool matches(String freezoneName, String normalizedId) {
    return normalize(freezoneName) == normalizedId;
  }
}
