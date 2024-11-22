import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models.dart';

class FlashcardsNotifier extends StateNotifier<List<Flashcard>> {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final String subjectId;
  final String flashcardSetId;

  FlashcardsNotifier({required this.subjectId, required this.flashcardSetId}) : super([]) {
    _fetchFlashcards();
  }

  // Fetch flashcards from Firestore
  void _fetchFlashcards() {
    _db
        .collection('subjects')
        .doc(subjectId)
        .collection('flashcardSets')
        .doc(flashcardSetId)
        .collection('flashcards')
        .snapshots()
        .listen((snapshot) {
      state = snapshot.docs.map((doc) {
        final data = doc.data();
        return Flashcard(data['term'], data['definition'], doc.id);
      }).toList();
    });
  }

  // CREATE
  Future<void> addFlashcard(String term, String definition) async {
    final newFlashcard = Flashcard(term, definition, '');

    //add to the state
    state = [...state, newFlashcard];

    //add to database
    await _db
        .collection('subjects')
        .doc(subjectId)
        .collection('flashcardSets')
        .doc(flashcardSetId)
        .collection('flashcards')
        .add({'term': term, 'definition': definition});
  }

  // UPDATE
  Future<void> editFlashcard(String flashcardId, String newTerm, String newDefinition) async {
    await _db
        .collection('subjects')
        .doc(subjectId)
        .collection('flashcardSets')
        .doc(flashcardSetId)
        .collection('flashcards')
        .doc(flashcardId)
        .update({'term': newTerm, 'definition': newDefinition});
  }

  // DELETE
  Future<void> deleteFlashcard(String flashcardId) async {
    await _db
        .collection('subjects')
        .doc(subjectId)
        .collection('flashcardSets')
        .doc(flashcardSetId)
        .collection('flashcards')
        .doc(flashcardId)
        .delete();
  }
}

// Provider for flashcards with Firestore integration
final flashcardsProvider = StateNotifierProvider.family<FlashcardsNotifier, List<Flashcard>, FlashcardSet>(
  (ref, flashcardSet) => FlashcardsNotifier(
    subjectId: flashcardSet.flashcardSetSubjectId, // Ensure `flashcardSet` has `subjectId`
    flashcardSetId: flashcardSet.documentId,   // Use `flashcardSet.documentId` for the specific flashcard set
  ),
);

