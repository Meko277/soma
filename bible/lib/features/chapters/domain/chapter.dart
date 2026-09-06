class Chapter {
  final String id;
  final int chapterNumber;
  final String title;
  final String content;

  const Chapter({
    required this.id,
    required this.chapterNumber,
    required this.title,
    required this.content,
  });

  factory Chapter.fromMap(
    String id,
    Map<String, dynamic> data,
  ) {
    return Chapter(
      id: id,
      chapterNumber: data['chapterNumber'] ?? 0,
      title: data['title'] ?? '',
      content: data['content'] ?? '',
    );
  }
}