import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/localization/app_strings.dart';
import '../../core/preferences/preferences_provider.dart';
import '../../core/traneem/traneem_content_providers.dart';
import '../../core/traneem/traneem_models.dart';
import '../../widgets/bilingual_text.dart';

// ================================================================
// TRANEEM PAGE (الترانيم)
//
// The main Traneem screen: a searchable list of hymns whose
// lyrics/words open in the traneem reader. Text-only by design
// (no audio, no streaming, no video).
// ================================================================

class TraneemPage extends ConsumerStatefulWidget {
  const TraneemPage({super.key});

  @override
  ConsumerState<TraneemPage> createState() => _TraneemPageState();
}

class _TraneemPageState extends ConsumerState<TraneemPage> {
  final TextEditingController _searchController =
      TextEditingController();

  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchQuery =
            _searchController.text.trim().toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final repository =
        ref.watch(traneemContentRepositoryProvider);

    final strings = AppStrings(
      ref.watch(preferencesProvider).interfaceLanguage,
    );

    final theme = Theme.of(context);

    final allHymns = repository.hymns;

    final filtered = allHymns.where((hymn) {
      if (_searchQuery.isEmpty) {
        return true;
      }
      return hymn.title
              .toLowerCase()
              .contains(_searchQuery) ||
          hymn.arabicTitle.contains(_searchQuery) ||
          hymn.id
              .toLowerCase()
              .contains(_searchQuery);
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: BilingualText(
          english: strings.traneem,
          arabic: 'الترانيم',
          primaryIsArabic: strings.isArabic,
          spacing: 1,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          20,
          20,
          20,
          32,
        ),
        children: [
          // ----------------------------------------------------
          // HEADER (bilingual format)
          // ----------------------------------------------------
          BilingualText(
            english: strings.traneemHeading,
            arabic: 'الترانيم',
            primaryIsArabic: strings.isArabic,
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 6),

          Text(strings.traneemSubtitle),

          const SizedBox(height: 20),

          // ----------------------------------------------------
          // SEARCH
          // ----------------------------------------------------
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () => _searchController.clear(),
                    )
                  : null,
              hintText: strings.searchTraneem,
            ),
          ),

          const SizedBox(height: 20),

          if (filtered.isEmpty) ...[
            Center(child: Text(strings.noHymnsFound)),
            const SizedBox(height: 12),
          ],

          // ----------------------------------------------------
          // HYMN LIST
          // ----------------------------------------------------
          ...filtered.map((hymn) => _buildHymnCard(hymn)),
        ],
      ),
    );
  }

  Widget _buildHymnCard(TraneemHymnMeta hymn) {
    final theme = Theme.of(context);

    final strings = AppStrings(
      ref.watch(preferencesProvider).interfaceLanguage,
    );

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => context.push('/traneem/${hymn.id}'),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  Icons.music_note_outlined,
                  color: theme.colorScheme.primary,
                ),
              ),

              const SizedBox(width: 16),

              Expanded(
                child: BilingualText(
                  english: hymn.title,
                  arabic: hymn.arabicTitle,
                  primaryIsArabic: strings.isArabic,
                  spacing: 3,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }
}