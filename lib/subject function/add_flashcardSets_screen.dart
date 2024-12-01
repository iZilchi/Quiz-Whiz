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
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20), // Rounded corners for the dialog
        ),
        title: const Text(
          'Create Flashcard Set',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.blueAccent, // Modern color for the title
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Enter a title for your flashcard set:',
              style: TextStyle(
                fontSize: 14,
                color: Colors.black54, // Subtle secondary color
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: flashcardSetController,
              decoration: InputDecoration(
                labelText: 'Flashcard Set Title',
                labelStyle: const TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12), // Rounded input field
                ),
                filled: true,
                fillColor: Colors.grey[100], // Light background for input field
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog without action
            },
            child: const Text(
              'Cancel',
              style: TextStyle(
                color: Colors.redAccent,
                fontSize: 14,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              final setName = flashcardSetController.text.trim();
              if (setName.isNotEmpty) {
                ref
                    .read(flashcardSetsProvider(subject.documentId).notifier)
                    .addFlashcardSet(setName);
                Navigator.pop(context); // Close dialog after adding the set
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blueAccent, // Button background color
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10), // Rounded corners for button
              ),
            ),
            child: const Text(
              'Add',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
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
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20), // Rounded corners for the dialog
        ),
        title: const Text(
          'Edit Flashcard Set Title',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.blueAccent, // Modern color for the title
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Update the title for your flashcard set:',
              style: TextStyle(
                fontSize: 14,
                color: Colors.black54, // Subtle secondary color
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: flashcardSetController,
              decoration: InputDecoration(
                labelText: 'New Flashcard Set Title',
                labelStyle: const TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12), // Rounded input field
                ),
                filled: true,
                fillColor: Colors.grey[100], // Light background for input field
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog without saving
            },
            child: const Text(
              'Cancel',
              style: TextStyle(
                color: Colors.redAccent,
                fontSize: 14,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              final setName = flashcardSetController.text.trim();
              if (setName.isNotEmpty) {
                ref
                    .read(flashcardSetsProvider(subject.documentId).notifier)
                    .editFlashcardSet(index, setName);
                Navigator.pop(context); // Close dialog after saving
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blueAccent, // Button background color
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10), // Rounded corners for button
              ),
            ),
            child: const Text(
              'Save',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
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
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20), // Rounded corners for the dialog
        ),
        title: const Text(
          'Delete Flashcard Set',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.redAccent, // Highlight delete action with red
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Are you sure you want to delete this flashcard set?',
              style: TextStyle(
                fontSize: 16,
                color: Colors.black87, // Subtle secondary color
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'This will permanently delete all flashcards inside this set. This action cannot be undone.',
              style: TextStyle(
                fontSize: 14,
                color: Colors.black54, // Lighter color for secondary text
              ),
            ),
          ],
        ),
        actionsAlignment: MainAxisAlignment.spaceAround, // Center-align buttons
        actions: [
          ElevatedButton(
            onPressed: () {
              ref
                  .read(flashcardSetsProvider(subject.documentId).notifier)
                  .deleteFlashcardSet(index);
              Navigator.pop(context); // Close dialog after deleting
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent, // Red button for delete action
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10), // Rounded corners for button
              ),
            ),
            child: const Text(
              'Delete',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
          OutlinedButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog without deleting
            },
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Colors.grey), // Subtle border
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10), // Rounded corners for button
              ),
            ),
            child: const Text(
              'Cancel',
              style: TextStyle(
                color: Colors.black87,
                fontSize: 14,
              ),
            ),
          ),
        ],
      );
    },
  );
}

    return Scaffold(
  backgroundColor: Colors.grey[200],
  appBar: AppBar(
    title: Text(
      'Flashcard Sets for ${subject.title}',
      style: const TextStyle(
        color: Colors.black87,
        fontWeight: FontWeight.bold,
        fontSize: 20,
      ),
    ),
    backgroundColor: Colors.white,
    elevation: 0, // Flat design for the app bar
    iconTheme: const IconThemeData(color: Colors.black87), // Black back button
  ),
  body: flashcardSets.isEmpty
      ? const Center(
          child: Text(
            'No flashcard sets created yet.',
            style: TextStyle(
              fontSize: 18,
              color: Colors.black54,
              fontStyle: FontStyle.italic,
            ),
          ),
        )
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
                onEnter: (_) =>
                    ref.read(hoverIndexProvider.notifier).state = index,
                onExit: (_) =>
                    ref.read(hoverIndexProvider.notifier).state = null,
                child: Stack(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AddFlashcardScreen(
                            flashcardSet: flashcardSets[index],
                          ),
                        ),
                      ),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        curve: Curves.easeInOut,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: hoverIndex == index
                                  ? Colors.black26
                                  : Colors.black12,
                              blurRadius: hoverIndex == index ? 8 : 4,
                              offset: const Offset(2, 2),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            flashcardSets[index].title,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
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
                              icon: const Icon(Icons.edit,
                                  color: Colors.blueAccent),
                              tooltip: 'Edit',
                              onPressed: () {
                                editFlashcardSet(index);
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete,
                                  color: Colors.redAccent),
                              tooltip: 'Delete',
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
    backgroundColor: Colors.blueAccent,
    child: const Icon(
      Icons.add,
      size: 28,
      color: Colors.white,
    ),
    tooltip: 'Add Flashcard Set',
  ),
);

  }
}
