
// ignore_for_file: file_names, sort_child_properties_last

import 'package:flashcard_project/subject%20function/add_flashcards_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../firebase/firestore_services.dart';
import '../models.dart';
import '../providers/flashcardSet_provider.dart';

final showEditDeleteProvider = StateProvider<bool>((ref) => false);

class AddFlashcardSetScreen extends ConsumerWidget {
  final Subject subject;

  const AddFlashcardSetScreen({super.key, required this.subject});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final flashcardSets = ref.watch(flashcardSetsProvider(subject.documentId)); // Pass subject ID
    final showEditDelete = ref.watch(showEditDeleteProvider);

    void recordActivity(String uid) {
      final today = DateTime.now();
      FirestoreService().addActivity(uid, today);
    }

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
                fontSize: 22, // Increased font size for title
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
                    fontSize: 16, // Slightly larger font for the prompt
                    color: Colors.black87, // Darker text for better readability
                  ),
                ),
                const SizedBox(height: 16), // Increased space between prompt and input field
                TextField(
                  controller: flashcardSetController,
                  decoration: InputDecoration(
                    labelText: 'Flashcard Set Title',
                    labelStyle: const TextStyle(
                      fontSize: 16, // Slightly larger font for label
                      color: Color.fromARGB(255, 90, 90, 90), // Blue color for label to match theme
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12), // Rounded input field
                    ),
                    filled: true,
                    fillColor: Colors.blue[50], // Light blue background for input field
                  ),
                  style: const TextStyle(
                    fontSize: 16, // Larger text for input field
                    color: Colors.black, // Black text for better readability
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
                    fontSize: 16, // Increased font size for consistency
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
                    recordActivity(subject.documentId);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent, // Button background color
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14), // More padding for buttons
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12), // Rounded corners for button
                  ),
                  elevation: 5, // Add shadow for depth effect
                ),
                child: const Text(
                  'Add',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16, // Larger font size for readability
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
                fontSize: 22, // Increased font size for title
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
                    fontSize: 16, // Slightly larger font for prompt
                    color: Colors.black87, // Darker text for better readability
                  ),
                ),
                const SizedBox(height: 16), // Increased space between prompt and input field
                TextField(
                  controller: flashcardSetController,
                  decoration: InputDecoration(
                    labelText: 'New Flashcard Set Title',
                    labelStyle: const TextStyle(
                      fontSize: 16, // Larger label text for visibility
                      color: Color.fromARGB(255, 135, 136, 136), // Blue color for label to match theme
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12), // Rounded input field
                    ),
                    filled: true,
                    fillColor: Colors.blue[50], // Light blue background for input field
                  ),
                  style: const TextStyle(
                    fontSize: 16, // Larger font for input text
                    color: Colors.black, // Black text for better readability
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
                    fontSize: 16, // Increased font size for consistency
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
                    recordActivity(subject.documentId);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent, // Button background color
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14), // More padding for buttons
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12), // Rounded corners for button
                  ),
                  elevation: 5, // Add shadow for depth effect
                ),
                child: const Text(
                  'Save',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16, // Larger font size for readability
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
                fontSize: 22, // Increased font size for emphasis
                fontWeight: FontWeight.bold,
                color: Colors.redAccent, // Highlight delete action with red
              ),
            ),
            content: const Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Are you sure you want to delete this flashcard set?',
                  style: TextStyle(
                    fontSize: 16, // Larger text for better readability
                    color: Colors.black87, // Dark text for primary message
                  ),
                ),
                SizedBox(height: 16), // More space between texts
                Text(
                  'This will permanently delete all flashcards inside this set. This action cannot be undone.',
                  style: TextStyle(
                    fontSize: 14, // Subtle warning font size
                    color: Colors.black54, // Light gray color for secondary info
                  ),
                ),
              ],
            ),
            actionsAlignment: MainAxisAlignment.spaceEvenly, // Evenly spaced buttons
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
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14), // Increased padding for comfort
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12), // Rounded corners for button
                  ),
                  elevation: 5, // Added shadow for depth
                ),
                child: const Text(
                  'Delete',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16, // Larger text for the delete button
                  ),
                ),
              ),
              OutlinedButton(
                onPressed: () {
                  Navigator.pop(context); // Close dialog without deleting
                },
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.grey), // Subtle border
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14), // Increased padding
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12), // Rounded corners for button
                  ),
                ),
                child: const Text(
                  'Cancel',
                  style: TextStyle(
                    color: Colors.black87,
                    fontSize: 16, // Larger text for the cancel button
                  ),
                ),
              ),
            ],
          );
        },
      );
    }

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 135,206,235),
      appBar: AppBar(
        title: Text(
          '${subject.title}',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color.fromARGB(255, 73, 141, 214),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: Icon(
              showEditDelete ? Icons.settings_applications_outlined : Icons.settings_applications,
              color: const Color.fromARGB(255, 255, 255, 255),
            ),
            onPressed: () {
              ref.read(showEditDeleteProvider.notifier).state =
                  !showEditDelete; // Toggle visibility state
            },
          ),
        ],
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
                  childAspectRatio: 1.5, // Adjust the aspect ratio for better visuals
                ),
                itemCount: flashcardSets.length,
                itemBuilder: (context, index) {
                  return Stack(
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
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                          decoration: BoxDecoration(
                            color: const Color.fromARGB(255, 248, 250, 229),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: const [
                              BoxShadow(
                                color: Colors.black12,
                                blurRadius: 6,
                                offset: Offset(4, 4),
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
                                color: Colors.black54,
                              ),
                            ),
                          ),
                        ),
                      ),
                      if (showEditDelete)
                        Positioned(
                          top: 8,
                          left: 8,
                          child: IconButton(
                            onPressed: () => editFlashcardSet(index),
                            iconSize: 30,
                            icon: const Icon(Icons.edit, color: Colors.blueGrey),
                          ),
                        ),
                      if (showEditDelete)
                        Positioned(
                          top: 8,
                          right: 8,
                          child: IconButton(
                            onPressed: () => deleteFlashcardSet(index),
                            iconSize: 30,
                            icon: const Icon(Icons.delete, color: Colors.redAccent),
                          ),
                        ),
                    ],
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
