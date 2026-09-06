import 'library_item.dart';

class ContentRepository {
  const ContentRepository();

List<LibraryItem> bibleBooks() => const [
  LibraryItem(
    id: 'genesis',
    kind: LibraryKind.bible,
    testament: BibleTestament.old,
    title: 'Genesis',
    subtitle: 'Old Testament • 50 chapters',
    body:
        'The first book of the Holy Bible. Select a chapter to begin reading.',
  ),

  LibraryItem(
    id: 'psalms',
    kind: LibraryKind.bible,
    testament: BibleTestament.old,
    title: 'Psalms',
    subtitle: 'Old Testament • 150 psalms',
    body:
        'A treasury of praise, prayer, repentance, and hope.',
  ),

  LibraryItem(
    id: 'matthew',
    kind: LibraryKind.bible,
    testament: BibleTestament.newTestament,
    title: 'Matthew',
    subtitle: 'New Testament • 28 chapters',
    body:
        'The Gospel according to Saint Matthew.',
  ),

  LibraryItem(
    id: 'john',
    kind: LibraryKind.bible,
    testament: BibleTestament.newTestament,
    title: 'John',
    subtitle: 'New Testament • 21 chapters',
    body:
        'The Gospel according to Saint John.',
  ),

  LibraryItem(
    id: 'acts',
    kind: LibraryKind.bible,
    testament: BibleTestament.newTestament,
    title: 'Acts',
    subtitle: 'New Testament • 28 chapters',
    body:
        'The Acts of the Apostles.',
  ),
];

  List<LibraryItem> churchItems() => const [
    LibraryItem(id: 'morning-agpeya', kind: LibraryKind.prayer, title: 'Morning Agpeya', subtitle: 'First Hour • Prayer', body: 'In the name of the Father, the Son, and the Holy Spirit, one God. Amen. Glory be to God forever. Amen.'),
    LibraryItem(id: 'vespers-agpeya', kind: LibraryKind.prayer, title: 'Vespers Agpeya', subtitle: 'Eleventh Hour • Prayer', body: 'O God, make speed to save us. O Lord, make haste to help us.'),
    LibraryItem(id: 'basil-liturgy', kind: LibraryKind.liturgy, title: 'Liturgy of Saint Basil', subtitle: 'Divine Liturgy', body: 'The Divine Liturgy is presented here as an offline reference guide. Approved liturgical texts can be installed as a content pack.'),
    LibraryItem(id: 'psalmody', kind: LibraryKind.hymn, title: 'Midnight Praise', subtitle: 'Psalmody & hymns', body: 'Arise, O children of the light, let us praise the Lord of hosts.'),
    LibraryItem(id: 'kiahk', kind: LibraryKind.hymn, title: 'Kiahk Psalmody', subtitle: 'Seasonal praise', body: 'A seasonal collection for the month of Kiahk.'),
    LibraryItem(id: 'st-mary', kind: LibraryKind.saint, title: 'Saint Mary', subtitle: 'The Theotokos', body: 'Saint Mary, the Mother of God, is honored throughout the Coptic Orthodox Church.'),
    LibraryItem(id: 'baptism', kind: LibraryKind.rite, title: 'Holy Baptism', subtitle: 'Sacrament', body: 'A reference introduction to the sacrament of Holy Baptism.'),
  ];

  LibraryItem? byId(String id) => [...bibleBooks(), ...churchItems()].where((item) => item.id == id).firstOrNull;
}

extension _FirstOrNull<T> on Iterable<T> { T? get firstOrNull => isEmpty ? null : first; }
