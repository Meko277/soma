
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
  ///
  /// NOTE on content: the current set is an initial authoring
  /// template of public-domain liturgical hymns. Additional
  /// approved hymn lyrics (especially Arabic) should be added
  /// as JSON files under assets/traneem/ and registered here.
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
    return null;
  }

  /// Loads one hymn's lyrics for the given language.
  Future<TraneemHymn> loadHymn(
    String id, {
    String language = 'en',
  }) {
    final meta = byId(id);

    if (meta == null) {
      throw TraneemContentException('Unknown hymn: $id');
    }

    return provider.loadHymn(meta, language: language);
  }

  // Keep provider debug output out of hot paths.
  @override
  String toString() => 'TraneemContentRepository(${_hymns.length} hymns)';
}
