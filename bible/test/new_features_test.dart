import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:bible/core/saved/saved_item.dart';
import 'package:bible/core/saved/saved_items_provider.dart';
import 'package:bible/core/translator/translator_models.dart';
import 'package:bible/core/translator/translator_service.dart';
import 'package:bible/core/traneem/traneem_content_provider.dart';
import 'package:bible/core/traneem/traneem_content_repository.dart';

// ================================================================
// TESTS FOR THE NEW CORE LAYERS
//
//   1. Traneem content (offline JSON assets, en + ar)
//   2. Saved / bookmarks persistence (SharedPreferences)
//   3. Translator (offline lexicon + composite fallback)
// ================================================================

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Traneem content (offline assets)', () {
    final repository = TraneemContentRepository();

    test('catalogue is not empty and has unique ids', () {
      expect(repository.hymns, isNotEmpty);

      final ids = repository.hymns.map((hymn) => hymn.id).toSet();

      expect(ids.length, repository.hymns.length);
    });

    test('every hymn loads lyrics in English and Arabic', () async {
      final provider = const TraneemContentProvider();

      for (final meta in repository.hymns) {
        final english = await provider.loadHymn(meta, language: 'en');
        final arabic = await provider.loadHymn(meta, language: 'ar');

        expect(english.stanzas, isNotEmpty,
            reason: '${meta.id} (en) must have lyrics');
        expect(arabic.stanzas, isNotEmpty,
            reason: '${meta.id} (ar) must have lyrics');
      }
    });

    test('unknown hymn id throws gracefully', () async {
      expect(
        () => repository.loadHymn('does-not-exist'),
        throwsA(isA<TraneemContentException>()),
      );
    });

    test('asset JSON is valid UTF-8 with Arabic titles preserved', () async {
      final raw = await rootBundle.loadString('assets/traneem/ar/trisagion.json');

      final decoded = jsonDecode(raw);

      expect(decoded, isA<Map<String, dynamic>>());

      final title = (decoded as Map<String, dynamic>)['title'];

      expect(title, isA<String>().having((t) => t, 'non-empty', isNotEmpty));
    });
  });

  group('Saved / bookmarks persistence', () {
    test('add, duplicate-guard, remove', () async {
      SharedPreferences.setMockInitialValues({});

      final notifier = SavedItemsNotifier();

      // Wait for the async restore.
      await Future<void>.delayed(Duration.zero);

      final item = SavedItem(
        id: 'bible:genesis-1',
        kind: SavedContentKind.bibleChapter,
        title: 'Genesis 1',
        subtitle: 'Chapter 1',
        routePath: '/bible/genesis-1',
      );

      await notifier.add(item);

      expect(notifier.isSaved(item.id), isTrue);
      expect(notifier.state.first.id, item.id);

      // Adding again must not duplicate.
      await notifier.add(item);

      expect(notifier.state.length, 1);

      await notifier.remove(item.id);

      expect(notifier.isSaved(item.id), isFalse);
    });

    test('items survive a fresh notifier (app restart simulation)',
        () async {
      SharedPreferences.setMockInitialValues({});

      final first = SavedItemsNotifier();

      await Future<void>.delayed(Duration.zero);

      await first.add(
        SavedItem(
          id: 'traneem:trisagion',
          kind: SavedContentKind.traneem,
          title: 'Trisagion',
          subtitle: 'Traneem',
          routePath: '/traneem/trisagion',
          savedAt: DateTime(2026, 1, 1),
        ),
      );

      // Simulated restart: same SharedPreferences store.
      final second = SavedItemsNotifier();

      await Future<void>.delayed(Duration.zero);

      expect(second.state.length, 1);
      expect(second.state.first.id, 'traneem:trisagion');
      expect(second.state.first.kind, SavedContentKind.traneem);
    });

    test('corrupt store is handled without crashing', () async {
      SharedPreferences.setMockInitialValues({
        'saved_items_v1': <String>['not-json'],
      });

      final notifier = SavedItemsNotifier();

      await Future<void>.delayed(Duration.zero);

      // Falls back to an empty list instead of crashing.
      expect(notifier.state, isEmpty);
    });
  });

  group('Coptic translator (offline-first)', () {
    test('offline lexicon translates a known phrase Coptic -> Arabic',
        () async {
      final service = createCopticTranslatorService();

      final result = await service.translate(
        const TranslationRequest(
          text: 'ϩⲁⲙⲏⲛ',
          from: TCode.coptic,
          to: TCode.arabic,
        ),
      );

      expect(result.isEmpty, isFalse);
      expect(result.exactMatch, isNotNull);
      expect(result.exactMatch, 'آمين');
      expect(result.fromRemote, isFalse);
    });

    test('offline lexicon translates Arabic -> Coptic', () async {
      final service = OfflineLexiconTranslatorService();

      final result = await service.translate(
        const TranslationRequest(
          text: 'آمين',
          from: TCode.arabic,
          to: TCode.coptic,
        ),
      );

      expect(result.isEmpty, isFalse);
      expect(result.exactMatch, 'ϩⲁⲙⲏⲛ');
    });

    test('unknown word returns rows but no matches (no crash, no throw)',
        () async {
      final service = createCopticTranslatorService();

      final result = await service.translate(
        const TranslationRequest(
          text: 'zzzznotawordzzz',
          from: TCode.coptic,
          to: TCode.arabic,
        ),
      );

      // The offline lexicon keeps a row per typed word so the UI can
      // show "not in dictionary", but no content was found.
      expect(result.hasMatches, isFalse);
      expect(result.exactMatch, isNull);

      for (final pair in result.words) {
        expect(pair.$2, isEmpty);
      }
    });

    test('unconfigured remote gateway throws a friendly error when used '
        'directly (composite never routes to it)', () async {
      final remote = RemoteCopticTranslatorService();

      expect(remote.isConfigured, isFalse);

      expect(
        () => remote.translate(
          const TranslationRequest(
            text: 'ϩⲁⲙⲏⲛ',
            from: TCode.coptic,
            to: TCode.arabic,
          ),
        ),
        throwsA(isA<TranslatorUnavailableException>()),
      );
    });
  });
}