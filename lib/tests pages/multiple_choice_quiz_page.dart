// ignore_for_file: library_private_types_in_public_api

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flashcard_project/models.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:async';
import '../firebase/firestore_services.dart';
import '../tests pages/result_page.dart';
import 'package:video_player/video_player.dart';
import 'package:path_provider/path_provider.dart';

class QuizPage extends StatefulWidget {
  final List<Map<String, dynamic>> questions;
  final int? timerDuration;
  final FlashcardSet flashcardSet;

  const QuizPage({
    super.key,
    required this.questions,
    this.timerDuration,
    required this.flashcardSet,
  });

  @override
  _QuizPageState createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  Map<int, String?> selectedAnswers = {};
  int currentQuestionIndex = 0;
  Timer? _timer;
  late int _remainingTime;
  File? mediaFile;
  String? uid;
  bool isMediaVisible = false;

   @override
  void initState() {
    super.initState();
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => const Scaffold(
              body: Center(child: Text("User not authenticated")),
            ),
          ),
        );
      });
    } else {
      uid = user.uid;
    }

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
    return selectedAnswers.length == widget.questions.length;
  }

  void recordActivity(String uid) {
    final today = DateTime.now();
    FirestoreService().addActivity(uid, today);
  }

  void _submitQuiz() {
    final user = FirebaseAuth.instance.currentUser;
    recordActivity(user!.uid);
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
          flashcardSet: widget.flashcardSet,
        ),
      ),
      (route) => false,
    );
  }

  Future<File?> fetchMedia(String flashcardSetName, String term) async {
      try {
        final directory = await getApplicationDocumentsDirectory();
        final filePath = '${directory.path}/$uid/$flashcardSetName/$term/';
        print('Checking directory path: $filePath');

        final dirExists = Directory(filePath).existsSync();
        print("Directory exists: $dirExists");

        if (!dirExists) return null;

        final allFiles = Directory(filePath).listSync().toList();
        print("Files in directory: ${allFiles.map((e) => e.path).toList()}");

        final mediaFileList = allFiles
            .whereType<File>()
            .where((file) =>
                file.path.endsWith('.png') ||
                file.path.endsWith('.jpg') ||
                file.path.endsWith('.jpeg') ||
                file.path.endsWith('.mp4') ||
                file.path.endsWith('.mkv'))
            .toList();

        if (mediaFileList.isEmpty) {
          print("No media files found in: $filePath");
          return null;
        }

        print("Media found: ${mediaFileList.first.path}");
        return mediaFileList.first;
      } catch (e) {
        print("Error in fetchMedia: $e");
        return null;
      }
    }

  Future<void> fetchAndDisplayMedia(String term) async {
    if (isMediaVisible) {
      // If media is already visible, hide it when the button is clicked again
      setState(() {
        isMediaVisible = false;
        mediaFile = null;
      });
    } else {
      // Fetch and display media if it's not already visible
      final file = await fetchMedia(widget.flashcardSet.title, term); 
      if (file != null && await file.exists()) {
        setState(() {
          mediaFile = file;
          isMediaVisible = true; // Show the media
        });
      } else {
        setState(() {
          mediaFile = null;
          isMediaVisible = false;
        });
      }
    }
  }

  Widget buildMediaWidget(File file) {
    if (file.path.endsWith('.mp4') || file.path.endsWith('.mkv')) {
      return GestureDetector(
        onTap: () {
          _showMediaPopup(file);
        },
        child: VideoPlayerWidget(file: file),
      );
    } else {
      return GestureDetector(
        onTap: () {
          _showMediaPopup(file);
        },
        child: Image.file(file),
      );
    }
  }

  void _showMediaPopup(File file) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                buildMediaWidget(file),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Close the popup
                  },
                  child: const Text('Close'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final question = widget.questions[currentQuestionIndex];

    print("Questions: ${widget.questions}");
    print("Term for current question: ${question['correctAnswer']}");

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
            ElevatedButton(
              onPressed: question['correctAnswer'] != null && question['correctAnswer'].isNotEmpty
                  ? () => fetchAndDisplayMedia(question['correctAnswer']!)
                  : null, // Only enable the button if 'term' is not null or empty
              child: Text(isMediaVisible ? 'Hide Media' : 'Show Media'),
            ),
            const SizedBox(height: 20),
            if (mediaFile != null) buildMediaWidget(mediaFile!),
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

class VideoPlayerWidget extends StatefulWidget {
  final File file;

  const VideoPlayerWidget({super.key, required this.file});

  @override
  _VideoPlayerWidgetState createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  late VideoPlayerController _controller;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    initializeVideoPlayer();
  }

  Future<void> initializeVideoPlayer() async {
    _controller = VideoPlayerController.file(widget.file);

    await _controller.initialize();
    if (mounted) {
      setState(() {
        _isInitialized = true;
        _controller.play();
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _isInitialized
        ? AspectRatio(
            aspectRatio: _controller.value.aspectRatio,
            child: VideoPlayer(_controller),
          )
        : const CircularProgressIndicator();
  }
}
