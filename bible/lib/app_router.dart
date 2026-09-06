import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'core/bible/bible_content_provider.dart';
import 'features/bible/bible_book_chapters_page.dart';
import 'features/bible/bible_chapter_reader_page.dart';
import 'features/bible/bible_page.dart';
import '../../features/agpeya/agpeya_page.dart';

enum AppRoute {
  home,
  bible,
  bibleBook,
  chapter,
}

final routerProvider = Provider<GoRouter>((ref) {
  // =========================================================
  // BIBLE REPOSITORY
  // =========================================================

  final repository = ref.watch(bibleContentRepositoryProvider);

  return GoRouter(
    initialLocation: '/',

    routes: [
      // =========================================================
      // HOME
      // =========================================================

      GoRoute(
        path: '/',
        name: AppRoute.home.name,
        builder: (context, state) {
          return const Scaffold(
            body: Center(
              child: Text('Home'),
            ),
          );
        },
      ),

      // =========================================================
      // BIBLE BOOKS
      // /bible
      // =========================================================

      GoRoute(
        path: '/bible',
        name: AppRoute.bible.name,
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
      // =========================================================
      // BIBLE BOOK CHAPTERS
      // /bible/genesis
      // =========================================================
GoRoute(
  path: '/book/:bookId',
  name: AppRoute.bibleBook.name,
  builder: (context, state) {
    final bookId = state.pathParameters['bookId']!;

    final book = repository.bookById(bookId);

    if (book == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Bible'),
        ),
        body: Center(
          child: Text(
            'Book not found\n\nID: $bookId',
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return BibleBookChaptersPage(
      book: book,
    );
  },
),

      // =========================================================
      // BIBLE CHAPTER READER
      // /chapter/genesis-1
      // =========================================================

      GoRoute(
        path: '/chapter/:chapterId',
        name: AppRoute.chapter.name,
        builder: (context, state) {
          final chapterId =
              state.pathParameters['chapterId'] ?? '';

          return BibleChapterReaderPage(
            chapterId: chapterId,
          );
        },
      ),
    ],
  );
});