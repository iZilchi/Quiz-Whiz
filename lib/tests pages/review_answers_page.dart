import 'package:flutter/material.dart';

class ReviewAnswersPage extends StatelessWidget {
  final Map<int, String?> selectedAnswers;
  final List<Map<String, dynamic>> questions;

  const ReviewAnswersPage({
    super.key,
    required this.selectedAnswers,
    required this.questions,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Review Answers'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView.builder(
          itemCount: questions.length,
          itemBuilder: (context, index) {
            final question = questions[index];
            final correctAnswer = question['correctAnswer'];
            final userAnswer = selectedAnswers[index];
            final isCorrect = userAnswer == correctAnswer;

            return Card(
              margin: const EdgeInsets.symmetric(vertical: 10),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Question ${index + 1}: ${question['question']}',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Your answer: $userAnswer',
                      style: TextStyle(
                        fontSize: 16,
                        color: isCorrect ? Colors.green : Colors.red,
                      ),
                    ),
                    Text(
                      'Correct answer: $correctAnswer',
                      style: const TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
