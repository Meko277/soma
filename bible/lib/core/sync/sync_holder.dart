import 'dart:async';

import '../bible/bible_sync.dart';
import 'firestore_content_sync.dart';

/// Holds the app-wide Firestore content sync instances so non-widget
/// code (content repositories) can read synced content without
/// needing a Riverpod ref.
///
/// Set once in main() after initialization; read anywhere via
/// [instance] / [bibleSync].
class SyncHolder {
  static FirestoreContentSync? _instance;

  static FirestoreContentSync? get instance => _instance;

  static void install(FirestoreContentSync sync) {
    _instance = sync;
  }

  // ----------------------------------------------------------
  // BIBLE (admin-edited books, fetched on demand per book)
  // ----------------------------------------------------------

  static BibleContentSync? _bible;

  /// On-demand sync of admin-edited Bible books from Firestore.
  ///
  /// Whenever one book changes in Firestore, [notifyBibleChanged] fires
  /// [bibleUpdates] so open chapter readers reload at once (exact-time
  /// updates while the app is online).
  static BibleContentSync? get bibleSync => _bible;

  static void installBible(BibleContentSync sync) {
    _bible = sync;
  }

  static final _bibleController = StreamController<void>.broadcast();

  /// Broadcast stream: fires whenever the open Bible book's Firestore
  /// doc changes, so an open chapter reloads at once while online.
  static Stream<void> get bibleUpdates => _bibleController.stream;

  static void notifyBibleChanged() {
    if (!_bibleController.isClosed) _bibleController.add(null);
  }
}
