import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models.dart';
import '../firebase/firestore_services.dart'; // Import FirestoreService

// StateNotifier to manage flashcard sets for a specific subject
class FlashcardSetsNotifier extends StateNotifier<List<FlashcardSet>> {
  final FirestoreService _firestoreService = FirestoreService();
  final String subjectId;
  final String uid; // Add uid to track the user's ID

  FlashcardSetsNotifier(this.subjectId, this.uid) : super([]) {
    // Initialize flashcard sets from Firestore
    _initializeFlashcardSets();
  }

  // READ flashcard sets from Firestore
  void _initializeFlashcardSets() {
    _firestoreService.getFlashcardSets(uid, subjectId).listen((flashcardSets) {
      state = flashcardSets;
    });
  }

  // CREATE a new flashcard set
  Future<void> addFlashcardSet(String title) async {
    // Create a new FlashcardSet with subjectId
    final newFlashcardSet = FlashcardSet(title, '', subjectId);

    // Optimistic update: Add the new flashcard set to the state before waiting for Firestore update
    state = [...state, newFlashcardSet];

    // Call Firestore service to add the flashcard set to Firestore
    await _firestoreService.addFlashcardSet(uid, subjectId, newFlashcardSet); // Pass uid to FirestoreService
  }

  // UPDATE an existing flashcard set
  Future<void> editFlashcardSet(int index, String newTitle) async {
    final flashcardSetId = state[index].documentId;
    final updatedSets = List<FlashcardSet>.from(state);
    updatedSets[index].title = newTitle;

    state = updatedSets; // Optimistic update
    await _firestoreService.updateFlashcardSet(subjectId, flashcardSetId, newTitle);
  }

  // DELETE a flashcard set
  Future<void> deleteFlashcardSet(int index) async {
    final flashcardSetId = state[index].documentId; // Assuming `id` is added to the FlashcardSet model
    final updatedSets = List<FlashcardSet>.from(state)..removeAt(index);

    state = updatedSets; // Optimistic update
    await _firestoreService.deleteFlashcardSet(subjectId, flashcardSetId);
  }
}

// Provider for FlashcardSetsNotifier
final flashcardSetsProvider = StateNotifierProvider.family<FlashcardSetsNotifier, List<FlashcardSet>, String>(
  (ref, subjectId) {
    final uid = FirebaseAuth.instance.currentUser?.uid; // Get the user's UID from FirebaseAuth
    if (uid == null) {
      throw Exception('User is not authenticated');
    }
    return FlashcardSetsNotifier(subjectId, uid);
  },
);
