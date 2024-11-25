import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:math';
import '../models.dart';
import '../providers/subject_provider.dart';
import '../providers/flashcardSet_provider.dart';
import '../providers/flashcards_provider.dart';
import '../tests pages/multiple_choice_quiz_page.dart';

class MultipleChoiceScreen extends ConsumerStatefulWidget {
  final String uid;
  const MultipleChoiceScreen({super.key, required this.uid});

  @override
  _MultipleChoiceScreenState createState() => _MultipleChoiceScreenState();
}

class _MultipleChoiceScreenState extends ConsumerState<MultipleChoiceScreen> {
  Subject? selectedSubject;
  FlashcardSet? selectedFlashcardSet;

  void _startQuiz(List<Flashcard> flashcards) {
    if (flashcards.length < 4) {
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
      List<String> choices = [flashcard.definition];

      while (choices.length < 4) {
        var randomFlashcard = flashcards[Random().nextInt(flashcards.length)];

        if (randomFlashcard != flashcard && !choices.contains(randomFlashcard.definition)) {
          choices.add(randomFlashcard.definition);
        }
      }

      choices.shuffle();

      questions.add({
        'question': flashcard.term,
        'correctAnswer': flashcard.definition,
        'choices': choices,
      });
    }
    questions.shuffle();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => QuizPage(questions: questions),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final subjects = ref.watch(subjectsProvider(widget.uid));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Flashcards for Quiz'),
        backgroundColor: Colors.green,
      ),
      body: Column(
        children: [
          DropdownButton<Subject>(
            hint: const Text('Select Subject'),
            value: selectedSubject,
            onChanged: (newValue) {
              setState(() {
                selectedSubject = newValue;
                selectedFlashcardSet = null;
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
              items: ref.watch(flashcardSetsProvider(selectedSubject!.documentId)).map((set) {
                return DropdownMenuItem(
                  value: set,
                  child: Text(set.title),
                );
              }).toList(),
            ),
          const Spacer(),
          ElevatedButton(
            onPressed: () {
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

              final flashcards = ref.watch(
                flashcardsProvider(selectedFlashcardSet!), // Pass the entire FlashcardSet object
              ) as List<Flashcard>;

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
