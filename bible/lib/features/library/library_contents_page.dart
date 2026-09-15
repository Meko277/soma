import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/preferences/app_preferences.dart';
import '../../core/preferences/preferences_provider.dart';
import '../../core/sync/firebase_sync_service.dart';
import '../../widgets/bilingual_text.dart';

class LibraryContentsPage extends ConsumerStatefulWidget {
  const LibraryContentsPage({super.key});

  @override
  ConsumerState<LibraryContentsPage> createState() =>
      _LibraryContentsPageState();
}

class _LibraryContentsPageState extends ConsumerState<LibraryContentsPage> {
  List<Map<String, dynamic>> _managedContent = const [];

  @override
  void initState() {
    super.initState();
    _loadManagedContent();
    FirebaseSyncService.instance.contentStream.listen((items) {
      if (mounted) setState(() => _managedContent = items);
    });
  }

  Future<void> _loadManagedContent() async {
    final items = await FirebaseSyncService.instance.getCached(
      FirebaseSyncService.cacheContent,
    );
    if (mounted) setState(() => _managedContent = items);
  }

  @override
  Widget build(BuildContext context) {
    final ref = this.ref;
    final isArabic =
        ref.watch(preferencesProvider).interfaceLanguage == AppLanguage.arabic;
    final entries = <_LibraryEntry>[
      _LibraryEntry(
        'bible',
        'The Holy Bible',
        'الكتاب المقدس',
        Icons.menu_book_outlined,
        '/bible',
      ),
      _LibraryEntry(
        'agpeya',
        'Agpeya',
        'أجبية',
        Icons.nightlight_outlined,
        '/agpeya',
      ),
      _LibraryEntry(
        'psalmody',
        'Psalmody',
        'الإبصلمودية',
        Icons.music_note_outlined,
        '/traneem',
      ),
      _LibraryEntry(
        'liturgy',
        'Divine Liturgies',
        'القداسات',
        Icons.church_outlined,
        '/liturgy',
      ),
      _LibraryEntry(
        'readings',
        'Readings',
        'القراءات',
        Icons.auto_stories_outlined,
        '/readings',
      ),
      _LibraryEntry(
        'index',
        'Index',
        'فهرس',
        Icons.list_alt_outlined,
        '/reader/index',
      ),
      _LibraryEntry(
        'occasions',
        'Occasions',
        'مناسبات',
        Icons.event_outlined,
        '/reader/occasions',
      ),
      _LibraryEntry(
        'apostles',
        'Apostles',
        'الرسل',
        Icons.people_outline,
        '/reader/apostles',
      ),
      _LibraryEntry(
        'rites',
        'Rites',
        'طقوس',
        Icons.volunteer_activism_outlined,
        '/reader/rites',
      ),
      ..._managedContent.map(
        (item) => _LibraryEntry(
          item['id']?.toString() ?? 'content',
          item['titleEn']?.toString() ?? 'App Content',
          item['titleAr']?.toString() ?? item['titleEn']?.toString() ?? 'محتوى',
          Icons.description_outlined,
          '/reader/${item['id']}',
        ),
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: BilingualText(
          english: 'Library Contents',
          arabic: 'محتويات المكتبة',
          primaryIsArabic: isArabic,
          spacing: 1,
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
      ),
      body: GridView.builder(
        padding: const EdgeInsets.fromLTRB(18, 18, 18, 32),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 12,
          mainAxisSpacing: 18,
          childAspectRatio: .82,
        ),
        itemCount: entries.length,
        itemBuilder: (context, index) {
          final entry = entries[index];
          return InkWell(
            borderRadius: BorderRadius.circular(18),
            onTap: () => context.push(entry.route),
            child: Column(
              children: [
                Expanded(
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Theme.of(
                        context,
                      ).colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: Theme.of(context).colorScheme.outlineVariant,
                      ),
                    ),
                    child: Icon(
                      entry.icon,
                      size: 46,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  isArabic ? entry.arabic : entry.english,
                  maxLines: 2,
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _LibraryEntry {
  const _LibraryEntry(
    this.id,
    this.english,
    this.arabic,
    this.icon,
    this.route,
  );

  final String id;
  final String english;
  final String arabic;
  final IconData icon;
  final String route;
}
