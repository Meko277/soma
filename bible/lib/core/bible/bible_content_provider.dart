import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'bible_content_repository.dart';

final bibleContentRepositoryProvider = Provider<BibleContentRepository>(
  (ref) => BibleContentRepository(),
);