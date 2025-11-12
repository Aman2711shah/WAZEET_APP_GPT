import '../data/models/package_model.dart';
import 'normalizers.dart';

/// Pick the best matching package from the list based on:
/// - Activities count
/// - Shareholders count
/// - Tenure (years)
/// For now, we'll match by activities first, then pick the best tenure match
PackageRow? pickBestPackage(
  List<PackageRow> rows, {
  required int activities,
  required int shareholders,
  required int tenure,
}) {
  if (rows.isEmpty) return null;

  // Filter by active packages
  final active = rows.where((r) => r.isActive == true).toList();
  if (active.isEmpty) return rows.first;

  // Match by activities and shareholders
  final matched = active.where((r) {
    final acts = parseActivitiesCount(r.noOfActivitiesAllowed);
    final shs = parseActivitiesCount(r.noOfShareholdersAllowed);
    return acts >= activities && shs >= shareholders;
  }).toList();

  if (matched.isEmpty) return active.first;

  // Find best tenure match (exact or closest higher)
  matched.sort((a, b) {
    final aYears = int.tryParse(a.tenureYears ?? '0') ?? 0;
    final bYears = int.tryParse(b.tenureYears ?? '0') ?? 0;
    return aYears.compareTo(bYears);
  });

  try {
    return matched.firstWhere(
      (r) => int.tryParse(r.tenureYears ?? '0') == tenure,
    );
  } catch (_) {
    // Return closest higher tenure
    return matched.firstWhere(
      (r) => (int.tryParse(r.tenureYears ?? '0') ?? 0) >= tenure,
      orElse: () => matched.last,
    );
  }
}
