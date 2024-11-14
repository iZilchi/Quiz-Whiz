// main.dart
import 'package:flutter/material.dart';
import 'pages/home_page.dart';
import 'navigation buttons/quiz_screen.dart';
import 'navigation buttons/add_screen.dart';
import 'navigation buttons/subject_screen.dart';
import 'navigation buttons/profile_screen.dart';
import 'pages/login_page.dart';

void main() {
  runApp(QuizWhizApp());
}

class QuizWhizApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Quiz Whiz',
      theme: ThemeData(primarySwatch: Colors.green),
      debugShowCheckedModeBanner: false,
      initialRoute: '/login', // Start with the login screen
      routes: {
        '/login': (context) => LoginPage(),
        '/home': (context) => HomePage(),
        '/quiz': (context) => QuizScreen(),
        '/add': (context) => AddScreen(),
        '/subjects': (context) => SubjectScreen(),
        '/profile': (context) => ProfileScreen(),
      },
    );
  }
}
