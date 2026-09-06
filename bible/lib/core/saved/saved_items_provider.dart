import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'saved_item.dart';

// ================================================================
// SAVED ITEMS PROVIDER
//
// Persists saved pages with the app's existing storage layer
// (SharedPreferences) so bookmarks survive app restarts and work
// fully offline.
// ================================================================

final savedItemsProvider =
    StateNotifierProvider<SavedItemsNotifier, List<SavedItem>>(
  (ref) => SavedItemsNotifier(),
);

class SavedItemsNotifier extends StateNotifier<List<SavedItem>> {
  SavedItemsNotifier() : super(const []) {
    _restore();
  }

  static const String _storageKey = 'saved_items_v1';

  bool isSaved(String id) => state.any((item) => item.id == id);

  /// Toggle: removes when present, adds otherwise.
  Future<void> toggle(SavedItem item) async {
    if (isSaved(item.id)) {
      await remove(item.id);
    } else {
      await add(item);
    }
  }

  Future<void> add(SavedItem item) async {
    // Keep newest first, never duplicate.
    state = [
      item,
      ...state.where((existing) => existing.id != item.id),
    ];

    await _persist();
  }

  Future<void> remove(String id) async {
    state = state.where((item) => item.id != id).toList();

    await _persist();
  }

  Future<void> clear() async {
    state = const [];
    await _persist();
  }

  Future<void> _restore() async {
    try {
      final storage = await SharedPreferences.getInstance();

      final raw = storage.getStringList(_storageKey) ?? const [];

      final items = raw
          .map((entry) => jsonDecode(entry))
          .whereType<Map<String, dynamic>>()
          .map(SavedItem.fromJson)
          .toList();

      // Newest first (mirror of how we add).
      items.sort((a, b) => b.savedAt.compareTo(a.savedAt));

      if (mounted) {
        state = items;
      }
    } catch (_) {
      // A corrupt store must never crash the app.
      state = const [];
    }
  }

  Future<void> _persist() async {
    try {
      final storage = await SharedPreferences.getInstance();

      final raw = state
          .map((item) => jsonEncode(item.toJson()))
          .toList();

      await storage.setStringList(_storageKey, raw);
    } catch (_) {
      // Best effort — a persistence failure must not crash the UI.
    }
  }
}