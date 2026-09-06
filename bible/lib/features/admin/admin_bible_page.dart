import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/bible/bible_content_provider.dart';
import '../../core/bible/bible_models.dart';

class AdminBiblePage extends ConsumerStatefulWidget {
  const AdminBiblePage({super.key});

  @override
  ConsumerState<AdminBiblePage> createState() => _AdminBiblePageState();
}

class _AdminBiblePageState extends ConsumerState<AdminBiblePage> {
  BibleBook? _selectedBook;
  int _selectedChapter = 1;

  @override
  Widget build(BuildContext context) {
    final repository = ref.watch(bibleContentRepositoryProvider);
    final books = repository.books;

    final chaptersCount = _selectedBook?.chapterCount ?? 0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Bible Content Admin'),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 960),
          child: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              Text(
                'Manage Bible Content',
                style: Theme.of(context)
                    .textTheme
                    .headlineMedium
                    ?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),

              const SizedBox(height: 8),

              const Text(
                'Select a Bible book and chapter to preview its offline content.',
              ),

              const SizedBox(height: 24),

              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      DropdownButtonFormField<BibleBook>(
                        decoration: const InputDecoration(
                          labelText: 'Bible Book',
                          border: OutlineInputBorder(),
                        ),
                        initialValue: _selectedBook,
                        isExpanded: true,
                        items: books.map((book) {
                          return DropdownMenuItem<BibleBook>(
                            value: book,
                            child: Text(
                              '${book.arabicName} — ${book.name}',
                            ),
                          );
                        }).toList(),
                        onChanged: (book) {
                          if (book == null) return;

                          setState(() {
                            _selectedBook = book;
                            _selectedChapter = 1;
                          });
                        },
                      ),

                      const SizedBox(height: 16),

                      if (_selectedBook != null)
                        DropdownButtonFormField<int>(
                          decoration: const InputDecoration(
                            labelText: 'Chapter',
                            border: OutlineInputBorder(),
                          ),
                          initialValue: _selectedChapter,
                          items: List.generate(
                            chaptersCount,
                            (index) => DropdownMenuItem<int>(
                              value: index + 1,
                              child: Text(
                                'Chapter ${index + 1}',
                              ),
                            ),
                          ),
                          onChanged: (value) {
                            if (value == null) return;

                            setState(() {
                              _selectedChapter = value;
                            });
                          },
                        ),

                      const SizedBox(height: 20),

                      if (_selectedBook == null)
                        const Text(
                          'Select a book to continue.',
                        )
                      else
                        FutureBuilder<BibleChapter?>(
                          future: repository.loadChapter(
                            bookId: _selectedBook!.id,
                            chapterNumber: _selectedChapter,
                            language: 'ar',
                          ),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const Center(
                                child: Padding(
                                  padding: EdgeInsets.all(20),
                                  child: CircularProgressIndicator(),
                                ),
                              );
                            }

                            if (snapshot.hasError) {
                              return Text(
                                'Error loading chapter:\n${snapshot.error}',
                                style: TextStyle(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .error,
                                ),
                              );
                            }

                            final chapter = snapshot.data;

                            if (chapter == null) {
                              return const Padding(
                                padding: EdgeInsets.all(16),
                                child: Text(
                                  'Chapter content could not be loaded.',
                                ),
                              );
                            }

                            return Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.stretch,
                              children: [
                                const Divider(),

                                const SizedBox(height: 12),

                                Text(
                                  '${_selectedBook!.arabicName} '
                                  '— الإصحاح $_selectedChapter',
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleLarge
                                      ?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),

                                const SizedBox(height: 16),

                                ...chapter.verses.map(
                                  (verse) => Padding(
                                    padding:
                                        const EdgeInsets.only(bottom: 12),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        SizedBox(
                                          width: 32,
                                          child: Text(
                                            '${verse.number}',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .primary,
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          child: Text(
                                            verse.text,
                                            textDirection:
                                                TextDirection.rtl,
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyLarge
                                                ?.copyWith(
                                                  height: 1.7,
                                                ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 28),

              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Bible Statistics',
                        style: Theme.of(context)
                            .textTheme
                            .titleLarge
                            ?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),

                      const SizedBox(height: 16),

                      Text(
                        'Total books: ${books.length}',
                      ),

                      const SizedBox(height: 6),

                      Text(
                        'Old Testament: ${books.where((book) => book.testament == BibleTestament.old).length}',
                      ),

                      const SizedBox(height: 6),

                      Text(
                        'New Testament: ${books.where((book) => book.testament == BibleTestament.newTestament).length}',
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}