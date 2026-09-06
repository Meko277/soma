import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/chapter.dart';

final chapterRepositoryProvider = Provider<ChapterRepository>((ref) {
  return ChapterRepository(FirebaseFirestore.instance);
});

final chaptersStreamProvider = StreamProvider<List<Chapter>>((ref) {
  final repository = ref.watch(chapterRepositoryProvider);
  return repository.getChapters();
});

class ChapterRepository {
  final FirebaseFirestore _firestore;

  ChapterRepository(this._firestore);

  Stream<List<Chapter>> getChapters() {
    return _firestore
        .collection('chapters')
        .orderBy('chapterNumber')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return Chapter.fromMap(
          doc.id,
          doc.data(),
        );
      }).toList();
    });
  }
}