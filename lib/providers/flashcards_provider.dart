import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models.dart';

// StateNotifier to manage flashcards for a flashcard set
class FlashcardsNotifier extends StateNotifier<List<Flashcard>> {
  FlashcardsNotifier() : super([]);

  void addFlashcard(String term, String definition) {
    state = [...state, Flashcard(term, definition)];
  }

  void editFlashcard(int index, String newTerm, String newDefinition) {
    final updatedFlashcards = List<Flashcard>.from(state);
    updatedFlashcards[index].term = newTerm;
    updatedFlashcards[index].definition = newDefinition;
    state = updatedFlashcards;
  }

  void deleteFlashcard(int index) {
    final updatedFlashcards = List<Flashcard>.from(state)..removeAt(index);
    state = updatedFlashcards;
  }
}

final flashcardsProvider = StateNotifierProvider.family<FlashcardsNotifier, List<Flashcard>, FlashcardSet>(
  (ref, flashcardSet) => FlashcardsNotifier(),
);
