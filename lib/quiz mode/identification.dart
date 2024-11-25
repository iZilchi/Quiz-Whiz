import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models.dart';
import '../providers/subject_provider.dart';
import '../providers/flashcardSet_provider.dart';
import '../providers/flashcards_provider.dart';
import '../tests pages/identification_quiz_page.dart';

class IdentificationScreen extends ConsumerStatefulWidget {
  final String uid;
  const IdentificationScreen({super.key, required this.uid});

  @override
  _IdentificationScreenState createState() => _IdentificationScreenState();
}

class _IdentificationScreenState extends ConsumerState<IdentificationScreen> {
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
      questions.add({
        'question': flashcard.term,
        'correctAnswer': flashcard.definition,
      });
    }

    questions.shuffle();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => IdentificationQuizPage(questions: questions),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final subjects = ref.watch(subjectsProvider(widget.uid));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Flashcards for Identification Quiz'),
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
                selectedFlashcardSet = null; // Reset the selected flashcard set when the subject changes
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
            Consumer(
              builder: (context, ref, child) {
                final flashcardSets = ref.watch(
                  flashcardSetsProvider(selectedSubject!.documentId), // Pass the subject ID, not the object
                );

                return DropdownButton<FlashcardSet>(
                  hint: const Text('Select Flashcard Set'),
                  value: selectedFlashcardSet,
                  onChanged: (newValue) {
                    setState(() {
                      selectedFlashcardSet = newValue;
                    });
                  },
                  items: flashcardSets.map((set) {
                    return DropdownMenuItem(
                      value: set,
                      child: Text(set.title),
                    );
                  }).toList(),
                );
              },
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
