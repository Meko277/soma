import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/localization/app_strings.dart';
import '../../core/preferences/preferences_provider.dart';
import '../../widgets/section_card.dart';

class AudioPage extends ConsumerWidget {
  const AudioPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final preferences = ref.watch(preferencesProvider);

    final strings = AppStrings(preferences.interfaceLanguage);

    final titleStyle = Theme.of(
      context,
    ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold);

    return ListView(
      padding: const EdgeInsets.all(20),

      children: [
        Text(strings.audio, style: titleStyle),

        const SizedBox(height: 8),

        Text(strings.audioIntro),

        const SizedBox(height: 18),

        SectionCard(
          title: strings.continueListening,
          subtitle: strings.noAudioPlaying,
          icon: Icons.play_circle_outline,
        ),

        SectionCard(
          title: strings.downloadedAudio,
          subtitle: strings.availableOffline,
          icon: Icons.download_outlined,
        ),

        SectionCard(
          title: strings.playlists,
          subtitle: strings.playlistsSubtitle,
          icon: Icons.queue_music_outlined,
        ),
      ],
    );
  }
}
