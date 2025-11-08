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
    'rak maritime city': 'rak_maritime_city',
    'rak maritime city free zone': 'rak_maritime_city',

    // Ajman variants
    'ajman free zone': 'ajman_free_zone',
    'ajman freezone': 'ajman_free_zone',
    'afz': 'ajman_free_zone',
    'ajman': 'ajman_free_zone',
    'ajman media city': 'ajman_media_city',
    'ajman media city free zone': 'ajman_media_city',

    // Sharjah variants
    'sharjah airport international free zone': 'saif_zone',
    'saif zone': 'saif_zone',
    'saif': 'saif_zone',
    'sharjah airport': 'saif_zone',
    'hamriyah free zone': 'hamriyah_free_zone',
    'hfza': 'hamriyah_free_zone',
    'sharjah media city': 'shams',
    'shams': 'shams',
    'sharjah publishing city': 'spc',
    'spc': 'spc',
    'srtip': 'srtip',
    'sharjah research technology park': 'srtip',

    // IFZA variants
    'ifza': 'ifza',
    'international free zone authority': 'ifza',

    // DMCC variants
    'dmcc': 'dmcc',
    'dubai multi commodities centre': 'dmcc',
    'dubai multi commodities center': 'dmcc',
    'jafza': 'jafza',
    'jebel ali free zone': 'jafza',

    // Dubai CommerCity variants
    'dubai commercity': 'dubai_commercity',
    'commercity': 'dubai_commercity',

    // DAFZA variants
    'dafza': 'dafza',
    'dubai airport freezone': 'dafza',
    'dubai airport free zone': 'dafza',

    // Dubai Silicon Oasis
    'dubai silicon oasis': 'dubai_silicon_oasis',
    'dso': 'dubai_silicon_oasis',

    // Meydan variants
    'meydan': 'meydan_freezone',
    'meydan freezone': 'meydan_freezone',
    'meydan free zone': 'meydan_freezone',

    // Dubai South / DWTC (legacy)
    'dubai south': 'dubai_south',
    'dwc': 'dubai_south',
    'dwtc': 'dubai_south',
    'dubai world trade centre': 'dubai_south',
    'dubai world trade center': 'dubai_south',

    // DIFC variants
    'difc': 'difc',
    'dubai international financial centre': 'difc',
    'dubai international financial center': 'difc',

    // Dubai sector clusters
    'dubai healthcare city': 'dubai_healthcare_city',
    'dhcc': 'dubai_healthcare_city',
    'dubai maritime city': 'dubai_maritime_city',
    'dubai internet city': 'dubai_internet_city',
    'dic': 'dubai_internet_city',
    'dubai media city': 'dubai_media_city',
    'dubai production city': 'dubai_production_city',
    'dubai studio city': 'dubai_studio_city',
    'dubai design district': 'dubai_design_district',
    'd3': 'dubai_design_district',
    'dubai knowledge park': 'dubai_knowledge_park',
    'dubai outsource city': 'dubai_outsource_city',
    'international humanitarian city': 'international_humanitarian_city',

    // Fujairah variants
    'fujairah free zone': 'fujairah_free_zone',
    'fujairah freezone': 'fujairah_free_zone',
    'creative city fujairah': 'creative_city_fujairah',
    'creative city': 'creative_city_fujairah',

    // Abu Dhabi variants
    'adgm': 'adgm',
    'abu dhabi global market': 'adgm',
    'kezad': 'kezad',
    'kizad': 'kezad',
    'masdar city': 'masdar_city',
    'masdar free zone': 'masdar_city',
    'adafz': 'adafz',
    'abu dhabi airports free zone': 'adafz',
    'twofour54': 'twofour54',

    // Umm Al Quwain
    'uaq ftz': 'uaq_free_trade_zone',
    'umm al quwain free trade zone': 'uaq_free_trade_zone',
    'uaq freezone': 'uaq_free_trade_zone',
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
