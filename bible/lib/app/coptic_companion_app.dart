import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/preferences/preferences_provider.dart';
import '../core/preferences/app_preferences.dart';
import 'router/app_router.dart';
import 'theme/app_theme.dart';

class CopticCompanionApp extends ConsumerWidget {
  const CopticCompanionApp({super.key});

  @override
  Widget build(
    BuildContext context,
    WidgetRef ref,
  ) {
    final preferences =
        ref.watch(preferencesProvider);

    final router =
        ref.watch(appRouterProvider);

    return MaterialApp.router(
      title: 'Soma',
      debugShowCheckedModeBanner: false,

      theme: AppTheme.beige,
      darkTheme: AppTheme.blue,
      themeMode: preferences.themeMode,

      routerConfig: router,

      builder: (context, child) {
        return MediaQuery(
          // Apply the user's chosen text size
          // (font scale) to the whole app.
          data: MediaQuery.of(context).copyWith(
            textScaler: TextScaler.linear(
              preferences.fontScale,
            ),
          ),
          child: Directionality(
            textDirection:
                preferences.interfaceLanguage.isRtl
                    ? TextDirection.rtl
                    : TextDirection.ltr,
            child:
                child ?? const SizedBox.shrink(),
          ),
        );
      },
    );
  }
}