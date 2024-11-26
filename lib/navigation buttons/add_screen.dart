// screens/add_screen.dart
import 'package:flutter/material.dart';

class AddScreen extends StatefulWidget {
  const AddScreen({super.key});

  @override
  _AddScreenState createState() => _AddScreenState();
}

class _AddScreenState extends State<AddScreen> {
  final _formKey = GlobalKey<FormState>();
  final _questionController = TextEditingController();
  final _subjectController = TextEditingController();
  final _optionController = TextEditingController();
  final _correctAnswerController = TextEditingController();

  List<Map<String, dynamic>> flashcards = [];
  List<String> options = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Flashcards'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Form to add new flashcards
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    // Subject Input
                    TextFormField(
                      controller: _subjectController,
                      decoration: const InputDecoration(
                        labelText: 'Enter Subject',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a subject';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Question Input
                    TextFormField(
                      controller: _questionController,
                      decoration: const InputDecoration(
                        labelText: 'Enter Question',
                        border: OutlineInputBorder(),
                        hintText: 'e.g., What is Flutter?',
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a question';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Answer Options Input
                    TextFormField(
                      controller: _optionController,
                      decoration: const InputDecoration(
                        labelText: 'Enter Option (e.g., A)',
                        border: OutlineInputBorder(),
                      ),
                      onFieldSubmitted: (_) {
                        setState(() {
                          if (_optionController.text.isNotEmpty) {
                            options.add(_optionController.text);
                            _optionController.clear();
                          }
                        });
                      },
                    ),
                    const SizedBox(height: 16),

                    // Correct Answer Input
                    TextFormField(
                      controller: _correctAnswerController,
                      decoration: const InputDecoration(
                        labelText: 'Enter Correct Answer',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter the correct answer';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),

                    // Add Flashcard Button
                    ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState?.validate() ?? false) {
                          setState(() {
                            flashcards.add({
                              'subject': _subjectController.text,
                              'question': _questionController.text,
                              'options': List.from(options),
                              'correctAnswer': _correctAnswerController.text,
                            });
                            // Clear fields after adding
                            _subjectController.clear();
                            _questionController.clear();
                            _correctAnswerController.clear();
                            options.clear();
                          });
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                      ),
                      child: const Text('Add Flashcard'),
                    ),
                    const SizedBox(height: 20),

                    // Show Added Flashcards
                    if (flashcards.isNotEmpty) ...[
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: flashcards.length,
                        itemBuilder: (context, index) {
                          return Card(
                            margin: const EdgeInsets.symmetric(vertical: 5),
                            elevation: 3,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Subject: ${flashcards[index]['subject']}',
                                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Q: ${flashcards[index]['question']}',
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                  const SizedBox(height: 8),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: List.generate(
                                      flashcards[index]['options'].length,
                                      (optionIndex) => Text(
                                        'Option ${String.fromCharCode(65 + optionIndex)}: ${flashcards[index]['options'][optionIndex]}',
                                        style: const TextStyle(fontSize: 16),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Correct Answer: ${flashcards[index]['correctAnswer']}',
                                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Button to view the created set of flashcards
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    // Navigate to a page to review the flashcards (to be implemented)
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                  ),
                  child: const Text('View Flashcards'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
