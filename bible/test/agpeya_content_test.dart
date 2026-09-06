import 'package:flutter_test/flutter_test.dart';

import 'package:bible/core/agpeya/agpeya_content_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const provider = AgpeyaContentProvider();

  const hourIds = [
    'morning',
    'third',
    'sixth',
    'ninth',
    'vespers',
    'compline',
    'midnight',
  ];

  for (final language in ['en', 'ar']) {
    group('Agpeya content ($language)', () {
      for (final hourId in hourIds) {
        test('loads and parses $hourId', () async {
          final hour = await provider.loadHour(
            hourId,
            language: language,
          );

          expect(hour.name, isNotEmpty,
              reason: '$language/$hourId name');

          // Every hour must have prayer content in one of
          // the supported formats:
          //  - structured psalms
          //  - midnight watches
          //  - flat chapters (some Arabic files)
          final hasContent = hour.psalms.isNotEmpty ||
              hour.watches.isNotEmpty ||
              hour.chapters.isNotEmpty;

          expect(hasContent, isTrue,
              reason: '$language/$hourId has no content');

          // Psalms must contain verse text.
          for (final psalm in hour.psalms) {
            expect(psalm.verses, isNotEmpty,
                reason: '$language/$hourId / ${psalm.reference}');
            for (final verse in psalm.verses) {
              expect(verse.text, isNotEmpty,
                  reason: '$language/$hourId / ${psalm.reference}');
            }
          }

          // Watch psalms must contain verse text.
          for (final watch in hour.watches) {
            expect(watch.psalms, isNotEmpty,
                reason: '$language/$hourId / ${watch.name}');
          }

          // Chapters must contain verse text.
          for (final chapter in hour.chapters) {
            expect(chapter.verses, isNotEmpty,
                reason: '$language/$hourId / ${chapter.title}');
            for (final verse in chapter.verses) {
              expect(verse.text, isNotEmpty,
                  reason: '$language/$hourId / ${chapter.title}');
            }
          }
        });
      }
    });
  }

  test('English midnight parses the three watches', () async {
    final hour = await provider.loadHour('midnight', language: 'en');

    expect(hour.watches.length, 3);
    expect(hour.watches[0].name, 'First Watch');
    expect(hour.watches[1].name, 'Second Watch');
    expect(hour.watches[2].name, 'Third Watch');
    expect(hour.watches[0].psalms.length, greaterThan(5));
    expect(hour.watches[0].gospel, isNotNull);
    expect(hour.watches[0].litanies, isNotNull);
  });

  test('Arabic morning parses Arabic-specific sections', () async {
    final hour = await provider.loadHour('morning', language: 'ar');

    expect(hour.name, 'باكر');
    expect(hour.comeLetUsWorship, isNotNull);
    expect(hour.lordsPrayer, isNotNull);
    expect(hour.additionalSections, isNotEmpty);
  });

  test('Arabic third hour parses the chapters fallback format', () async {
    final hour = await provider.loadHour('third', language: 'ar');

    expect(hour.name, 'الثالثة');
    expect(hour.chapters, isNotEmpty);
    expect(hour.chapters.first.title, isNotEmpty);
    expect(hour.chapters.first.verses.first.text, isNotEmpty);
  });

  test('Arabic midnight parses the chapters fallback format', () async {
    final hour = await provider.loadHour('midnight', language: 'ar');

    expect(hour.name, 'نصف الليل');
    expect(hour.chapters.length, greaterThan(3));
  });

  test('English morning parses structured sections', () async {
    final hour = await provider.loadHour('morning', language: 'en');

    expect(hour.psalms.length, greaterThan(5));
    expect(hour.gospel, isNotNull);
    expect(hour.litanies, isNotNull);
    expect(hour.closing, isNotNull);
  });
}