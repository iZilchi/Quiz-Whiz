import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models.dart';
import '../providers/flashcards_provider.dart'; // Import the provider

final hoverIndexProvider = StateProvider<int?>((ref) => null);
final currentFlashcardIndexProvider = StateProvider<int>((ref) => 0);
final isShowingTermProvider = StateProvider<bool>((ref) => true);


class AddFlashcardScreen extends ConsumerWidget {
  final FlashcardSet flashcardSet;

  const AddFlashcardScreen({super.key, required this.flashcardSet});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final flashcards = ref.watch(flashcardsProvider(flashcardSet)); // Watch the flashcards
    final currentFlashcardIndex = ref.watch(currentFlashcardIndexProvider);
    // final isShuffled = ref.watch(isShuffledProvider(flashcardSet));

    void addFlashcard() {
      TextEditingController termController = TextEditingController();
      TextEditingController definitionController = TextEditingController();

      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Create Flashcard'),
            content: Column(
              mainAxisSize: MainAxisSize.min, // Ensure the dialog is not too large
              children: [
                TextField(
                  controller: termController,
                  decoration: const InputDecoration(labelText: 'Term'),
                ),
                TextField(
                  controller: definitionController,
                  decoration: const InputDecoration(labelText: 'Definition'),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  final term = termController.text.trim();
                  final definition = definitionController.text.trim();
                  if (term.isNotEmpty && definition.isNotEmpty) {
                    ref
                        .read(flashcardsProvider(flashcardSet).notifier)
                        .addFlashcard(term, definition); // Add flashcard
                    Navigator.pop(context);
                  }
                },
                child: const Text('Add'),
              ),
            ],
          );
        },
      );
    }

    void editFlashcard(int index) {
      // Get the flashcard to edit
      final flashcard = ref.read(flashcardsProvider(flashcardSet))[index];
      
      // Initialize controllers with the current values
      TextEditingController termController = TextEditingController(text: flashcard.term);
      TextEditingController definitionController = TextEditingController(text: flashcard.definition);

      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Edit Flashcard'),
            content: Column(
              mainAxisSize: MainAxisSize.min, // Prevent oversized dialog
              children: [
                TextField(
                  controller: termController,
                  decoration: const InputDecoration(labelText: 'Term'),
                ),
                TextField(
                  controller: definitionController,
                  decoration: const InputDecoration(labelText: 'Definition'),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  // Get the updated values
                  final updatedTerm = termController.text.trim();
                  final updatedDefinition = definitionController.text.trim();

                  // Apply changes only if both fields are not empty
                  if (updatedTerm.isNotEmpty && updatedDefinition.isNotEmpty) {
                    ref
                        .read(flashcardsProvider(flashcardSet).notifier)
                        .editFlashcard(flashcard.documentId, updatedTerm, updatedDefinition);
                  }

                  Navigator.pop(context); // Close the dialog
                },
                child: const Text('Save'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context), // Close dialog without saving
                child: const Text('Cancel'),
              ),
            ],
          );
        },
      );
    }

    void deleteFlashcard(int index) {
      final flashcards = ref.read(flashcardsProvider(flashcardSet));
      
      if (index >= 0 && index < flashcards.length) {
        //get flashcard id
        final flashcardId = flashcards[index].documentId;
        // Remove the flashcard
        ref.read(flashcardsProvider(flashcardSet).notifier).deleteFlashcard(flashcardId);
        
        // Adjust the current flashcard index
        final newFlashcardCount = flashcards.length - 1;
        if (newFlashcardCount == 0) {
          // No flashcards left, reset the index to 0
          ref.read(currentFlashcardIndexProvider.notifier).state = 0;
        } else if (index >= newFlashcardCount) {
          // If the deleted flashcard was the last one, move to the new last index
          ref.read(currentFlashcardIndexProvider.notifier).state = newFlashcardCount - 1;
        }
      }
    }

    void navigateToPreviousFlashcard() {
      if (flashcards.isNotEmpty) {
        ref.read(currentFlashcardIndexProvider.notifier).state =
            (currentFlashcardIndex - 1 + flashcards.length) % flashcards.length;
      }
    }

    void navigateToNextFlashcard() {
      if (flashcards.isNotEmpty) {
        ref.read(currentFlashcardIndexProvider.notifier).state =
            (currentFlashcardIndex + 1) % flashcards.length;
      }
    }

    // Function to shuffle flashcards
    // void toggleShuffle() {
      // if (isShuffled) {
      //   // If currently shuffled, restore the original order
      //   ref.read(flashcardsProvider(flashcardSet).notifier).restoreOrder();
      // } else {
      //   // If not shuffled, shuffle the flashcards
      //   ref.read(flashcardsProvider(flashcardSet).notifier).shuffle();
      // }
      // // Toggle shuffle state
      // ref.read(isShuffledProvider(flashcardSet).notifier).state = !isShuffled;
    // }

    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        title: Text('Flashcards for ${flashcardSet.title}'),
        backgroundColor: Colors.grey[200],
      ),
      body: flashcards.isEmpty
          ? const Center(child: Text('No flashcards created yet.'))
          : Center(
              child: GestureDetector(
                onTap: () {
                  //Toggle between term and definition
                  ref.read(isShowingTermProvider.notifier).state = !ref.read(isShowingTermProvider);
                },
                child: Card(
                  elevation: 5,
                  margin: const EdgeInsets.all(16),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          ref.watch(isShowingTermProvider)
                              ? flashcards[currentFlashcardIndex].term
                              : flashcards[currentFlashcardIndex].definition,
                          style: const TextStyle(
                              fontSize: 24, fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.arrow_back, color: Colors.blue),
                              onPressed: navigateToPreviousFlashcard,
                            ),
                            IconButton(
                              icon: const Icon(Icons.arrow_forward, color: Colors.blue),
                              onPressed: navigateToNextFlashcard,
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // IconButton(
                            //   icon: Icon(
                            //     isShuffled ? Icons.shuffle_on : Icons.shuffle,
                            //     color: Colors.orange,
                            //   ),
                            //   onPressed: toggleShuffle,
                            // ),
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.blue),
                              onPressed: () {
                                editFlashcard(currentFlashcardIndex);
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () {
                                deleteFlashcard(currentFlashcardIndex);
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: addFlashcard,
        backgroundColor: const Color.fromARGB(255, 255, 255, 255),
        child: const Icon(Icons.add),
      ),
    );
  }
}
