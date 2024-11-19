import 'package:flashcard_project/pages/home_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models.dart';
import '../providers/subject_provider.dart';
import '../providers/flashcardSet_provider.dart';
import '../providers/flashcards_provider.dart';

class MultipleChoiceScreen extends ConsumerStatefulWidget {
  const MultipleChoiceScreen({super.key});

  @override
  _MultipleChoiceScreenState createState() => _MultipleChoiceScreenState();
}

class _MultipleChoiceScreenState extends ConsumerState<MultipleChoiceScreen> {
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

    // Prepare quiz questions and choices
    List<Map<String, dynamic>> questions = [];
    for (var flashcard in flashcards) {
      List<String> choices = [flashcard.definition];
      for (var otherFlashcard in flashcards) {
        if (otherFlashcard != flashcard) {
          choices.add(otherFlashcard.definition);
        }
      }
      choices.shuffle();
      questions.add({
        'question': flashcard.term,
        'correctAnswer': flashcard.definition,
        'choices': choices,
      });
    }

    // Navigate to the quiz page
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => QuizPage(questions: questions),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final subjects = ref.watch(subjectsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Flashcards for Quiz'),
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
          // Updated ElevatedButton with dialog error handling
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
              // Show dialog if there are fewer than 4 flashcards
              if (flashcards.isEmpty || flashcards.length < 4) {
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
              } else {
                _startQuiz(flashcards);
              }
            },
            child: const Text('Start Quiz'),
          ),
          const Spacer(),
        ],
      ),
    );
  }
}

class QuizPage extends StatefulWidget {
  final List<Map<String, dynamic>> questions;

  const QuizPage({super.key, required this.questions});

  @override
  _QuizPageState createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  Map<int, String?> selectedAnswers = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quiz'),
      ),
      body: ListView.builder(
        itemCount: widget.questions.length,
        itemBuilder: (context, index) {
          final question = widget.questions[index];

          return Card(
            margin: const EdgeInsets.all(10),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Question Text
                  Text(
                    question['question'],
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  // Choices as RadioListTile
                  ...question['choices'].map<Widget>((choice) {
                    return RadioListTile<String>(
                      title: Text(choice),
                      value: choice,
                      groupValue: selectedAnswers[index],
                      onChanged: (value) {
                        setState(() {
                          selectedAnswers[index] = value; // Update selected answer
                        });
                      },
                    );
                  }).toList(),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
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
              ),
            ),
          );
        },
        child: const Icon(Icons.check),
      ),
    );
  }
}

class ResultPage extends StatelessWidget {
  final int score;
  final int totalQuestions;

  const ResultPage({super.key, required this.score, required this.totalQuestions});

  @override
  Widget build(BuildContext context) {
    double percentage = (score / totalQuestions) * 100;
    String result = percentage >= 70 ? 'Passed' : 'Failed';
    Color resultColor = percentage >= 70 ? Colors.green : Colors.red;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Test Result'),
        backgroundColor: Colors.blue,
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'Your Score: $score/$totalQuestions',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: resultColor,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'You $result!',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: resultColor,
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => const HomePage()),
                    (route) => false, // This clears all previous routes
                  );
                },
                child: const Text('Back to Home'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
