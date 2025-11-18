import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Persist and expose bookmarked Free Zone IDs using SharedPreferences.
final bookmarksProvider = NotifierProvider<BookmarksNotifier, Set<String>>(
  BookmarksNotifier.new,
);

class BookmarksNotifier extends Notifier<Set<String>> {
  static const _prefsKey = 'bookmarked_freezones';

  @override
  Set<String> build() {
    // Start with empty set, load asynchronously
    load();
    return <String>{};
  }

  Future<void> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final list = prefs.getStringList(_prefsKey) ?? const <String>[];
      state = list.toSet();
    } catch (_) {
      // ignore errors, start with empty set
      state = <String>{};
    }
  }

  Future<void> _persist() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(_prefsKey, state.toList());
    } catch (_) {
      // ignore persistence errors
    }
  }

  bool isBookmarked(String id) => state.contains(id);

  Future<void> toggle(String id) async {
    final newState = Set<String>.from(state);
    if (!newState.add(id)) {
      newState.remove(id);
    }
    state = newState;
    await _persist();
  }
}
