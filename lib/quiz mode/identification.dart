import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models.dart';
import '../providers/subject_provider.dart';
import '../providers/flashcardSet_provider.dart';
import '../providers/flashcards_provider.dart';
import '../tests pages/identification_quiz_page.dart';

class IdentificationScreen extends ConsumerStatefulWidget {
  const IdentificationScreen({super.key});

  @override
  _IdentificationScreenState createState() => _IdentificationScreenState();
}

class _IdentificationScreenState extends ConsumerState<IdentificationScreen> {
  Subject? selectedSubject;
  FlashcardSet? selectedFlashcardSet;

  void _startQuiz(List<Flashcard> flashcards) {
    if (flashcards.length < 4) {
      // Show an alert if there are fewer than 4 flashcards
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Not Enough Flashcards'),
          content: const Text('You need at least 4 flashcards to start the quiz.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
      return;
    }

    List<Map<String, dynamic>> questions = [];

    for (var flashcard in flashcards) {
      // Create a question with the term and its definition
      questions.add({
        'question': flashcard.term,
        'correctAnswer': flashcard.definition,
      });
    }

    // Shuffle the questions to randomize the order
    questions.shuffle();

    // Navigate to the quiz page and pass the questions
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => IdentificationQuizPage(questions: questions), // Navigate to IdentificationQuizPage
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final subjects = ref.watch(subjectsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Flashcards for Identification Quiz'),
        backgroundColor: Colors.green,
      ),
      body: Column(
        children: [
          // Dropdown for Subjects
          DropdownButton<Subject>(
            hint: const Text('Select Subject'),
            value: selectedSubject,
            onChanged: (newValue) {
              setState(() {
                selectedSubject = newValue;
                selectedFlashcardSet = null; // Reset flashcard set
              });
            },
            items: subjects.map((subject) {
              return DropdownMenuItem(
                value: subject,
                child: Text(subject.title),
              );
            }).toList(),
          ),
          if (selectedSubject != null)
            DropdownButton<FlashcardSet>(
              hint: const Text('Select Flashcard Set'),
              value: selectedFlashcardSet,
              onChanged: (newValue) {
                setState(() {
                  selectedFlashcardSet = newValue;
                });
              },
              items: ref.watch(flashcardSetsProvider(selectedSubject!)).map((set) {
                return DropdownMenuItem(
                  value: set,
                  child: Text(set.title),
                );
              }).toList(),
            ),
          const Spacer(),
          ElevatedButton(
            onPressed: () {
              // Show dialog if subject is not selected
              if (selectedSubject == null) {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Subject Not Selected'),
                    content: const Text('Please select a subject before starting the quiz.'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('OK'),
                      ),
                    ],
                  ),
                );
                return;
              }

              // Show dialog if flashcard set is not selected
              if (selectedFlashcardSet == null) {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Flashcard Set Not Selected'),
                    content: const Text('Please select a flashcard set before starting the quiz.'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('OK'),
                      ),
                    ],
                  ),
                );
                return;
              }

              // Get flashcards
              final flashcards = ref.watch(flashcardsProvider(selectedFlashcardSet!)) as List<Flashcard>;

              // Start quiz
              _startQuiz(flashcards);
            },
            child: const Text('Start Quiz'),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
