enum LibraryKind {
  bible,
  prayer,
  liturgy,
  hymn,
  saint,
  rite,
}

enum BibleTestament {
  old,
  newTestament,
}

class LibraryItem {
  const LibraryItem({
    required this.id,
    required this.kind,
    required this.title,
    required this.subtitle,
    required this.body,
    this.testament,
  });

  final String id;
  final LibraryKind kind;
  final String title;
  final String subtitle;
  final String body;

  // Used only for Bible books.
  final BibleTestament? testament;
}