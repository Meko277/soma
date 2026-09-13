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
  static BibleContentSync? get bibleSync => _bible;

  static void installBible(BibleContentSync sync) {
    _bible = sync;
  }
}
