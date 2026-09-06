import 'package:bible/features/chapters/data/chapter_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The main screen that displays a list of chapters.
class ChapterListScreen extends ConsumerWidget {
  const ChapterListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the provider. This widget will rebuild whenever the stream emits new data.
    final chaptersAsyncValue = ref.watch(chaptersStreamProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Bible Chapters'),
      ),
      // The `when` method is a clean way to handle the different states
      // of an async operation (loading, error, data).
      body: chaptersAsyncValue.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(child: Text('An error occurred: $error')),
        data: (chapters) {
          if (chapters.isEmpty) {
            return const Center(
              child: Text('No chapters found. Add a chapter in the admin site.'),
            );
          }
          return ListView.builder(
            itemCount: chapters.length,
            itemBuilder: (context, index) {
              final chapter = chapters[index];
              return ListTile(
                leading: CircleAvatar(child: Text(chapter.chapterNumber.toString())),
                title: Text(chapter.title),
                subtitle: Text(
                  chapter.content,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              );
            },
          );
        },
      ),
    );
  }
}