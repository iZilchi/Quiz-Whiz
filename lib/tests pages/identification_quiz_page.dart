import 'package:flutter/material.dart';
import '../tests pages/result_page.dart';

class IdentificationQuizPage extends StatefulWidget {
  final List<Map<String, dynamic>> questions;

  const IdentificationQuizPage({super.key, required this.questions});

  @override
  _IdentificationQuizPageState createState() => _IdentificationQuizPageState();
}

class _IdentificationQuizPageState extends State<IdentificationQuizPage> {
  Map<int, String?> selectedAnswers = {};
  int currentQuestionIndex = 0;
  final TextEditingController _answerController = TextEditingController();

  void _goToNextQuestion() {
    if (currentQuestionIndex < widget.questions.length - 1) {
      setState(() {
        currentQuestionIndex++;
      });
      _answerController.clear();
    }
  }

  void _goToPreviousQuestion() {
    if (currentQuestionIndex > 0) {
      setState(() {
        currentQuestionIndex--;
      });
      _answerController.clear();
    }
  }

  bool _isQuizComplete() {
    for (var i = 0; i < widget.questions.length; i++) {
      if (selectedAnswers[i] == null || selectedAnswers[i]!.isEmpty) {
        return false;
      }
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final question = widget.questions[currentQuestionIndex];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Identification Quiz'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(color: Colors.grey.withOpacity(0.2), blurRadius: 4, offset: Offset(0, 2)),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    question['question'],
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _answerController,
                    decoration: const InputDecoration(
                      labelText: 'Your Answer',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) {
                      setState(() {
                        selectedAnswers[currentQuestionIndex] = value;
                      });
                    },
                  ),
                ],
              ),
            ),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: currentQuestionIndex > 0 ? _goToPreviousQuestion : null,
                  child: const Text('Back'),
                ),
                ElevatedButton(
                  onPressed: currentQuestionIndex < widget.questions.length - 1 ? _goToNextQuestion : null,
                  child: const Text('Next'),
                ),
              ],
            ),
            const SizedBox(height: 20),
            if (currentQuestionIndex == widget.questions.length - 1)
              ElevatedButton(
                onPressed: _isQuizComplete()
                    ? () {
                        int score = 0;
                        for (int i = 0; i < widget.questions.length; i++) {
                          if (selectedAnswers[i]!.trim().toLowerCase() == widget.questions[i]['correctAnswer'].toLowerCase()) {
                            score++;
                          }
                        }
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ResultPage(
                              score: score,
                              totalQuestions: widget.questions.length,
                              selectedAnswers: selectedAnswers,
                              questions: widget.questions,
                              quizType: 'Identification',
                            ),
                          ),
                        );
                      }
                    : null,
                child: const Text('Submit'),
              ),
          ],
        ),
      ),
    );
  }
}
