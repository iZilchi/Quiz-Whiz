import 'package:flutter/material.dart';
import '../quiz mode/identification.dart';
import '../quiz mode/multiplechoice.dart';

class QuizScreen extends StatefulWidget {
  final String uid;

  const QuizScreen({super.key, required this.uid});

  @override
  _QuizScreenState createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  final List<Map<String, dynamic>> options = [];

  @override
  void initState() {
    super.initState();
    options.addAll([
      {
        'title': 'Multiple Choice',
        'color': const Color.fromARGB(232, 233, 172, 86),
        'screen': MultipleChoiceScreen(uid: widget.uid), // Pass uid here
      },
      {
        'title': 'Identification Exam',
        'color': const Color.fromARGB(232, 233, 172, 86),
        'screen': IdentificationScreen(uid: widget.uid), // Pass uid here
      }
    ]);
  }

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
                margin: const EdgeInsets.symmetric(vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                color: option['color'],
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Center(
                    child: Text(
                      option['title'],
                      style: const TextStyle(
                        fontFamily: 'Satoshi',
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

