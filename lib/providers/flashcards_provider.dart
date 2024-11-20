import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models.dart';
import 'dart:math';

// StateNotifier to manage flashcards for a flashcard set
class FlashcardsNotifier extends StateNotifier<List<Flashcard>> {
  List<Flashcard> _originalFlashcardsOrder = [];
  bool _isShuffled = false;

  FlashcardsNotifier() : super([]);

  void addFlashcard(String term, String definition) {
    final newFlashcard = Flashcard(term, definition);
    _originalFlashcardsOrder.add(newFlashcard);  // Add to the original order
    state = List.from(_originalFlashcardsOrder);  // Ensure state reflects the original order
  }

  void editFlashcard(int index, String newTerm, String newDefinition) {
    final updatedFlashcards = List<Flashcard>.from(state);
    updatedFlashcards[index].term = newTerm;
    updatedFlashcards[index].definition = newDefinition;
    _originalFlashcardsOrder = updatedFlashcards;
    state = updatedFlashcards;
  }

  void deleteFlashcard(int index) {
    final updatedFlashcards = List<Flashcard>.from(state)..removeAt(index);
    state = updatedFlashcards;
  }

  // Shuffle the flashcards
  void shuffle() {
    final random = Random();
    final shuffled = List<Flashcard>.from(_originalFlashcardsOrder);  // Copy original order
    shuffled.shuffle(random);  // Shuffle the list
    state = shuffled;  // Update the state with the shuffled list
    _isShuffled = true;  // Mark the flashcards as shuffled
  }

  // Restore the original order
  void restoreOrder() {
    state = List.from(_originalFlashcardsOrder);  // Restore original order
    _isShuffled = false;  // Mark the flashcards as not shuffled
  }

  bool get isShuffled => _isShuffled;  // Getter to check if shuffled
}


final flashcardsProvider = StateNotifierProvider.family<FlashcardsNotifier, List<Flashcard>, FlashcardSet>(
  (ref, flashcardSet) => FlashcardsNotifier(),
);

final isShuffledProvider = StateProvider.family<bool, FlashcardSet>((ref, flashcardSet) {
  final flashcardsNotifier = ref.watch(flashcardsProvider(flashcardSet).notifier);
  return flashcardsNotifier.isShuffled;
});
