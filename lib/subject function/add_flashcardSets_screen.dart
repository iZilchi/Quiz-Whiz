import 'package:flashcard_project/navigation%20buttons/subject_screen.dart';
import 'package:flashcard_project/subject%20function/add_flashcards_screen.dart';
import 'package:flutter/material.dart';

class Flashcard {
  String term;
  String definition;

  Flashcard(this.term, this.definition);
}

class FlashcardSet {
  String title;
  List<Flashcard> flashcards;

  FlashcardSet(this.title) : flashcards = [];
}

class AddFlashcardSetScreen extends StatefulWidget {
  final Subject subject;

  const AddFlashcardSetScreen({super.key, required this.subject});

  @override
  _AddFlashcardSetScreenState createState() => _AddFlashcardSetScreenState();
}

class _AddFlashcardSetScreenState extends State<AddFlashcardSetScreen> {
  int? _hoveredIndex;

  // Function to add new flashcard
  void _addFlashcardSet() {
    TextEditingController flashcardSetController = TextEditingController();

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
                  setState(() {
                    widget.subject.flashcardSets.add(FlashcardSet(flashcardSetController.text));
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

  // Function to edit an existing flashcard
  void _editFlashcardSet(int index) {
    TextEditingController flashcardSetController = TextEditingController(text: widget.subject.flashcardSets[index].title);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Flashcard Set'),
          content: TextField(
            controller: flashcardSetController,
            decoration: const InputDecoration(labelText: 'Set New Flashcard Set Title'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                setState(() {
                  widget.subject.flashcardSets[index].title = flashcardSetController.text.trim();
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

  // Function to delete a flashcard
  void _deleteFlashcardSet(int index) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Flashcard Set'),
          content: const Text('Deleting this flashcard set will also delete the flashcards created inside it.'),
          actions: [
            TextButton(
              onPressed: () {
                setState(() {
                  widget.subject.flashcardSets.removeAt(index);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200], // Set the background color of the entire Scaffold
      appBar: AppBar(
        title: Text('Flashcard Sets for ${widget.subject.title}'),
        backgroundColor: Colors.grey[200], // Ensure AppBar is also grey to match the background
      ),
      body: widget.subject.flashcardSets.isEmpty 
        ? Center(
          child: Text('No flashcard sets created yet.'),
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
          itemCount: widget.subject.flashcardSets.length,
          itemBuilder: (context, index) {
            return MouseRegion(

              onEnter: (_) {
                setState(() {
                  _hoveredIndex = index;
                });
              },
              onExit: (_) {
                setState(() {
                  _hoveredIndex = null;
                });
              },

              child: GestureDetector(
                onTap: () => {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AddFlashcardScreen(flashcardSet: widget.subject.flashcardSets[index])
                    ),
                  )
                }, // Open set on tap
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
                          widget.subject.flashcardSets[index].title,
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ),
                      if (_hoveredIndex == index)
                        Positioned(
                          top: 8,
                          right: 8,
                          child: Row(
                            children: [
                              IconButton(
                                    icon: Icon(Icons.edit),
                                    onPressed: () => _editFlashcardSet(index),
                                  ),
                              IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                onPressed: () => _deleteFlashcardSet(index), // Delete on press
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
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
