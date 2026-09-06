import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'content_repository.dart';
final contentRepositoryProvider = Provider<ContentRepository>((ref) => const ContentRepository());
