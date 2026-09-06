import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/localization/app_strings.dart';
import '../core/preferences/preferences_provider.dart';

class AppNavigationScaffold extends ConsumerWidget {
  const AppNavigationScaffold({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = AppStrings(ref.watch(preferencesProvider).interfaceLanguage);
    final destinations = [
      (strings.home, Icons.home_outlined, '/'), (strings.bible, Icons.menu_book_outlined, '/bible'), (strings.agpeya, Icons.auto_stories_outlined, '/agpeya'), (strings.liturgy, Icons.church_outlined, '/liturgy'), (strings.translator, Icons.translate_outlined, '/translator'), (strings.more, Icons.more_horiz, '/more'),
    ];
    final location = GoRouterState.of(context).uri.path;
    final routeIndex = destinations.indexWhere(
      (destination) =>
          location == destination.$3 ||
          (destination.$3 != '/' &&
              location.startsWith('${destination.$3}/')),
    );
    final index = routeIndex < 0 ? 0 : routeIndex;
    return Scaffold(
      body: SafeArea(child: child),
      bottomNavigationBar: NavigationBar(
        selectedIndex: index,
        onDestinationSelected: (selected) => context.go(destinations[selected].$3),
        destinations: destinations.map((destination) => NavigationDestination(icon: Icon(destination.$2), selectedIcon: Icon(destination.$2), label: destination.$1)).toList(),
      ),
    );
  }
}
