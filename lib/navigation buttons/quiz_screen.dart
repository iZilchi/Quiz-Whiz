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
        'icon': Icons.check_box_outline_blank,
        'screen': MultipleChoiceScreen(uid: widget.uid),
      },
      {
        'title': 'Identification Exam',
        'color': const Color.fromARGB(232, 233, 172, 86),
        'icon': Icons.image_search,
        'screen': IdentificationScreen(uid: widget.uid),
      }
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quiz Options'),
        automaticallyImplyLeading: false, // Disable the back button
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
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
                elevation: 5,
                color: option['color'],
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Icon(
                        option['icon'],
                        size: 32,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          option['title'],
                          style: const TextStyle(
                            fontFamily: 'Satoshi',
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          textAlign: TextAlign.center,
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
    );
  }
}
