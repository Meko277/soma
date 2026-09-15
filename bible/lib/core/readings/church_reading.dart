class ChurchReading {
  const ChurchReading({
    required this.id,
    required this.type,
    required this.title,
    required this.content,
  });

  final String id;
  final String type;
  final String title;
  final List<String> content;

  factory ChurchReading.fromJson(Map<String, dynamic> json) {
    final rawContent = json['content'] ?? json['reads'] ?? json['verses'];
    final content = rawContent is List
        ? rawContent
              .map((item) => item is Map ? item['text'] : item)
              .map((item) => item?.toString() ?? '')
              .where((item) => item.trim().isNotEmpty)
              .toList()
        : <String>[];

    return ChurchReading(
      id: (json['id'] ?? '').toString(),
      type: (json['type'] ?? 'reading').toString(),
      title: (json['title'] ?? json['name'] ?? json['id'] ?? 'Reading')
          .toString(),
      content: content,
    );
  }
}
