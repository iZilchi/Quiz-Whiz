import 'package:flutter/material.dart';

class IdentificationExamScreen extends StatefulWidget {
  @override
  _IdentificationExamScreenState createState() =>
      _IdentificationExamScreenState();
}

class _IdentificationExamScreenState extends State<IdentificationExamScreen> {
  final List<Map<String, dynamic>> questions = [
    {
      'question': 'What animal is this?',
      'correctAnswer': 'Lion',
      'userAnswer': '',
    },
    {
      'question': 'What is the name of this landmark?',
      'correctAnswer': 'Eiffel Tower',
      'userAnswer': '',
    },
    {
      'question': 'Which country does this flag belong to?',
      'correctAnswer': 'USA',
      'userAnswer': '',
    },
  ];

  int _currentQuestionIndex = 0;
  TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose(); // Dispose the controller when the widget is destroyed
    super.dispose();
  }

  int _calculateScore() {
    int score = 0;
    for (var question in questions) {
      if (question['userAnswer'].trim().toLowerCase() ==
          question['correctAnswer'].trim().toLowerCase()) {
        score++;
      }
    }
    return score;
  }

  void _submitAll() {
    int score = _calculateScore();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            ResultPage(score: score, totalQuestions: questions.length),
      ),
    );
  }

  void _nextQuestion() {
    if (_currentQuestionIndex < questions.length - 1) {
      setState(() {
        _currentQuestionIndex++;
        _controller.text = questions[_currentQuestionIndex]['userAnswer'];
      });
    }
  }

  void _previousQuestion() {
    if (_currentQuestionIndex > 0) {
      setState(() {
        _currentQuestionIndex--;
        _controller.text = questions[_currentQuestionIndex]['userAnswer'];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentQuestion = questions[_currentQuestionIndex];

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
          color: Colors.white, // Set the back arrow color to white
        ),
        title: Text(
          'Identification Exam',
          style: TextStyle(
            color: Colors.white, // Set the title text color to white
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.green,
        centerTitle: true,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(20),
            bottomRight: Radius.circular(20),
          ),
        ),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Removed the image, no longer used here
                SizedBox(height: 20),
                Container(
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 8,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Text(
                        currentQuestion['question'],
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 20),
                      TextField(
                        controller: _controller,
                        onChanged: (value) {
                          currentQuestion['userAnswer'] = value;
                        },
                        decoration: InputDecoration(
                          labelText: 'Type your answer here',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed:
                          _currentQuestionIndex > 0 ? _previousQuestion : null,
                      child: Text('Previous'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                      ),
                    ),
                    SizedBox(width: 20),
                    if (_currentQuestionIndex < questions.length - 1)
                      ElevatedButton(
                        onPressed: _nextQuestion,
                        child: Text('Next'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                        ),
                      ),
                    if (_currentQuestionIndex == questions.length - 1)
                      ElevatedButton(
                        onPressed: () => _submitAll(),
                        child: Text('Submit'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                        ),
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
                  value:
                      (_currentQuestionIndex + 1) / questions.length, // Progress
                  backgroundColor: Colors.grey[300],
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                ),
                SizedBox(height: 10),
                Text(
                  'Question ${_currentQuestionIndex + 1} of ${questions.length}',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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

  ResultPage({required this.score, required this.totalQuestions});

  @override
  Widget build(BuildContext context) {
    double percentage = (score / totalQuestions) * 100;
    String result = percentage >= 70 ? 'Passed' : 'Failed';
    Color resultColor = percentage >= 70 ? Colors.green : Colors.red;

    return Scaffold(
      appBar: AppBar(
        title: Text('Test Result'),
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
              SizedBox(height: 20),
              Text(
                'You $result!',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: resultColor,
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text('Back to Home'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  padding:
                      EdgeInsets.symmetric(vertical: 15, horizontal: 30),
                  textStyle: TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
