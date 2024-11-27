import 'package:flutter/material.dart';
import 'dart:async';
import '../tests pages/result_page.dart';

class QuizPage extends StatefulWidget {
  final List<Map<String, dynamic>> questions;
  final int? timerDuration;

  const QuizPage({
    super.key,
    required this.questions,
    this.timerDuration,
  });

  @override
  _QuizPageState createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  Map<int, String?> selectedAnswers = {};
  int currentQuestionIndex = 0;
  Timer? _timer;
  late int _remainingTime;

   @override
  void initState() {
    super.initState();
    if (widget.timerDuration != null) {
      _remainingTime = widget.timerDuration!;
      _startTimer();
    }
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingTime > 0) {
        setState(() {
          _remainingTime--;
        });
      } else {
        _timer?.cancel();
        _submitQuiz();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

    String _formatTime(int seconds) {
    int hours = seconds ~/ 3600;
    int minutes = (seconds % 3600) ~/ 60;
    int secs = seconds % 60;

    if (hours > 0) {
      return '$hours hr ${minutes.toString().padLeft(2, '0')} min';
    } else {
      return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
    }
  }


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
        return true;
      }
    }
    return true;
  }

  void _submitQuiz() {
    int score = 0;
    for (int i = 0; i < widget.questions.length; i++) {
      if (selectedAnswers[i] == widget.questions[i]['correctAnswer']) {
        score++;
      }
    }
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (context) => ResultPage(
          score: score,
          totalQuestions: widget.questions.length,
          selectedAnswers: selectedAnswers,
          questions: widget.questions,
          quizType: 'MultipleChoice',
          previousTimerDuration: widget.timerDuration,
        ),
      ),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final question = widget.questions[currentQuestionIndex];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Multiple Choice Quiz'),
        automaticallyImplyLeading: false,
        actions: [
          if (widget.timerDuration != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Center(
                child: Text(
                  'Time Left: ${_formatTime(_remainingTime)}',
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Question ${currentQuestionIndex + 1}/${widget.questions.length}',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
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
                  onPressed: currentQuestionIndex < widget.questions.length - 1
                      ? _goToNextQuestion
                      : null,
                  child: const Text('Next'),
                ),
              ],
            ),
            const SizedBox(height: 20),
            if (currentQuestionIndex == widget.questions.length - 1)
              ElevatedButton(
                onPressed: _isQuizComplete() ? _submitQuiz : null,
                child: const Text('Submit'),
              ),
          ],
        ),
      ),
    );
  }
}
