import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models.dart';

// StateNotifier to manage flashcard sets for a specific subject
class FlashcardSetsNotifier extends StateNotifier<List<FlashcardSet>> {
  FlashcardSetsNotifier() : super([]);

  void addFlashcardSet(String title) {
    state = [...state, FlashcardSet(title)];
  }

  void editFlashcardSet(int index, String newTitle) {
    final updatedSets = List<FlashcardSet>.from(state);
    updatedSets[index].title = newTitle;
    state = updatedSets;
  }

  void deleteFlashcardSet(int index) {
    final updatedSets = List<FlashcardSet>.from(state)..removeAt(index);
    state = updatedSets;
  }
}

final flashcardSetsProvider = StateNotifierProvider.family<FlashcardSetsNotifier, List<FlashcardSet>, Subject>(
  (ref, subject) => FlashcardSetsNotifier(),
);
