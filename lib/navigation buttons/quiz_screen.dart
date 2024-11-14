// screens/quiz_screen.dart
import 'package:flutter/material.dart';

class QuizScreen extends StatefulWidget {
  @override
  _QuizScreenState createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  // Example questions and answers
  final List<Map<String, dynamic>> _quizQuestions = [
    {
      'question': 'What is Flutter?',
      'options': ['A programming language', 'A framework', 'An IDE', 'A database'],
      'answer': 'A framework',
    },
    {
      'question': 'What is Dart used for?',
      'options': ['Web Development', 'Mobile App Development', 'Game Development', 'Machine Learning'],
      'answer': 'Mobile App Development',
    },
    {
      'question': 'Which company developed Flutter?',
      'options': ['Google', 'Microsoft', 'Facebook', 'Apple'],
      'answer': 'Google',
    },
  ];

  int _currentQuestionIndex = 0;
  bool _isAnswered = false;

  void _nextQuestion(String selectedAnswer) {
    if (_isAnswered) {
      return; // Prevents re-selection after answering
    }

    if (selectedAnswer == _quizQuestions[_currentQuestionIndex]['answer']) {
      setState(() {
        // You could track score here if needed
      });
    }

    setState(() {
      _isAnswered = true;
    });
  }

  void _goToNext() {
    if (_currentQuestionIndex < _quizQuestions.length - 1) {
      setState(() {
        _currentQuestionIndex++;
        _isAnswered = false; // Reset answer for the next question
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentQuestion = _quizQuestions[_currentQuestionIndex];
    final options = currentQuestion['options'];

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Question Display
            Text(
              currentQuestion['question'],
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),

            // Option Buttons
            ...List.generate(options.length, (index) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: ElevatedButton(
                  onPressed: () {
                    if (!_isAnswered) {
                      _nextQuestion(options[index]);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isAnswered && options[index] == currentQuestion['answer']
                        ? Colors.green
                        : (_isAnswered && options[index] != currentQuestion['answer']
                            ? Colors.red
                            : Colors.blue),
                    padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  ),
                  child: Text(
                    options[index],
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              );
            }),

            // Next Question Button
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                if (_isAnswered) {
                  _goToNext();
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
                padding: EdgeInsets.symmetric(horizontal: 80, vertical: 15),
              ),
              child: Text(
                _currentQuestionIndex == _quizQuestions.length - 1
                    ? 'Finish Quiz'
                    : 'Next Question',
                style: TextStyle(fontSize: 16),
              ),
            ),

            // Progress Bar
            SizedBox(height: 20),
            LinearProgressIndicator(
              value: (_currentQuestionIndex + 1) / _quizQuestions.length, // Correctly calculate progress
              backgroundColor: Colors.grey[300],
              color: Colors.blue,
            ),
          ],
        ),
      ),
    );
  }
}
