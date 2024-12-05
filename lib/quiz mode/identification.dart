import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models.dart';
import '../providers/subject_provider.dart';
import '../providers/flashcardSet_provider.dart';
import '../providers/flashcards_provider.dart';
import '../tests pages/identification_quiz_page.dart';
import 'package:flutter/services.dart';

class IdentificationScreen extends ConsumerStatefulWidget {
  final String uid;
  const IdentificationScreen({Key? key, required this.uid}) : super(key: key);

  @override
  _IdentificationScreenState createState() => _IdentificationScreenState();
}

class _IdentificationScreenState extends ConsumerState<IdentificationScreen> {
  Subject? selectedSubject;
  FlashcardSet? selectedFlashcardSet;
  final TextEditingController timerController = TextEditingController();

  bool get isFormValid =>
      selectedSubject != null &&
      selectedFlashcardSet != null &&
      (timerController.text.isEmpty ||
          (int.tryParse(timerController.text) != null &&
              int.parse(timerController.text) >= 1 &&
              int.parse(timerController.text) <= 120));

  void _showErrorDialog(String title, String content) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
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
    }

    List<Map<String, dynamic>> questions = flashcards.map((flashcard) {
      return {
        'question': flashcard.term,
        'correctAnswer': flashcard.definition,
      };
    }).toList()
      ..shuffle();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => IdentificationQuizPage(
          questions: questions,
          timerDuration: timerDuration != null ? timerDuration * 60 : null,
          flashcardSet: selectedFlashcardSet!,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final subjects = ref.watch(subjectsProvider(widget.uid));

    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          'Identification Quiz',
          style: GoogleFonts.nunito(
            fontSize: 20, 
            fontWeight: FontWeight.bold, 
            color: Colors.white, 
          ),),
        backgroundColor: Color.fromARGB(255, 34, 123, 148),
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline),
            tooltip: 'Help',
            onPressed: () {
              _showErrorDialog(
                'Help',
                '1. Select a subject.\n'
                '2. Select a flashcard set.\n'
                '3. Enter a timer (optional).\n'
                '4. Press "Start Quiz" to begin.',
              );
            },
          ),
        ],
      ),
      body: subjects.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Subject Dropdown
                  _buildDropdown<Subject>(
                    label: 'Select Subject',
                    icon: Icons.school,
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
                  const SizedBox(height: 16),
                  // Flashcard Set Dropdown
                  if (selectedSubject != null)
                    _buildDropdown<FlashcardSet>(
                      label: 'Select Flashcard Set',
                      icon: Icons.collections_bookmark,
                      value: selectedFlashcardSet,
                      onChanged: (newValue) {
                        setState(() {
                          selectedFlashcardSet = newValue;
                        });
                      },
                      items: ref
                          .watch(flashcardSetsProvider(selectedSubject!.documentId))
                          .map((set) {
                        return DropdownMenuItem(
                          value: set,
                          child: Text(set.title),
                        );
                      }).toList(),
                    ),
                  const SizedBox(height: 16),
                  // Timer Input Field
                  TextField(
                    controller: timerController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    onChanged: (_) => setState(() {}),
                    decoration: InputDecoration(
                      labelText: 'Timer (minutes, max 120)',
                      prefixIcon: const Icon(Icons.timer),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      helperText: 'Leave empty for no timer.',
                      errorText: timerController.text.isNotEmpty &&
                              (int.tryParse(timerController.text) == null ||
                                  int.parse(timerController.text) < 1 ||
                                  int.parse(timerController.text) > 120)
                          ? 'Enter a valid timer (1-120 minutes).'
                          : null,
                    ),
                  ),
                  const Spacer(),
                  // Start Quiz Button
                  ElevatedButton.icon(
                    onPressed: isFormValid
                        ? () {
                            final flashcards = ref.watch(
                              flashcardsProvider(selectedFlashcardSet!),
                            );

                            _startQuiz(flashcards);
                          }
                        : null,
                    icon: const Icon(Icons.play_arrow),
                    label: const Text('Start Quiz',),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isFormValid
                          ? Colors.green
                          : Colors.green.withOpacity(0.6),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
    );
  }

  Widget _buildDropdown<T>({
    required String label,
    required IconData icon,
    required T? value,
    required void Function(T?) onChanged,
    required List<DropdownMenuItem<T>> items,
  }) {
    return DropdownButtonFormField<T>(
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      value: value,
      onChanged: onChanged,
      items: items,
    );
  }
}
