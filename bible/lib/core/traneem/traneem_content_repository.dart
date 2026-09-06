import '../sync/sync_holder.dart';
import 'traneem_content_provider.dart';
import 'traneem_models.dart';

/// Metadata + loading for the Traneem (hymn) section.
///
/// The bilingual hymn list lives here (like the Agpeya page),
/// while the actual lyrics are fetched on demand by the
/// [TraneemContentProvider].
class TraneemContentRepository {
  const TraneemContentRepository({
    this.provider = const TraneemContentProvider(),
  });

  final TraneemContentProvider provider;

  /// All hymns available in the Traneem catalogue.
  List<TraneemHymnMeta> get hymns => _hymns;

  static const List<TraneemHymnMeta> _hymns = [
    TraneemHymnMeta(
      id: 'trisagion',
      title: 'Holy God (Trisagion)',
      arabicTitle: 'التقديس المقدس (الثلاثي قدوس)',
      category: 'Liturgical',
      categoryAr: 'طقسية',
    ),
    TraneemHymnMeta(
      id: 'lords-prayer',
      title: 'Our Father (The Lord\'s Prayer)',
      arabicTitle: 'أبانا الذي في السموات',
      category: 'Prayer',
      categoryAr: 'صلاة',
    ),
    TraneemHymnMeta(
      id: 'doxology',
      title: 'Glory Be (Doxology)',
      arabicTitle: 'المجد للإله',
      category: 'Liturgical',
      categoryAr: 'طقسية',
    ),
  ];

  TraneemHymnMeta? byId(String id) {
    for (final hymn in _hymns) {
      if (hymn.id == id) {
        return hymn;
      }
    }

    // Admin-added hymns (present in Firestore but not in the bundled
    // catalogue) are resolved from the sync cache so they open fine.
    final sync = SyncHolder.instance;
    final synced = sync?.traneem(id, 'en') ?? sync?.traneem(id, 'ar');
    if (synced != null) {
      return TraneemHymnMeta(
        id: synced.id,
        title: synced.title,
        arabicTitle: synced.arabicTitle,
        category: synced.category,
        categoryAr: synced.categoryAr,
      );
    }

    return null;
  }

  /// Loads one hymn's lyrics for the given language.
  ///
  /// OFFLINE-FIRST: if the Firestore sync service has fetched this
  /// hymn (or it was persisted from a previous session), that
  /// version is returned immediately so the app always shows the
  /// latest admin-edited content. Otherwise falls back to the
  /// bundled asset.
  Future<TraneemHymn> loadHymn(
    String id, {
    String language = 'en',
  }) async {
    // Prefer Firestore-synced content when available.
    final synced = await traneemSyncedHymn(id, language);
    if (synced != null) return synced;

    final meta = byId(id);
    if (meta == null) {
      throw TraneemContentException('Unknown hymn: $id');
    }
    return provider.loadHymn(meta, language: language);
  }

  /// Returns the Firestore-synced hymn if present, else null.
  Future<TraneemHymn?> traneemSyncedHymn(String id, String language) async {
    try {
      final sync = SyncHolder.instance;
      if (sync == null) return null;
      return sync.traneem(id, language);
    } catch (_) {
      return null;
    }
  }

  // Keep provider debug output out of hot paths.
  @override
  String toString() => 'TraneemContentRepository(${_hymns.length} hymns)';
}
