import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../community/people_repository.dart';

/// Provider for the PeopleRepository
/// Used for managing user connections and suggestions
final peopleRepositoryProvider = Provider<PeopleRepository>((ref) {
  return PeopleRepository();
});
