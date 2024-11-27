import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:math';
import '../models.dart';
import '../providers/subject_provider.dart';
import '../providers/flashcardSet_provider.dart';
import '../providers/flashcards_provider.dart';
import '../tests pages/multiple_choice_quiz_page.dart';
import 'package:flutter/services.dart';

class MultipleChoiceScreen extends ConsumerStatefulWidget {
  final String uid;
  const MultipleChoiceScreen({super.key, required this.uid});

  @override
  _MultipleChoiceScreenState createState() => _MultipleChoiceScreenState();
}

class _MultipleChoiceScreenState extends ConsumerState<MultipleChoiceScreen> {
  Subject? selectedSubject;
  FlashcardSet? selectedFlashcardSet;
  final TextEditingController timerController = TextEditingController();

  void _showErrorDialog(String title, String content) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _startQuiz(List<Flashcard> flashcards) {
    if (selectedFlashcardSet == null) {
      _showErrorDialog(
        'Flashcard Set Not Selected',
        'Please select a flashcard set before starting the quiz.',
      );
      return;
    }

    final flashcards = ref.read(flashcardsProvider(selectedFlashcardSet!));

    if (flashcards.length < 4) {
      _showErrorDialog(
        'Not Enough Flashcards',
        'You need at least 4 flashcards to start the quiz.',
      );
      return;
    }

    int? timerDuration;
    if (timerController.text.isNotEmpty) {
      timerDuration = int.tryParse(timerController.text);
      if (timerDuration == null || timerDuration < 1 || timerDuration > 120) {
        _showErrorDialog(
          'Invalid Timer',
          'Please enter a valid timer between 1 and 120 minutes.',
        );
        return;
      }
    }

    List<Map<String, dynamic>> questions = flashcards.map((flashcard) {
      List<String> incorrectAnswers = flashcards
          .where((f) => f != flashcard)
          .map((f) => f.term)
          .toList()
        ..shuffle();

      List<String> choices = ([flashcard.term] + incorrectAnswers.take(3).toList());
      choices.shuffle();

      return {
        'question': flashcard.definition,
        'correctAnswer': flashcard.term,
        'choices': choices,
      };
    }).toList()
      ..shuffle();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => QuizPage(
          questions: questions,
          timerDuration: timerDuration != null ? timerDuration * 60 : null,
        ),
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
      body: subjects.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : Column(
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
                const SizedBox(height: 16),
                TextField(
                  controller: timerController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: const InputDecoration(
                    labelText: 'Timer (minutes, max 120)',
                    border: OutlineInputBorder(),
                  ),
                ),
                const Spacer(),
                ElevatedButton(
                  onPressed: () {
                    if (selectedSubject == null) {
                      _showErrorDialog(
                        'Subject Not Selected',
                        'Please select a subject before starting the quiz.',
                      );
                      return;
                    }

                    if (selectedFlashcardSet == null) {
                      _showErrorDialog(
                        'Flashcard Set Not Selected',
                        'Please select a flashcard set before starting the quiz.',
                      );
                      return;
                    }

                    final flashcards = ref.watch(
                      flashcardsProvider(selectedFlashcardSet!),
                    );

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
