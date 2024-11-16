// screens/quiz_screen.dart
import 'package:flutter/material.dart';

import '../quiz mode/fillintheblanks.dart';
import '../quiz mode/identification.dart';
import '../quiz mode/multiplechoice.dart';

class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key});

  @override
  _QuizScreenState createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  // Example questions and answers
  final List<Map<String, dynamic>> options = [
    {
      'title': 'Multiple Choice',
      'color': const Color.fromARGB(232, 233, 172, 86),
      'screen': MultipleChoiceScreen(),
    },
    {
      'title': 'Identification Exam',
      'color': const Color.fromARGB(232, 233, 172, 86),
      'screen': IdentificationExamScreen(),
    },
    {
      'title': 'Fill in the Blanks',
      'color': const Color.fromARGB(232, 233, 172, 86),
      'screen': FillInTheBlanksScreen(),
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: ListView.builder(
          itemCount: options.length,
          itemBuilder: (context, index) {
            final option = options[index];
            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => option['screen']),
                );
              },
              child: Card(
                margin: EdgeInsets.symmetric(vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                color: option['color'],
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Center(
                    child: Text(
                      option['title'],
                      style: TextStyle(
                        fontFamily: 'Satoshi', // Use Satoshi font
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}