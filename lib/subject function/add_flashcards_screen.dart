import 'dart:math';

import 'package:flashcard_project/subject%20function/add_flashcardSets_screen.dart';
import 'package:flutter/material.dart';

class AddFlashcardScreen extends StatefulWidget {
  final FlashcardSet flashcardSet;

  const AddFlashcardScreen({super.key, required this.flashcardSet});

  @override
  _AddFlashcardScreenState createState() => _AddFlashcardScreenState();
}

class _AddFlashcardScreenState extends State<AddFlashcardScreen> {
  int currentIndex = 0;
  bool isTermVisible = true;

  // Function to add new flashcard
  void _addFlashcard() {
    TextEditingController termController = TextEditingController();
    TextEditingController definitionController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {

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
                    widget.flashcardSet.flashcards.add(Flashcard(termController.text, definitionController.text));
                    currentIndex = widget.flashcardSet.flashcards.length - 1; // Show the newly added card
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

  // Function to shuffle flashcards
  void _shuffleFlashcards() {
    setState(() {
      widget.flashcardSet.flashcards.shuffle(Random()); // Shuffle using Random()
      currentIndex = 0; // Reset to the first card after shuffling
    });
  }

  // Function to edit an existing flashcard
  void _editFlashcard(int index) {
    TextEditingController termController = TextEditingController(text: widget.flashcardSet.flashcards[index].term);
    TextEditingController definitionController = TextEditingController(text: widget.flashcardSet.flashcards[index].definition);

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
                  widget.flashcardSet.flashcards[index].term = termController.text;
                  widget.flashcardSet.flashcards[index].definition = definitionController.text;
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
                  widget.flashcardSet.flashcards.removeAt(index);
                  if (currentIndex >= widget.flashcardSet.flashcards.length) {
                    currentIndex = widget.flashcardSet.flashcards.length - 1; // Reset to last card if deleted
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
    if (currentIndex < widget.flashcardSet.flashcards.length - 1) {
      setState(() {
        currentIndex++;
      });
    } else {
      setState(() {
        currentIndex = 0;
      });
    }
  }

  void _previousCard() {
    if (currentIndex > 0) {
      setState(() {
        currentIndex--;
      });
    } else {
      setState(() {
        currentIndex = widget.flashcardSet.flashcards.length - 1;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if(widget.flashcardSet.flashcards.isEmpty){
      return Scaffold(
        appBar: AppBar(
          title: Text(widget.flashcardSet.title),
        ),
        body: Center(
          child: Text('No flashcards added yet.'),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: _addFlashcard,
          child: Icon(Icons.add),
        ),
      );
    }

    final flashcard = widget.flashcardSet.flashcards[currentIndex];

    return Scaffold(
      appBar: AppBar(title: Text('${widget.flashcardSet.title} Flashcards')),
      body: Center(
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    isTermVisible = !isTermVisible;
                  });
                },
                child: Card(
                  elevation: 5,
                  margin: EdgeInsets.all(20),
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          isTermVisible ? flashcard.term : flashcard.definition,
                          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            IconButton(
                              icon: Icon(Icons.edit),
                              onPressed: () => _editFlashcard(currentIndex),
                            ),
                            IconButton(
                              icon: Icon(Icons.delete),
                              onPressed: () => _deleteFlashcard(currentIndex),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            onPressed: _addFlashcard,
            child: Icon(Icons.add),
            heroTag: null,
          ),
          SizedBox(height: 10),
          FloatingActionButton(
            onPressed: _shuffleFlashcards, // Shuffle on press
            child: Icon(Icons.shuffle),
            heroTag: null,
          ),
          SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: Icon(Icons.arrow_back),
                onPressed: _previousCard,
              ),
              IconButton(
                icon: Icon(Icons.arrow_forward),
                onPressed: _nextCard,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
