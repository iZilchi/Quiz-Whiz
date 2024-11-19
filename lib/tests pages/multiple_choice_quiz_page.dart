import 'package:flutter/material.dart';
import '../tests pages/result_page.dart';

class QuizPage extends StatefulWidget {
  final List<Map<String, dynamic>> questions;

  const QuizPage({super.key, required this.questions});

  @override
  _QuizPageState createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  Map<int, String?> selectedAnswers = {};
  int currentQuestionIndex = 0;

  void _goToNextQuestion() {
    if (currentQuestionIndex < widget.questions.length - 1) {
      setState(() {
        currentQuestionIndex++;
      });
    }
  }

  void _goToPreviousQuestion() {
    if (currentQuestionIndex > 0) {
      setState(() {
        currentQuestionIndex--;
      });
    }
  }

  bool _isQuizComplete() {
    for (var i = 0; i < widget.questions.length; i++) {
      if (selectedAnswers[i] == null) {
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
        title: const Text('Quiz'),
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
                  ...question['choices'].map<Widget>((choice) {
                    return RadioListTile<String>(
                      title: Text(choice),
                      value: choice,
                      groupValue: selectedAnswers[currentQuestionIndex],
                      onChanged: (value) {
                        setState(() {
                          selectedAnswers[currentQuestionIndex] = value;
                        });
                      },
                    );
                  }).toList(),
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
                          if (selectedAnswers[i] == widget.questions[i]['correctAnswer']) {
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
                              quizType: 'MultipleChoice',
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
