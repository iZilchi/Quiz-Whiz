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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('${widget.setName} Flashcards')),
      body: flashcards.isEmpty
          ? const Center(child: Text('No flashcards added yet.'))
          : ListView.builder(
              itemCount: flashcards.length,
              itemBuilder: (context, index) {
                final flashcard = flashcards[index];
                return ListTile(
                  title: Text(flashcard.term),
                  subtitle: Text(flashcard.definition),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addFlashcard,
        child: const Icon(Icons.add),
      ),
    );
  }
}
