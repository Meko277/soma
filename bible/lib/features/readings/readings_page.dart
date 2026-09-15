import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/readings/church_reading.dart';
import '../../core/sync/firebase_sync_service.dart';
import '../../core/localization/app_strings.dart';
import '../../core/preferences/preferences_provider.dart';

class ReadingsPage extends ConsumerStatefulWidget {
  const ReadingsPage({super.key});

  @override
  ConsumerState<ReadingsPage> createState() => _ReadingsPageState();
}

class _ReadingsPageState extends ConsumerState<ReadingsPage> {
  List<ChurchReading> _readings = const [];
  StreamSubscription<List<Map<String, dynamic>>>? _subscription;

  @override
  void initState() {
    super.initState();
    _loadCached();
    _subscription = FirebaseSyncService.instance.readingsStream.listen((data) {
      if (!mounted) return;
      setState(() {
        _readings = data.map(ChurchReading.fromJson).toList();
      });
    });
  }

  Future<void> _loadCached() async {
    final data = await FirebaseSyncService.instance.getCached(
      FirebaseSyncService.cacheReadings,
    );
    if (!mounted || data.isEmpty) return;
    setState(() {
      _readings = data.map(ChurchReading.fromJson).toList();
    });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings(
      ref.watch(preferencesProvider).interfaceLanguage,
    );
    final readings = _readings;

    return Scaffold(
      appBar: AppBar(title: Text(strings.isArabic ? 'القراءات' : 'Readings')),
      body: readings.isEmpty
          ? _emptyState(strings)
          : ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
              itemCount: readings.length,
              separatorBuilder: (_, _) => const SizedBox(height: 10),
              itemBuilder: (context, index) => _ReadingCard(
                reading: readings[index],
                isArabic: strings.isArabic,
              ),
            ),
    );
  }

  Widget _emptyState(AppStrings strings) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Text(
          strings.isArabic
              ? 'لا توجد قراءات متزامنة بعد.'
              : 'No synced readings are available yet.',
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

class _ReadingCard extends StatelessWidget {
  const _ReadingCard({required this.reading, required this.isArabic});

  final ChurchReading reading;
  final bool isArabic;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Directionality(
          textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                reading.title,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (reading.type.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  reading.type,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: theme.colorScheme.primary,
                  ),
                ),
              ],
              const Divider(height: 24),
              for (final paragraph in reading.content) ...[
                Text(
                  paragraph,
                  style: theme.textTheme.bodyLarge?.copyWith(height: 1.8),
                ),
                const SizedBox(height: 10),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
