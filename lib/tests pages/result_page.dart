import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'multiple_choice_quiz_page.dart';
import '../pages/home_page.dart';
import '../tests pages/review_answers_page.dart';
import 'identification_quiz_page.dart';
import '../models.dart';

class ResultPage extends StatelessWidget {
  final int score;
  final int totalQuestions;
  final Map<int, String?> selectedAnswers;
  final List<Map<String, dynamic>> questions;
  final String quizType;
  final int? previousTimerDuration;
  final FlashcardSet flashcardSet;

  const ResultPage({
    super.key,
    required this.score,
    required this.totalQuestions,
    required this.selectedAnswers,
    required this.questions,
    required this.quizType,
    this.previousTimerDuration,
    required this.flashcardSet,
  });

  @override
  Widget build(BuildContext context) {
    double percentage = (score / totalQuestions) * 100;

    return Scaffold(
      appBar: AppBar(
        title: Text('Quiz Result', 
        style: GoogleFonts.poppins(
          fontSize: 18),),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'You scored $score out of $totalQuestions',
                style: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Text(
                'Your score: ${percentage.toStringAsFixed(2)}%',
                style: GoogleFonts.poppins(fontSize: 20),
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
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue, // Set background color to blue
                  foregroundColor: Colors.white, // Ensure text color is white for contrast
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20), // Optional: Adjust padding
                ),
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
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green, // Set background color to blue
                  foregroundColor: Colors.white, // Ensure text color is white for contrast
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20), // Optional: Adjust padding
                ),
                child: const Text('Review Answers'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (quizType == 'MultipleChoice') {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => QuizPage(
                          questions: questions,
                          timerDuration: previousTimerDuration,
                          flashcardSet: flashcardSet,
                        ),
                      ),
                    );
                  } else if (quizType == 'Identification') {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => IdentificationQuizPage(
                          questions: questions,
                          timerDuration: previousTimerDuration,
                          flashcardSet: flashcardSet,
                        ),
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red, // Set background color to blue
                  foregroundColor: Colors.white, // Ensure text color is white for contrast
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20), // Optional: Adjust padding
                ),
                child: const Text('Retake Test'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
