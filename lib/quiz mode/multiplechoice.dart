import 'dart:math';
import 'package:flutter/material.dart';

class MultipleChoiceScreen extends StatefulWidget {
  final List<Flashcard> flashcards;

  const MultipleChoiceScreen({Key? key, required this.flashcards})
      : super(key: key);

  @override
  _MultipleChoiceScreenState createState() => _MultipleChoiceScreenState();
}

class _MultipleChoiceScreenState extends State<MultipleChoiceScreen> {
  late List<Map<String, dynamic>> questions;
  int _currentQuestionIndex = 0;

  @override
  void initState() {
    super.initState();
    _generateQuestions();
  }

  void _generateQuestions() {
    if (widget.flashcards.length < 4) {
      // Ensure there are at least 4 flashcards
      questions = [];
      return;
    }

    List<Flashcard> flashcards = List.from(widget.flashcards);
    flashcards.shuffle(Random());

    questions = flashcards.map((flashcard) {
      // Get options from other flashcards
      List<String> options = flashcards
          .where((f) => f != flashcard)
          .take(3)
          .map((f) => f.term)
          .toList();

      options.add(flashcard.term);
      options.shuffle(Random());

      return {
        'question': flashcard.definition,
        'options': options,
        'correctAnswer': flashcard.term,
        'selectedAnswer': null,
      };
    }).toList();
  }

  void _updateAnswer(int questionIndex, String answer) {
    setState(() {
      questions[questionIndex]['selectedAnswer'] = answer;
    });
  }

  void _nextQuestion() {
    if (_currentQuestionIndex < questions.length - 1) {
      setState(() {
        _currentQuestionIndex++;
      });
    }
  }

  void _previousQuestion() {
    if (_currentQuestionIndex > 0) {
      setState(() {
        _currentQuestionIndex--;
      });
    }
  }

  void _submitAnswers() {
    int correctAnswers = questions.where((question) =>
        question['selectedAnswer'] == question['correctAnswer']).length;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Test Results'),
          content: Text(
            'You got $correctAnswers out of ${questions.length} correct.',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (questions.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text('Quiz Mode')),
        body: Center(child: Text('Not enough flashcards to start the quiz.')),
      );
    }

    final question = questions[_currentQuestionIndex];
    double progress = (_currentQuestionIndex + 1) / questions.length;

    return Scaffold(
      appBar: AppBar(title: Text('Quiz Mode')),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    question['question'],
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(height: 20),
                  Card(
                    margin: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    elevation: 5,
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ...question['options'].map<Widget>((option) {
                            return ListTile(
                              title: Text(option),
                              leading: Radio<String>(
                                value: option,
                                groupValue: question['selectedAnswer'],
                                onChanged: (String? value) {
                                  if (value != null) {
                                    _updateAnswer(_currentQuestionIndex, value);
                                  }
                                },
                              ),
                            );
                          }).toList(),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: _currentQuestionIndex > 0 ? _previousQuestion : null,
                  child: Text('Previous'),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                ),
                SizedBox(width: 20),
                if (_currentQuestionIndex < questions.length - 1)
                  ElevatedButton(
                    onPressed: _nextQuestion,
                    child: Text('Next'),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                  ),
                if (_currentQuestionIndex == questions.length - 1)
                  ElevatedButton(
                    onPressed: _submitAnswers,
                    child: Text('Submit'),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                LinearProgressIndicator(
                  value: progress,
                  backgroundColor: Colors.grey[300],
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                ),
                SizedBox(height: 10),
                Text(
                  'Question ${_currentQuestionIndex + 1} of ${questions.length}',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class Flashcard {
  String term;
  String definition;

  Flashcard(this.term, this.definition);
}
