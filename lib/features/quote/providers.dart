import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'data/freezone_repo.dart';
import 'data/models/package_model.dart';
import 'logic/matchers.dart';
import 'logic/quote_engine.dart';

// User selections
final freezoneProvider = StateProvider<String>((_) => 'SHAMS');
final visasProvider = StateProvider<int>((_) => 1);
final activitiesProvider = StateProvider<int>((_) => 1);
final shareholdersProvider = StateProvider<int>((_) => 1);
final tenureProvider = StateProvider<int>((_) => 1); // years

// Data and computation
final repoProvider = Provider((_) => FreezoneRepo());
final packagesProvider = FutureProvider<List<PackageRow>>((ref) async {
  final zone = ref.watch(freezoneProvider);
  return ref.watch(repoProvider).loadZone(zone);
});

final quoteProvider = Provider<QuoteResult>((ref) {
  final pkgs = ref
      .watch(packagesProvider)
      .maybeWhen(data: (d) => d, orElse: () => <PackageRow>[]);
  final input = QuoteInput(
    freezone: ref.watch(freezoneProvider),
    visas: ref.watch(visasProvider),
    activities: ref.watch(activitiesProvider),
    shareholders: ref.watch(shareholdersProvider),
    tenure: ref.watch(tenureProvider),
  );
  final pkg = pickBestPackage(
    pkgs,
    activities: input.activities,
    shareholders: input.shareholders,
    tenure: input.tenure,
  );
  return compute(pkg, input);
});
