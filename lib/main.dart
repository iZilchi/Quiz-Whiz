// main.dart
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flashcard_project/firebase/firebase_options.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'pages/home_page.dart';
import 'navigation buttons/quiz_screen.dart';
import 'navigation buttons/subject_screen.dart';
import 'navigation buttons/profile_screen.dart';
import 'pages/login_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(
    const ProviderScope(child: QuizWhizApp()),
  );
}

class QuizWhizApp extends StatelessWidget {
  const QuizWhizApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Quiz Whiz',
      theme: ThemeData(primarySwatch: Colors.green),
      debugShowCheckedModeBanner: false,
      // Keep all routes here
      initialRoute: '/',
      routes: {
        '/': (context) => const AuthChecker(),
        '/login': (context) => LoginPage(),
        '/home': (context) => const HomePage(),
        '/quiz': (context) {
          final uid = ModalRoute.of(context)?.settings.arguments as String;
          return QuizScreen(uid: uid);
        },
        '/subjects': (context) {
          final uid = ModalRoute.of(context)?.settings.arguments as String;
          return SubjectScreen(uid: uid);
        },
        '/profile': (context) => ProfileScreen(),
      },
    );
  }
}

class AuthChecker extends StatelessWidget {
  const AuthChecker({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasData && snapshot.data != null) {
          // User is authenticated
          final String uid = snapshot.data!.uid;
          // Navigate to home page
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.pushReplacementNamed(context, '/home', arguments: uid);
          });
          return const SizedBox(); // Empty widget while navigating
        } else {
          // User is not authenticated
          return LoginPage();
        }
      },
    );
  }
}

