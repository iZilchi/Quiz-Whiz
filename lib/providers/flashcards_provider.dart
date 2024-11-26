import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models.dart';

class FlashcardsNotifier extends StateNotifier<List<Flashcard>> {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final String subjectId;
  final String flashcardSetId;
  final String uid;  // User ID added

  List<Flashcard> _originalFlashcards = [];  // Store the original order of flashcards

  FlashcardsNotifier({required this.subjectId, required this.flashcardSetId, required this.uid}) : super([]) {
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
        .where('uid', isEqualTo: uid)
        .orderBy('createdAt', descending: false)
        .snapshots()
        .listen((snapshot) {
      state = snapshot.docs.map((doc) {
        final data = doc.data();
        return Flashcard(data['term'], data['definition'], doc.id);
      }).toList();

      _originalFlashcards = List.from(state);  // Save original order
    });
  }

  // Shuffle the flashcards
  void shuffleFlashcards() {
    state.shuffle();  // Shuffle the list in place
    state = List.from(state);  // Trigger a state update to notify listeners
  }

  // Restore the original order
  void restoreOriginalOrder() {
    state = List.from(_originalFlashcards);  // Reset to the original order
  }

  // CREATE
  Future<void> addFlashcard(String term, String definition, {String? imageUrl, required String uid}) async {
  final newFlashcard = Flashcard(term, definition, '');

  // Add to the state temporarily
  state = [...state, newFlashcard];

  // Add to the Firestore database with UID and timestamp
  await _db
      .collection('subjects')
      .doc(subjectId)
      .collection('flashcardSets')
      .doc(flashcardSetId)
      .collection('flashcards')
      .add({
    'term': term,
    'definition': definition,
    'uid': uid, // Associate with user ID
    'createdAt': FieldValue.serverTimestamp(), // Add creation timestamp
  });
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
  (ref, flashcardSet) {
    final uid = FirebaseAuth.instance.currentUser?.uid; // Get the user's UID from FirebaseAuth
    if (uid == null) {
      throw Exception('User is not authenticated');
    }
    return FlashcardsNotifier(
      subjectId: flashcardSet.flashcardSetSubjectId, // Ensure `flashcardSet` has `subjectId`
      flashcardSetId: flashcardSet.documentId,       // Use `flashcardSet.documentId` for the specific flashcard set
      uid: uid,                                      // Pass the user ID
    );
  },
);

final isShuffledProvider = StateProvider<bool>((ref) => false);  // Default is not shuffled
