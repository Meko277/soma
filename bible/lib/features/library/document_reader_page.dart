import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/sync/firebase_sync_service.dart';

import '../../core/content/content_providers.dart';
import '../../core/localization/app_strings.dart';
import '../../core/preferences/app_preferences.dart';
import '../../core/preferences/preferences_provider.dart';

class DocumentReaderPage extends ConsumerStatefulWidget {
  const DocumentReaderPage({super.key, required this.documentId});

  final String documentId;

  @override
  ConsumerState<DocumentReaderPage> createState() => _DocumentReaderPageState();
}

class _DocumentReaderPageState extends ConsumerState<DocumentReaderPage> {
  Map<String, dynamic>? _managedContent;
  StreamSubscription<List<Map<String, dynamic>>>? _contentSubscription;

  @override
  void initState() {
    super.initState();
    _loadManagedContent();
    _contentSubscription = FirebaseSyncService.instance.contentStream.listen((
      items,
    ) {
      if (!mounted) return;
      final match = items.where(
        (item) => item['id']?.toString() == widget.documentId,
      );
      setState(() => _managedContent = match.isEmpty ? null : match.first);
    });
  }

  @override
  void dispose() {
    _contentSubscription?.cancel();
    super.dispose();
  }

  Future<void> _loadManagedContent() async {
    final items = await FirebaseSyncService.instance.getCached(
      FirebaseSyncService.cacheContent,
    );
    if (!mounted) return;
    final match = items.where(
      (item) => item['id']?.toString() == widget.documentId,
    );
    if (match.isNotEmpty) setState(() => _managedContent = match.first);
  }

  @override
  Widget build(BuildContext context) {
    final ref = this.ref;
    final item = ref.read(contentRepositoryProvider).byId(widget.documentId);
    final managed = _managedContent;

    final preferences = ref.watch(preferencesProvider);

    final strings = AppStrings(preferences.interfaceLanguage);

    if (item == null && managed == null) {
      return Scaffold(
        appBar: AppBar(),
        body: Center(child: Text(strings.documentNotAvailable)),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _managedTitle(managed, preferences.interfaceLanguage == AppLanguage.arabic) ??
              item!.title,
        ),
        actions: const [
          IconButton(onPressed: null, icon: Icon(Icons.bookmark_border)),
          IconButton(onPressed: null, icon: Icon(Icons.share_outlined)),
        ],
      ),

      body: SelectionArea(
        child: ListView(
          padding: const EdgeInsets.all(24),

          children: [
            Text(
              _categoryLabel(
                managed?['category']?.toString() ?? item!.subtitle,
                preferences.interfaceLanguage == AppLanguage.arabic,
              ),
              style: TextStyle(color: Theme.of(context).colorScheme.primary),
            ),

            const SizedBox(height: 24),

            Text(
              _managedBody(
                    managed,
                    preferences.interfaceLanguage == AppLanguage.arabic,
                  ) ??
                  item!.body,

              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(height: 1.7),
            ),

            const SizedBox(height: 28),

            Text(
              strings.contentPacksTitle,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 6),

            Text(strings.contentPacksBody),
          ],
        ),
      ),
    );
  }

  String? _managedTitle(Map<String, dynamic>? content, bool arabic) {
    if (content == null) return null;
    String pick(String key) => (content[key] ?? '').toString().trim();
    final primary = arabic ? pick('titleAr') : pick('titleEn');
    if (primary.isNotEmpty) return primary;
    for (final fallback in ['titleEn', 'titleAr', 'titleCo']) {
      final candidate = pick(fallback);
      if (candidate.isNotEmpty) return candidate;
    }
    return null;
  }

  String _categoryLabel(String raw, bool arabic) {
    const labels = <String, List<String>>{
      'psalmody': ['Psalmody', 'الإبصلمودية'],
      'liturgies': ['Liturgies', 'القداسات'],
      'vespers-matins-liturgy': ['Vespers · Matins · Liturgy', 'عشية · باكر · القداس'],
      'antiphonary': ['Antiphonary', 'الدفنار'],
      'melodies': ['Melodies', 'الألحان'],
      'feasts': ['Feasts', 'الأعياد'],
      'fasts': ['Fasts', 'الأصوام'],
      'saints': ['Saints', 'القديسون'],
      'fractions': ['Fractions', 'القسمة'],
      'doxologies': ['Doxologies', 'الذكصولوجيات'],
      'psalies': ['Psalies', 'الإبصاليات'],
      'papal': ['Papal', 'الباباوي'],
      'clergy': ['Clergy', 'الإكليروس'],
      'special-baptism': ['Baptism', 'المعمودية'],
      'special-crowning': ['Crowning', 'الإكليل'],
      'special-unction': ['Unction of the Sick', 'مسحة المرضى'],
      'special-visitation': ['Visitation', 'الافتقاد'],
      'special-funeral': ['Funeral', 'الجناز'],
      'special-consecrations': ['Consecrations', 'التكريس والتدشين'],
      'special-prostration': ['Prostration', 'السجدة'],
      'special-pascha': ['Holy Pascha', 'البصخة المقدسة'],
      'special-lakkan': ['Lakkan', 'اللقان'],
    };
    final hit = labels[raw];
    if (hit == null) return raw;
    return arabic ? hit[1] : hit[0];
  }

  String? _managedBody(Map<String, dynamic>? content, bool arabic) {
    if (content == null) return null;
    final key = arabic ? 'bodyAr' : 'bodyEn';
    final value = content[key]?.toString();
    if (value != null && value.trim().isNotEmpty) return value;
    for (final fallback in ['bodyEn', 'bodyAr', 'bodyCo']) {
      final candidate = content[fallback]?.toString();
      if (candidate != null && candidate.trim().isNotEmpty) return candidate;
    }
    return null;
  }
}
