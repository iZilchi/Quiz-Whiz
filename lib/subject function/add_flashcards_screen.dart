import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models.dart';
import '../providers/flashcards_provider.dart'; // Import the provider

final hoverIndexProvider = StateProvider<int?>((ref) => null);
final currentFlashcardIndexProvider = StateProvider<int>((ref) => 0);

class AddFlashcardScreen extends ConsumerWidget {
  final FlashcardSet flashcardSet;

  const AddFlashcardScreen({super.key, required this.flashcardSet});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final flashcards = ref.watch(flashcardsProvider(flashcardSet)); // Watch the flashcards
    final currentFlashcardIndex = ref.watch(currentFlashcardIndexProvider);

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

    void navigateToPreviousFlashcard() {
      if (currentFlashcardIndex > 0) {
        ref
            .read(currentFlashcardIndexProvider.notifier)
            .state = currentFlashcardIndex - 1;
      }
    }

    void navigateToNextFlashcard() {
      if (currentFlashcardIndex < flashcards.length - 1) {
        ref
            .read(currentFlashcardIndexProvider.notifier)
            .state = currentFlashcardIndex + 1;
      }
    }

    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        title: Text('Flashcards for ${flashcardSet.title}'),
        backgroundColor: Colors.grey[200],
      ),
      body: flashcards.isEmpty
          ? const Center(child: Text('No flashcards created yet.'))
          : Center(
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
                        flashcards[currentFlashcardIndex].term,
                        style: const TextStyle(
                            fontSize: 24, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        flashcards[currentFlashcardIndex].definition,
                        style: const TextStyle(fontSize: 18),
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
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.blue),
                            onPressed: () {
                              // Edit functionality
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () {
                              ref
                                  .read(flashcardsProvider(flashcardSet).notifier)
                                  .deleteFlashcard(currentFlashcardIndex); // Delete flashcard
                            },
                          ),
                        ],
                      ),
                    ],
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
