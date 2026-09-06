class AgpeyaHour {
  final String id;
  final String name;
  final String? englishName;
  final String? traditionalTime;
  final String? introduction;

  final AgpeyaSection? opening;
  final AgpeyaSection? hourIntro;
  final AgpeyaSection? comeLetUsWorship;
  final AgpeyaSection? thanksgiving;
  final AgpeyaPsalm? introductoryPsalm;

  final String? psalmsIntro;
  final List<AgpeyaPsalm> psalms;

  final AgpeyaGospel? gospel;
  final AgpeyaContentSection? litanies;
  final AgpeyaSection? lordsPrayer;
  final AgpeyaContentSection? closing;

  final List<AgpeyaContentSection> additionalSections;

  /// Midnight prayer: three watches, each with its own
  /// psalms, gospel, litanies and closing.
  final List<AgpeyaWatch> watches;

  /// Fallback format used by several Arabic JSON files:
  /// a flat list of titled chapters with verses.
  final List<AgpeyaChapter> chapters;

  const AgpeyaHour({
    required this.id,
    required this.name,
    this.englishName,
    this.traditionalTime,
    this.introduction,
    this.opening,
    this.hourIntro,
    this.comeLetUsWorship,
    this.thanksgiving,
    this.introductoryPsalm,
    this.psalmsIntro,
    this.psalms = const [],
    this.gospel,
    this.litanies,
    this.lordsPrayer,
    this.closing,
    this.additionalSections = const [],
    this.watches = const [],
    this.chapters = const [],
  });

  factory AgpeyaHour.fromJson(Map<String, dynamic> json) {
    return AgpeyaHour(
      // Some Arabic files use "Id"/"bookId" instead of "id".
      id: (json['id'] ?? json['Id'] ?? json['bookId'])
              ?.toString() ??
          '',

      // Some Arabic files use "Name"/"bookName" instead of "name".
      name: (json['name'] ?? json['Name'] ?? json['bookName'])
              ?.toString() ??
          '',

      englishName: json['englishName']?.toString(),
      traditionalTime: json['traditionalTime']?.toString(),
      introduction: json['introduction']?.toString(),

      opening: json['opening'] is Map<String, dynamic>
          ? AgpeyaSection.fromJson(
              json['opening'] as Map<String, dynamic>,
            )
          : null,

      hourIntro: json['hourIntro'] is Map<String, dynamic>
          ? AgpeyaSection.fromJson(
              json['hourIntro'] as Map<String, dynamic>,
            )
          : null,

      comeLetUsWorship:
          json['comeLetUsWorship'] is Map<String, dynamic>
              ? AgpeyaSection.fromJson(
                  json['comeLetUsWorship']
                      as Map<String, dynamic>,
                )
              : null,

      thanksgiving: json['thanksgiving'] is Map<String, dynamic>
          ? AgpeyaSection.fromJson(
              json['thanksgiving'] as Map<String, dynamic>,
            )
          : null,

      introductoryPsalm:
          json['introductoryPsalm'] is Map<String, dynamic>
              ? AgpeyaPsalm.fromJson(
                  json['introductoryPsalm']
                      as Map<String, dynamic>,
                )
              : null,

      psalmsIntro: json['psalmsIntro']?.toString(),

      psalms: (json['psalms'] as List<dynamic>? ?? [])
          .whereType<Map<String, dynamic>>()
          .map(AgpeyaPsalm.fromJson)
          .toList(),

      gospel: json['gospel'] is Map<String, dynamic>
          ? AgpeyaGospel.fromJson(
              json['gospel'] as Map<String, dynamic>,
            )
          : null,

      litanies: json['litanies'] is Map<String, dynamic>
          ? AgpeyaContentSection.fromJson(
              json['litanies'] as Map<String, dynamic>,
            )
          : null,

      lordsPrayer: json['lordsPrayer'] is Map<String, dynamic>
          ? AgpeyaSection.fromJson(
              json['lordsPrayer'] as Map<String, dynamic>,
            )
          : null,

      closing: json['closing'] is Map<String, dynamic>
          ? AgpeyaContentSection.fromJson(
              json['closing'] as Map<String, dynamic>,
            )
          : null,

      additionalSections:
          (json['additionalSections'] as List<dynamic>? ?? [])
              .whereType<Map<String, dynamic>>()
              .map(AgpeyaContentSection.fromJson)
              .toList(),

      watches: (json['watches'] as List<dynamic>? ?? [])
          .whereType<Map<String, dynamic>>()
          .map(AgpeyaWatch.fromJson)
          .toList(),

      chapters: (json['chapters'] as List<dynamic>? ?? [])
          .whereType<Map<String, dynamic>>()
          .map(AgpeyaChapter.fromJson)
          .toList(),
    );
  }
}


// ============================================================
// Watch (Midnight Prayer)
// ============================================================

class AgpeyaWatch {
  final String id;
  final String name;
  final String? theme;
  final String? psalmsIntro;
  final List<AgpeyaPsalm> psalms;
  final AgpeyaGospel? gospel;
  final AgpeyaContentSection? litanies;
  final AgpeyaContentSection? closing;

  const AgpeyaWatch({
    required this.id,
    required this.name,
    this.theme,
    this.psalmsIntro,
    this.psalms = const [],
    this.gospel,
    this.litanies,
    this.closing,
  });

  factory AgpeyaWatch.fromJson(
    Map<String, dynamic> json,
  ) {
    return AgpeyaWatch(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      theme: json['theme']?.toString(),

      psalmsIntro: json['psalmsIntro']?.toString(),

      psalms: (json['psalms'] as List<dynamic>? ?? [])
          .whereType<Map<String, dynamic>>()
          .map(AgpeyaPsalm.fromJson)
          .toList(),

      gospel: json['gospel'] is Map<String, dynamic>
          ? AgpeyaGospel.fromJson(
              json['gospel'] as Map<String, dynamic>,
            )
          : null,

      litanies: json['litanies'] is Map<String, dynamic>
          ? AgpeyaContentSection.fromJson(
              json['litanies'] as Map<String, dynamic>,
            )
          : null,

      closing: json['closing'] is Map<String, dynamic>
          ? AgpeyaContentSection.fromJson(
              json['closing'] as Map<String, dynamic>,
            )
          : null,
    );
  }
}


// ============================================================
// Chapter (fallback format in some Arabic files)
// ============================================================

class AgpeyaChapter {
  final int? number;
  final String title;
  final List<AgpeyaVerse> verses;

  const AgpeyaChapter({
    this.number,
    required this.title,
    required this.verses,
  });

  factory AgpeyaChapter.fromJson(
    Map<String, dynamic> json,
  ) {
    final dynamic rawNumber =
        json['chapterNumber'] ?? json['number'];

    return AgpeyaChapter(
      number: rawNumber is int
          ? rawNumber
          : int.tryParse(rawNumber?.toString() ?? ''),

      title: (json['chapterTitle'] ?? json['title'])
              ?.toString() ??
          '',

      verses: (json['verses'] as List<dynamic>? ?? [])
          .whereType<Map<String, dynamic>>()
          .map(AgpeyaVerse.fromJson)
          .toList(),
    );
  }
}


// ============================================================
// Generic Section
// ============================================================

class AgpeyaSection {
  final String? title;
  final List<String> content;
  final bool inline;

  const AgpeyaSection({
    this.title,
    this.content = const [],
    this.inline = false,
  });

  factory AgpeyaSection.fromJson(
    Map<String, dynamic> json,
  ) {
    return AgpeyaSection(
      title: json['title']?.toString(),

      content: (json['content'] as List<dynamic>? ?? [])
          .map((item) => item.toString())
          .toList(),

      inline: json['inline'] == true,
    );
  }
}


// ============================================================
// Content Section
// ============================================================

class AgpeyaContentSection {
  final String? title;
  final List<String> content;

  const AgpeyaContentSection({
    this.title,
    this.content = const [],
  });

  factory AgpeyaContentSection.fromJson(
    Map<String, dynamic> json,
  ) {
    return AgpeyaContentSection(
      title: json['title']?.toString(),

      content: (json['content'] as List<dynamic>? ?? [])
          .map((item) => item.toString())
          .toList(),
    );
  }
}


// ============================================================
// Psalm
// ============================================================

class AgpeyaPsalm {
  final String reference;
  final String title;
  final List<AgpeyaVerse> verses;

  const AgpeyaPsalm({
    required this.reference,
    required this.title,
    required this.verses,
  });

  factory AgpeyaPsalm.fromJson(
    Map<String, dynamic> json,
  ) {
    return AgpeyaPsalm(
      reference: json['reference']?.toString() ?? '',
      title: json['title']?.toString() ?? '',

      verses: (json['verses'] as List<dynamic>? ?? [])
          .whereType<Map<String, dynamic>>()
          .map(AgpeyaVerse.fromJson)
          .toList(),
    );
  }
}


// ============================================================
// Verse
// ============================================================

class AgpeyaVerse {
  final int? number;
  final String text;

  const AgpeyaVerse({
    this.number,
    required this.text,
  });

  factory AgpeyaVerse.fromJson(
    Map<String, dynamic> json,
  ) {
    // Structured files use "num", chapter-format
    // files use "number".
    final dynamic rawNum = json['num'] ?? json['number'];

    return AgpeyaVerse(
      number: rawNum is int
          ? rawNum
          : int.tryParse(rawNum?.toString() ?? ''),

      text: json['text']?.toString() ?? '',
    );
  }
}


// ============================================================
// Gospel
// ============================================================

class AgpeyaGospel {
  final String reference;
  final String? rubric;
  final List<AgpeyaVerse> verses;

  const AgpeyaGospel({
    required this.reference,
    this.rubric,
    required this.verses,
  });

  factory AgpeyaGospel.fromJson(
    Map<String, dynamic> json,
  ) {
    return AgpeyaGospel(
      reference: json['reference']?.toString() ?? '',

      rubric: json['rubric']?.toString(),

      verses: (json['verses'] as List<dynamic>? ?? [])
          .whereType<Map<String, dynamic>>()
          .map(AgpeyaVerse.fromJson)
          .toList(),
    );
  }
}