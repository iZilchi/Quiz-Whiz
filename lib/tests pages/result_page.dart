import 'package:flutter/material.dart';
import '/quiz mode/multiplechoice.dart';
import 'multiple_choice_quiz_page.dart';
import '../pages/home_page.dart';
import '../tests pages/review_answers_page.dart';

class ResultPage extends StatelessWidget {
  final int score;
  final int totalQuestions;
  final Map<int, String?> selectedAnswers;
  final List<Map<String, dynamic>> questions;

  const ResultPage({
    super.key,
    required this.score,
    required this.totalQuestions,
    required this.selectedAnswers,
    required this.questions,
  });

  @override
  Widget build(BuildContext context) {
    double percentage = (score / totalQuestions) * 100;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Quiz Result'),
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'You scored $score out of $totalQuestions',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              'Your score: ${percentage.toStringAsFixed(2)}%',
              style: const TextStyle(fontSize: 20),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const HomePage(),
                  ),
                );
              },
              child: const Text('Back to Home'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ReviewAnswersPage(
                      selectedAnswers: selectedAnswers,
                      questions: questions,
                    ),
                  ),
                );
              },
              child: const Text('Review Answers'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => QuizPage(questions: questions),
                  ),
                );
              },
              child: const Text('Retake Test'),
            ),
          ],
        ),
      ),
    );
  }
}
