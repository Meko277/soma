import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'traneem_content_repository.dart';

final traneemContentRepositoryProvider = Provider<TraneemContentRepository>(
  (ref) => const TraneemContentRepository(),
);
