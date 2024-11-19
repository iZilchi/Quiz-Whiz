import 'package:flutter/material.dart';

class FillInTheBlanksScreen extends StatefulWidget {
  const FillInTheBlanksScreen({super.key});

  @override
  _FillInTheBlanksScreenState createState() => _FillInTheBlanksScreenState();
}

class _FillInTheBlanksScreenState extends State<FillInTheBlanksScreen> {
  final List<Map<String, dynamic>> questions = [
    {
      'question': 'The capital of France is _____.',
      'correctAnswer': 'Paris',
      'userAnswer': '',
    },
    {
      'question': 'Flutter is developed by _____.',
      'correctAnswer': 'Google',
      'userAnswer': '',
    },
    {
      'question': 'The sun rises in the _____.',
      'correctAnswer': 'east',
      'userAnswer': '',
    },
  ];

  int currentQuestionIndex = 0;
  final TextEditingController _controller = TextEditingController();

  void _submitAnswer() {
    if (currentQuestionIndex < questions.length - 1) {
      setState(() {
        questions[currentQuestionIndex]['userAnswer'] = _controller.text; // Save the user's answer
        _controller.clear(); // Clear the text field
        currentQuestionIndex++;
      });
    } else {
      _validateAnswers();
    }
  }

  void _goToPrevious() {
    if (currentQuestionIndex > 0) {
      setState(() {
        currentQuestionIndex--;
        _controller.text = questions[currentQuestionIndex]['userAnswer']; // Load the previous answer
      });
    }
  }

  void _validateAnswers() {
    int correctAnswers = 0;
    for (var question in questions) {
      if (question['userAnswer'].toLowerCase() == question['correctAnswer'].toLowerCase()) {
        correctAnswers++;
      }
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ResultPage(score: correctAnswers, totalQuestions: questions.length),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final question = questions[currentQuestionIndex];

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(80.0),
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(bottom: Radius.circular(30)),
          child: AppBar(
            title: const Text('Fill in the Blanks'),
            backgroundColor: Colors.green,
            centerTitle: true,
            titleTextStyle: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
            iconTheme: const IconThemeData(color: Colors.white), // Set the back arrow to white
          ),
        ),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween, // Space out the components
        children: [
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min, // Adjust to fit content
              children: [
                Text(
                  question['question'],
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: _controller,
                  decoration: InputDecoration(
                    labelText: 'Your Answer',
                    border: const OutlineInputBorder(),
                    suffixIcon: _controller.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              setState(() {
                                _controller.clear();
                                question['userAnswer'] = '';
                              });
                            },
                          )
                        : null,
                  ),
                  onChanged: (value) {
                    setState(() {
                      question['userAnswer'] = value.trim();
                    });
                  },
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center, // Center the buttons horizontally
                  children: [
                    ElevatedButton(
                      onPressed: currentQuestionIndex > 0 ? _goToPrevious : null,
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                      child: Text('Previous'),
                    ),
                    const SizedBox(width: 20), // Space between buttons
                    ElevatedButton(
                      onPressed: _submitAnswer,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: currentQuestionIndex < questions.length - 1
                            ? Colors.green
                            : Colors.blue,
                      ),
                      child: Text(currentQuestionIndex < questions.length - 1 ? 'Next' : 'Submit'),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Add the progress bar at the bottom
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                LinearProgressIndicator(
                  value: (currentQuestionIndex + 1) / questions.length, // Calculate progress
                  backgroundColor: Colors.grey[300],
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
                ),
                const SizedBox(height: 10),
                Text(
                  'Question ${currentQuestionIndex + 1} of ${questions.length}',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ],
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
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 30),
                  textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                child: Text('Back to Home'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
