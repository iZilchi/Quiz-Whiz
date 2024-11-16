import 'package:flutter/material.dart';
import '../subject function/add_flashcards_screen.dart';

class SubjectScreen extends StatefulWidget {
  const SubjectScreen({super.key});

  @override
  _SubjectScreenState createState() => _SubjectScreenState();
}

class _SubjectScreenState extends State<SubjectScreen> {
  List<String> flashcardSets = []; // Start with an empty list

  void _addFlashcardSet() {
    showDialog(
      context: context,
      builder: (context) {
        TextEditingController setNameController = TextEditingController();

        return AlertDialog(
          title: const Text('Add Flashcard Set'),
          content: TextField(
            controller: setNameController,
            decoration: const InputDecoration(labelText: 'Set Name'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                final setName = setNameController.text.trim();
                if (setName.isNotEmpty) {
                  setState(() {
                    flashcardSets.add(setName);
                  });
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

  void _editFlashcardSet(int index) {
    TextEditingController setNameController = TextEditingController(text: flashcardSets[index]);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Flashcard Set'),
          content: TextField(
            controller: setNameController,
            decoration: const InputDecoration(labelText: 'Set Name'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                setState(() {
                  flashcardSets[index] = setNameController.text.trim();
                });
                Navigator.pop(context);
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  // Function to delete a specific flashcard set
  void _deleteFlashcardSet(int index) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Flashcard Set'),
          content: const Text('Are you sure you want to delete this flashcard set?'),
          actions: [
            TextButton(
              onPressed: () {
                setState(() {
                  flashcardSets.removeAt(index);
                });
                Navigator.pop(context);
              },
              child: const Text('Delete'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog without deleting
              },
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  void _openFlashcardSet(String setName) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddFlashcardScreen(setName: setName),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200], // Set the background color of the entire Scaffold
      appBar: AppBar(
        title: const Text('Subjects'),
        backgroundColor: Colors.grey[200], // Ensure AppBar is also grey to match the background
      ),
      body: Padding(
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
            return GestureDetector(
              onTap: () => _openFlashcardSet(flashcardSets[index]), // Open set on tap
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey[100], // Set the container's background color to a slightly darker grey
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 4,
                      offset: Offset(2, 2),
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    Center(
                      child: Text(
                        flashcardSets[index],
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _deleteFlashcardSet(index), // Delete on press
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addFlashcardSet,
        backgroundColor: const Color.fromARGB(255, 255, 255, 255),
        child: const Icon(Icons.add),
      ),
    );
  }
}
