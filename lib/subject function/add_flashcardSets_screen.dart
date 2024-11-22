import 'package:flashcard_project/subject%20function/add_flashcards_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models.dart';
import '../providers/flashcardSet_provider.dart';

final hoverIndexProvider = StateProvider<int?>((ref) => null);

class AddFlashcardSetScreen extends ConsumerWidget {
  final Subject subject;

  const AddFlashcardSetScreen({super.key, required this.subject});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final flashcardSets = ref.watch(flashcardSetsProvider(subject.documentId)); // Pass subject ID
    final hoverIndex = ref.watch(hoverIndexProvider);

    void addFlashcardSet() {
      final flashcardSetController = TextEditingController();

      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Create Flashcard Set'),
            content: TextField(
              controller: flashcardSetController,
              decoration: const InputDecoration(labelText: 'Flashcard Set Title'),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  final setName = flashcardSetController.text.trim();
                  if (setName.isNotEmpty) {
                    ref
                        .read(flashcardSetsProvider(subject.documentId).notifier)
                        .addFlashcardSet(setName);
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

    void editFlashcardSet(int index) {
      final flashcardSetController = TextEditingController();

      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Edit Flashcard Set Title'),
            content: TextField(
              controller: flashcardSetController,
              decoration: const InputDecoration(labelText: 'Set Flashcard Set Title'),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  final setName = flashcardSetController.text.trim();
                  if (setName.isNotEmpty) {
                    ref
                        .read(flashcardSetsProvider(subject.documentId).notifier)
                        .editFlashcardSet(index, setName);
                    Navigator.pop(context);
                  }
                },
                child: const Text('Save'),
              ),
            ],
          );
        },
      );
    }

    void deleteFlashcardSet(int index) {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Delete Flashcard Set'),
            content: const Text(
                'Deleting this flashcard set will also delete the flashcards created inside it.'),
            actions: [
              TextButton(
                onPressed: () {
                  ref
                      .read(flashcardSetsProvider(subject.documentId).notifier)
                      .deleteFlashcardSet(index);
                  Navigator.pop(context);
                },
                child: const Text('Delete'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('Cancel'),
              ),
            ],
          );
        },
      );
    }

    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        title: Text('Flashcard Sets for ${subject.title}'),
        backgroundColor: Colors.grey[200],
      ),
      body: flashcardSets.isEmpty
          ? const Center(child: Text('No flashcard sets created yet.'))
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1.5,
                ),
                itemCount: flashcardSets.length,
                itemBuilder: (context, index) {
                  return MouseRegion(
                    onEnter: (_) => ref.read(hoverIndexProvider.notifier).state = index,
                    onExit: (_) => ref.read(hoverIndexProvider.notifier).state = null,
                    child: Stack(
                      children: [
                        GestureDetector(
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AddFlashcardScreen(
                                  flashcardSet: flashcardSets[index]),
                            ),
                          ),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: const [
                                BoxShadow(
                                  color: Colors.black12,
                                  blurRadius: 4,
                                  offset: Offset(2, 2),
                                ),
                              ],
                            ),
                            child: Center(
                              child: Text(
                                flashcardSets[index].title,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        ),
                        if (hoverIndex == index)
                          Positioned(
                            top: 8,
                            right: 8,
                            child: Row(
                              children: [
                                IconButton(
                                  icon:
                                      const Icon(Icons.edit, color: Colors.blue),
                                  onPressed: () {
                                    editFlashcardSet(index);
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete,
                                      color: Colors.red),
                                  onPressed: () {
                                    deleteFlashcardSet(index);
                                  },
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  );
                },
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: addFlashcardSet,
        backgroundColor: const Color.fromARGB(255, 255, 255, 255),
        child: const Icon(Icons.add),
      ),
    );
  }
}
