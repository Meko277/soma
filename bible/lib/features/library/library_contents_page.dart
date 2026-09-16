import 'dart:async';

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

/// Full Coptic Reader taxonomy, rendered live from the admin-edited
/// Firestore `content` collection (see admin LIBRARY_CATEGORIES):
/// psalmody / liturgies / vespers-matins-liturgy / antiphonary /
/// melodies / feasts / fasts / saints / fractions / doxologies /
/// psalies / papal / clergy / special-* (baptism, crowning, unction,
/// visitation, funeral, consecrations, prostration, pascha, lakkan).
///
/// Saving any doc in the admin updates the app at once while online
/// (FirebaseSyncService.contentStream + offline cache).
class _LibraryContentsPageState extends ConsumerState<LibraryContentsPage> {
  List<Map<String, dynamic>> _managedContent = const [];

  static const _categories = <_LibraryCategory>[
    _LibraryCategory('psalmody', 'Psalmody', 'الإبصلمودية', Icons.music_note_outlined),
    _LibraryCategory('liturgies', 'Liturgies', 'القداسات', Icons.church_outlined),
    _LibraryCategory('vespers-matins-liturgy', 'Vespers · Matins · Liturgy', 'عشية · باكر · القداس', Icons.nights_stay_outlined),
    _LibraryCategory('antiphonary', 'Antiphonary', 'الدفنار', Icons.library_music),
    _LibraryCategory('melodies', 'Melodies', 'الألحان', Icons.audiotrack),
    _LibraryCategory('feasts', 'Feasts', 'الأعياد', Icons.celebration_outlined),
    _LibraryCategory('fasts', 'Fasts', 'الأصوام', Icons.self_improvement),
    _LibraryCategory('saints', 'Saints', 'القديسون', Icons.people_outline),
    _LibraryCategory('fractions', 'Fractions', 'القسمة', Icons.call_split),
    _LibraryCategory('doxologies', 'Doxologies', 'الذكصولوجيات', Icons.star_border),
    _LibraryCategory('psalies', 'Psalies', 'الإبصاليات', Icons.list_outlined),
    _LibraryCategory('papal', 'Papal', 'الباباوي', Icons.account_balance),
    _LibraryCategory('clergy', 'Clergy', 'الإكليروس', Icons.groups_outlined),
    _LibraryCategory('special-baptism', 'Baptism', 'المعمودية', Icons.water_drop_outlined),
    _LibraryCategory('special-crowning', 'Crowning', 'الإكليل', Icons.favorite_border),
    _LibraryCategory('special-unction', 'Unction of the Sick', 'مسحة المرضى', Icons.healing),
    _LibraryCategory('special-visitation', 'Visitation', 'الافتقاد', Icons.home_outlined),
    _LibraryCategory('special-funeral', 'Funeral', 'الجناز', Icons.local_fire_department_outlined),
    _LibraryCategory('special-consecrations', 'Consecrations', 'التكريس والتدشين', Icons.volunteer_activism_outlined),
    _LibraryCategory('special-prostration', 'Prostration', 'السجدة', Icons.accessibility_new),
    _LibraryCategory('special-pascha', 'Holy Pascha', 'البصخة المقدسة', Icons.bedtime_outlined),
    _LibraryCategory('special-lakkan', 'Lakkan', 'اللقان', Icons.waves),
  ];

  StreamSubscription<List<Map<String, dynamic>>>? _contentSub;

  @override
  void initState() {
    super.initState();
    _loadManagedContent();
    // Exact-time updates: admin saves flow here at once while online.
    _contentSub = FirebaseSyncService.instance.contentStream.listen((items) {
      if (mounted) setState(() => _managedContent = items);
    });
  }

  @override
  void dispose() {
    _contentSub?.cancel();
    super.dispose();
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

    // Admin docs grouped by category id, so every Coptic Reader reading
    // added in the admin appears under its own section at once.
    final byCategory = <String, List<Map<String, dynamic>>>{};
    for (final item in _managedContent) {
      final cat = (item['category'] ?? 'library').toString();
      (byCategory[cat] ??= []).add(item);
    }

    String localizedTitle(Map<String, dynamic> item) {
      final en = (item['titleEn'] ?? '').toString().trim();
      final ar = (item['titleAr'] ?? '').toString().trim();
      final co = (item['titleCo'] ?? '').toString().trim();
      if (isArabic) return ar.isNotEmpty ? ar : (en.isNotEmpty ? en : co);
      return en.isNotEmpty ? en : (ar.isNotEmpty ? ar : co);
    }

    final sections = <_LibrarySection>[];
    for (final cat in _categories) {
      final docs = byCategory[cat.id] ?? const [];
      sections.add(
        _LibrarySection(
          category: cat,
          docs: docs
              .map(
                (item) => _LibraryEntry(
                  item['id']?.toString() ?? cat.id,
                  localizedTitle(item).isEmpty ? cat.english : localizedTitle(item),
                  localizedTitle(item).isEmpty ? cat.arabic : localizedTitle(item),
                  cat.icon,
                  '/reader/${item['id']}',
                ),
              )
              .toList(),
        ),
      );
    }
    // Any admin doc with an unknown/custom category still shows up.
    final known = _categories.map((c) => c.id).toSet();
    final extra = byCategory.entries
        .where((e) => !known.contains(e.key))
        .expand((e) => e.value)
        .map(
          (item) => _LibraryEntry(
            item['id']?.toString() ?? 'content',
            (item['titleEn'] ?? item['titleAr'] ?? 'App Content').toString(),
            (item['titleAr'] ?? item['titleEn'] ?? 'محتوى').toString(),
            Icons.description_outlined,
            '/reader/${item['id']}',
          ),
        )
        .toList();

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
      ...extra,
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
      body: ListView(
        padding: const EdgeInsets.fromLTRB(18, 18, 18, 32),
        children: [
          _buildGrid(context, entries, isArabic),
          for (final section in sections) ...[
            const SizedBox(height: 22),
            Row(
              children: [
                Icon(section.category.icon,
                    color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    isArabic
                        ? section.category.arabic
                        : section.category.english,
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 2),
                  decoration: BoxDecoration(
                    color: Theme.of(context)
                        .colorScheme
                        .primary
                        .withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${section.docs.length}',
                    style: Theme.of(context)
                        .textTheme
                        .labelMedium
                        ?.copyWith(
                            color:
                                Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            if (section.docs.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  isArabic
                      ? 'لا توجد قراءات بعد — أضفها من لوحة الإدارة.'
                      : 'No readings yet — add them from the admin panel.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context)
                          .colorScheme
                          .onSurfaceVariant),
                ),
              )
            else
              _buildGrid(context, section.docs, isArabic),
          ],
        ],
      ),
    );
  }

  Widget _buildGrid(
      BuildContext context, List<_LibraryEntry> entries, bool isArabic) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.only(top: 8),
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
    );
  }
}

class _LibraryCategory {
  const _LibraryCategory(this.id, this.english, this.arabic, this.icon);

  final String id;
  final String english;
  final String arabic;
  final IconData icon;
}

class _LibrarySection {
  const _LibrarySection({required this.category, required this.docs});

  final _LibraryCategory category;
  final List<_LibraryEntry> docs;
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
