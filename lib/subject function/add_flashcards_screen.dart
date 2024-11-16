import 'package:flutter/material.dart';

class Flashcard {
  String term;
  String definition;

  Flashcard(this.term, this.definition);
}

class AddFlashcardScreen extends StatefulWidget {
  final String setName;

  const AddFlashcardScreen({super.key, required this.setName});

  @override
  _AddFlashcardScreenState createState() => _AddFlashcardScreenState();
}

class _AddFlashcardScreenState extends State<AddFlashcardScreen> {
  List<Flashcard> flashcards = [];
  int currentIndex = 0;

  // Function to add new flashcard
  void _addFlashcard() {
    showDialog(
      context: context,
      builder: (context) {
        TextEditingController termController = TextEditingController();
        TextEditingController definitionController = TextEditingController();

        return AlertDialog(
          title: const Text('Add New Flashcard'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
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
                if (termController.text.isNotEmpty && definitionController.text.isNotEmpty) {
                  setState(() {
                    flashcards.add(Flashcard(termController.text, definitionController.text));
                    currentIndex = flashcards.length - 1; // Show the newly added card
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
  void _editFlashcard(int index) {
    TextEditingController termController = TextEditingController(text: flashcards[index].term);
    TextEditingController definitionController = TextEditingController(text: flashcards[index].definition);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Flashcard'),
          content: Column(
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
                setState(() {
                  flashcards[index].term = termController.text;
                  flashcards[index].definition = definitionController.text;
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
  void _deleteFlashcard(int index) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Flashcard'),
          content: const Text('Are you sure you want to delete this flashcard?'),
          actions: [
            TextButton(
              onPressed: () {
                setState(() {
                  flashcards.removeAt(index);
                  if (currentIndex >= flashcards.length) {
                    currentIndex = flashcards.length - 1; // Reset to last card if deleted
                  }
                });
                Navigator.pop(context);
              },
              child: const Text('Delete'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog
              },
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  // Function to move to the next card
  void _nextCard() {
    setState(() {
      currentIndex = (currentIndex + 1) % flashcards.length;
    });
  }

  // Function to move to the previous card
  void _previousCard() {
    setState(() {
      currentIndex = (currentIndex - 1 + flashcards.length) % flashcards.length;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('${widget.setName} Flashcards')),
      body: flashcards.isEmpty
          ? const Center(child: Text('No flashcards added yet.'))
          : Center(
              child: Card(
                elevation: 5,
                margin: const EdgeInsets.all(20),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        flashcards[currentIndex].term,
                        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        flashcards[currentIndex].definition,
                        style: const TextStyle(fontSize: 18),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () => _editFlashcard(currentIndex),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () => _deleteFlashcard(currentIndex),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            onPressed: _addFlashcard,
            child: const Icon(Icons.add),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: _previousCard,
              ),
              IconButton(
                icon: const Icon(Icons.arrow_forward),
                onPressed: _nextCard,
              ),
            ],
          ),
          // Number indicator placed below the Card container
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Text(
              '${currentIndex + 1} / ${flashcards.length}',
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ),
        ],
      ),
    );
  }
}
