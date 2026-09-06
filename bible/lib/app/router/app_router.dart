import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/bible/bible_content_provider.dart';
import '../../core/preferences/app_preferences.dart';
import '../../core/preferences/preferences_provider.dart';
import '../../features/agpeya/agpeya_page.dart';
import '../../features/admin/admin_bible_page.dart';
import '../../features/bible/bible_book_chapters_page.dart';
import '../../features/bible/bible_chapter_reader_page.dart';
import '../../features/bible/bible_page.dart';
import '../../features/calendar/calendar_page.dart';
import '../../features/church/church_page.dart';
import '../../features/home/home_page.dart';
import '../../features/library/document_reader_page.dart';
import '../../features/liturgy/liturgy_home_page.dart';
import '../../features/liturgy/liturgy_reader_page.dart';
import '../../features/more/more_page.dart';
import '../../features/settings/appearance_settings_page.dart';
import '../../features/settings/language_settings_page.dart';
import '../../features/today/today_page.dart';
import '../../features/traneem/traneem_page.dart';
import '../../features/traneem/traneem_reader_page.dart';
import '../../features/saved/saved_page.dart';
import '../../features/agpeya/agpeya_prayer_page.dart';
import '../../features/translator/coptic_translator_page.dart';

import '../../widgets/app_navigation_scaffold.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final repository = ref.watch(bibleContentRepositoryProvider);

  return GoRouter(
    initialLocation: '/',

    routes: [
      // =========================================================
      // MAIN APP SHELL
      // =========================================================

      ShellRoute(
        builder: (context, state, child) {
          return AppNavigationScaffold(
            child: child,
          );
        },

        routes: [
          // =======================================================
          // HOME
          // =======================================================

          GoRoute(
            path: '/',
            name: 'home',
            builder: (context, state) {
              return const HomePage();
            },
          ),

          // =======================================================
          // BIBLE
          // /bible
          // =======================================================

          GoRoute(
            path: '/bible',
            name: 'bible',
            builder: (context, state) {
              return const BiblePage();
            },
          ),
GoRoute(
  path: '/agpeya',
  name: 'agpeya',
  builder: (context, state) {
    return const AgpeyaPage();
  },
),

          // =======================================================
          // BIBLE BOOK
          // /book/genesis
          // /book/exodus
          // /book/matthew
          // etc.
          // =======================================================

          GoRoute(
            path: '/book/:id',
            name: 'bibleBook',
            builder: (context, state) {
              final bookId =
                  state.pathParameters['id'] ?? '';

              debugPrint('========== BOOK ROUTE ==========');
              debugPrint('Requested book ID: "$bookId"');

              final book =
                  repository.bookById(bookId);

              if (book == null) {
                debugPrint(
                  'BOOK NOT FOUND: "$bookId"',
                );

                return Scaffold(
                  appBar: AppBar(
                    title: const Text('Bible'),
                  ),
                  body: Center(
                    child: Text(
                      'Book not found\n\n'
                      'ID: $bookId',
                      textAlign: TextAlign.center,
                    ),
                  ),
                );
              }

              debugPrint(
                'BOOK FOUND: ${book.name}',
              );
              debugPrint(
                'Chapter count: ${book.chapterCount}',
              );
              debugPrint(
                '================================',
              );

              return BibleBookChaptersPage(
                book: book,
              );
            },
          ),

          // =======================================================
          // CHURCH
          // =======================================================

          GoRoute(
            path: '/church',
            name: 'church',
            builder: (context, state) {
              return const ChurchPage();
            },
          ),

          // =======================================================
          // TODAY
          // =======================================================

          GoRoute(
            path: '/today',
            name: 'today',
            builder: (context, state) {
              return const TodayPage();
            },
          ),

          // =======================================================
          // TRANSLATOR (replaces Audio)
          // =======================================================

          GoRoute(
            path: '/translator',
            name: 'translator',
            builder: (context, state) {
              return const CopticTranslatorPage();
            },
          ),

          // =======================================================
          // MORE
          // =======================================================

          GoRoute(
            path: '/more',
            name: 'more',
            builder: (context, state) {
              return const MorePage();
            },
          ),

          // =======================================================
          // LITURGY (القداس)
          //
          // The KIND CHOOSER (Basil / Gregory / Cyril) must live
          // INSIDE the navigation shell so the bottom bar stays
          // visible when the user taps القداس in the bottom
          // navigation. The reader (/liturgy/:kind) remains
          // OUTSIDE the shell for immersive reading and
          // presentation mode.
          // =======================================================

          GoRoute(
            path: '/liturgy',
            name: 'liturgy',
            builder: (context, state) {
              return const LiturgyHomePage();
            },
          ),
        ],
      ),

      // =========================================================
      // AGPEYA PRAYERS
      //
      // Kept OUTSIDE the navigation shell on purpose: the
      // bottom NavigationBar would otherwise stay visible on
      // top of (and steal space from) the full-screen
      // PRESENTATION MODE when the phone is in landscape.
      // =========================================================

      GoRoute(
        path: '/agpeya/morning',
        name: 'agpeyaMorning',
        builder: (context, state) {
          return Consumer(
            builder: (context, ref, _) {
              final language =
                  ref.watch(preferencesProvider).contentLanguage;

              return AgpeyaPrayerPage(
                prayerId: 'morning',
                title: 'Morning Prayer',
                arabicTitle: 'صلاة باكر',
                language: _languageCode(language),
              );
            },
          );
        },
      ),

      GoRoute(
        path: '/agpeya/third',
        name: 'agpeyaThird',
        builder: (context, state) {
          return Consumer(
            builder: (context, ref, _) {
              final language =
                  ref.watch(preferencesProvider).contentLanguage;

              return AgpeyaPrayerPage(
                prayerId: 'third',
                title: 'Third Hour',
                arabicTitle: 'الساعة الثالثة',
                language: _languageCode(language),
              );
            },
          );
        },
      ),

      GoRoute(
        path: '/agpeya/sixth',
        name: 'agpeyaSixth',
        builder: (context, state) {
          return Consumer(
            builder: (context, ref, _) {
              final language =
                  ref.watch(preferencesProvider).contentLanguage;

              return AgpeyaPrayerPage(
                prayerId: 'sixth',
                title: 'Sixth Hour',
                arabicTitle: 'الساعة السادسة',
                language: _languageCode(language),
              );
            },
          );
        },
      ),

      GoRoute(
        path: '/agpeya/ninth',
        name: 'agpeyaNinth',
        builder: (context, state) {
          return Consumer(
            builder: (context, ref, _) {
              final language =
                  ref.watch(preferencesProvider).contentLanguage;

              return AgpeyaPrayerPage(
                prayerId: 'ninth',
                title: 'Ninth Hour',
                arabicTitle: 'الساعة التاسعة',
                language: _languageCode(language),
              );
            },
          );
        },
      ),

      GoRoute(
        path: '/agpeya/vespers',
        name: 'agpeyaVespers',
        builder: (context, state) {
          return Consumer(
            builder: (context, ref, _) {
              final language =
                  ref.watch(preferencesProvider).contentLanguage;

              return AgpeyaPrayerPage(
                prayerId: 'vespers',
                title: 'Vespers',
                arabicTitle: 'صلاة الغروب',
                language: _languageCode(language),
              );
            },
          );
        },
      ),

      GoRoute(
        path: '/agpeya/compline',
        name: 'agpeyaCompline',
        builder: (context, state) {
          return Consumer(
            builder: (context, ref, _) {
              final language =
                  ref.watch(preferencesProvider).contentLanguage;

              return AgpeyaPrayerPage(
                prayerId: 'compline',
                title: 'Compline',
                arabicTitle: 'صلاة النوم',
                language: _languageCode(language),
              );
            },
          );
        },
      ),

      GoRoute(
        path: '/agpeya/midnight',
        name: 'agpeyaMidnight',
        builder: (context, state) {
          return Consumer(
            builder: (context, ref, _) {
              final language =
                  ref.watch(preferencesProvider).contentLanguage;

              return AgpeyaPrayerPage(
                prayerId: 'midnight',
                title: 'Midnight Prayer',
                arabicTitle: 'صلاة نصف الليل',
                language: _languageCode(language),
              );
            },
          );
        },
      ),

      // =========================================================
      // LITURGY READER
      //
      // The chooser (/liturgy) lives INSIDE the navigation shell
      // (see ShellRoute above) so the bottom bar stays visible.
      // This reader route stays outside the shell so reading and
      // PRESENTATION MODE are fully immersive (no bottom
      // NavigationBar).
      // =========================================================

      // =========================================================
      // CALENDAR
      // =========================================================

      GoRoute(
        path: '/calendar',
        name: 'calendar',
        builder: (context, state) {
          return const CalendarPage();
        },
      ),

// =========================================================
      // TRANEEM (الترانيم)
      //
      // Text-only hymn lyrics (no audio / streaming). A main
      // screen plus a reader page. Kept OUTSIDE the navigation
      // shell so the reader is immersive; reached from the
      // More page.
      // =========================================================

      GoRoute(
        path: '/traneem',
        name: 'traneem',
        builder: (context, state) {
          return const TraneemPage();
        },
      ),

      GoRoute(
        path: '/traneem/:id',
        name: 'traneemReader',
        builder: (context, state) {
          return Consumer(
            builder: (context, ref, _) {
              final language =
                  ref.watch(preferencesProvider).contentLanguage;

              return TraneemReaderPage(
                hymnId: state.pathParameters['id'] ?? '',
                language: _languageCode(language),
              );
            },
          );
        },
      ),

      // =========================================================
      // SAVED / BOOKMARKS (المحفوظات)
      // =========================================================

      GoRoute(
        path: '/saved',
        name: 'saved',
        builder: (context, state) {
          return const SavedPage();
        },
      ),
      // =========================================================
      // ADMIN
      // =========================================================

      GoRoute(
        path: '/admin',
        name: 'admin',
        builder: (context, state) {
          return const AdminBiblePage();
        },
      ),

      // =========================================================
      // DOCUMENT READER
      // /reader/:id
      // =========================================================

      GoRoute(
        path: '/reader/:id',
        name: 'reader',
        builder: (context, state) {
          return DocumentReaderPage(
            documentId:
                state.pathParameters['id']!,
          );
        },
      ),

      // =========================================================
      // BIBLE CHAPTER READER
      // /chapter/genesis-1
      // /chapter/exodus-1
      // etc.
      // =========================================================

      GoRoute(
        path: '/chapter/:id',
        name: 'chapter',
        builder: (context, state) {
          final chapterId =
              state.pathParameters['id'] ?? '';

          // Optional role hint (?role=people|deacons|priests)
          final role = state.uri.queryParameters['role'];

          return BibleChapterReaderPage(
            chapterId: chapterId,
            roleHint: role,
          );
        },
      ),

      // =========================================================
      // LITURGY READER
      // /liturgy/basil | /liturgy/gregory | /liturgy/cyril
      //
      // Outside the navigation shell so reading and
      // PRESENTATION MODE are fully immersive (no bottom
      // NavigationBar).
      // =========================================================

      GoRoute(
        path: '/liturgy/:kind',
        name: 'liturgyKind',
        builder: (context, state) {
          return Consumer(
            builder: (context, ref, _) {
              final language = ref
                  .watch(preferencesProvider)
                  .contentLanguage;

              return LiturgyReaderPage(
                kindId:
                    state.pathParameters['kind'] ??
                        'basil',

                language:
                    _languageCode(language),
              );
            },
          );
        },
      ),

      // =========================================================
      // SETTINGS - APPEARANCE
      // =========================================================

      GoRoute(
        path: '/settings/appearance',
        name: 'appearanceSettings',
        builder: (context, state) {
          return const AppearanceSettingsPage();
        },
      ),

      // =========================================================
      // SETTINGS - LANGUAGE
      // =========================================================

      GoRoute(
        path: '/settings/language',
        name: 'languageSettings',
        builder: (context, state) {
          return const LanguageSettingsPage();
        },
      ),
    ],
  );
});

// =========================================================
// HELPERS
// =========================================================

/// Maps the app content language preference to the
/// language code used by the Agpeya asset folders.
String _languageCode(AppLanguage language) {
  return language == AppLanguage.arabic ? 'ar' : 'en';
}
