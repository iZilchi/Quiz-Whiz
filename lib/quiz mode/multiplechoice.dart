import 'package:flutter/material.dart';

class MultipleChoiceScreen extends StatefulWidget {
  @override
  _MultipleChoiceScreenState createState() => _MultipleChoiceScreenState();
}

class _MultipleChoiceScreenState extends State<MultipleChoiceScreen> {
  final List<Map<String, dynamic>> questions = [
    {
      'question': 'What is the capital of France?',
      'options': ['Paris', 'London', 'Berlin', 'Madrid'],
      'selectedAnswer': null,
      'correctAnswer': 'Paris',
    },
    {
      'question': 'Which programming language is used by Flutter?',
      'options': ['Dart', 'Java', 'Kotlin', 'Swift'],
      'selectedAnswer': null,
      'correctAnswer': 'Dart',
    },
    {
      'question': 'What is 2 + 2?',
      'options': ['3', '4', '5', '6'],
      'selectedAnswer': null,
      'correctAnswer': '4',
    }
  ];

  int _currentQuestionIndex = 0;

  void _updateAnswer(int questionIndex, String answer) {
    setState(() {
      questions[questionIndex]['selectedAnswer'] = answer;
    });
  }

  void _nextQuestion() {
    if (_currentQuestionIndex < questions.length - 1) {
      setState(() {
        _currentQuestionIndex++;
      });
    }
  }

  void _previousQuestion() {
    if (_currentQuestionIndex > 0) {
      setState(() {
        _currentQuestionIndex--;
      });
    }
  }

  void _submitAnswers() {
    int correctAnswers = 0;
    for (var question in questions) {
      if (question['selectedAnswer'] == question['correctAnswer']) {
        correctAnswers++;
      }
    }

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Test Results'),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              ...questions.map<Widget>((question) {
                return Text(
                  '${question['question']} \nAnswer: ${question['selectedAnswer'] ?? 'Not answered'}\n',
                  style: TextStyle(fontSize: 16),
                );
              }).toList(),
              SizedBox(height: 20),
              Text(
                'You got $correctAnswers out of ${questions.length} correct.',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final question = questions[_currentQuestionIndex];
    double progress = (_currentQuestionIndex + 1) / questions.length;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text('Multiple Choice Questions'),
        backgroundColor: Colors.green,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: Colors.white, // Set the title text color to white
          fontSize: 22, // You can adjust the font size as needed
          fontWeight: FontWeight.bold, // Bold the text
        ),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'English',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(height: 20),
                  Card(
                    margin: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    elevation: 5,
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              question['question'],
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 20),
                            ...question['options'].map<Widget>((option) {
                              return ListTile(
                                title: Text(option),
                                leading: Radio<String>(
                                  value: option,
                                  groupValue: question['selectedAnswer'],
                                  onChanged: (String? value) {
                                    if (value != null) {
                                      _updateAnswer(_currentQuestionIndex, value);
                                    }
                                  },
                                ),
                              );
                            }).toList(),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Buttons at the bottom
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: _currentQuestionIndex > 0 ? _previousQuestion : null,
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
                    onPressed: _submitAnswers,
                    child: Text('Submit'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                    ),
                  ),
              ],
            ),
          ),
          // Progress bar at the bottom
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                LinearProgressIndicator(
                  value: progress,
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
