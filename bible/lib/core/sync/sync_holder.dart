import 'firestore_content_sync.dart';

/// Holds the app-wide Firestore content sync instance so non-widget
/// code (content repositories) can read synced content without
/// needing a Riverpod ref.
///
/// Set once in main() after initialization; read anywhere via
/// [instance].
class SyncHolder {
  static FirestoreContentSync? _instance;

  static FirestoreContentSync? get instance => _instance;

  static void install(FirestoreContentSync sync) {
    _instance = sync;
  }
}
