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
      // Set SplashScreen as initial screen, which will transition to AuthChecker
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(), // SplashScreen as the first route
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

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Wait for 2 seconds before navigating to the login page
    Future.delayed(const Duration(seconds: 2), () {
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => LoginPage(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: animation,
              child: child,
            );
          },
          transitionDuration: const Duration(milliseconds: 500), // Duration of fade transition
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: const Color.fromARGB(255, 33,52,88), // Primary background color
        child: Center(
          child: Image.asset(
            'assets/logo.png',
            width: 150,
            height: 150,
          ),
        ),
      ),
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
          // User is authenticated, navigate to home page
          final String uid = snapshot.data!.uid;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.pushReplacementNamed(context, '/home', arguments: uid);
          });
          return const SizedBox(); // Empty widget while navigating
        } else {
          // User is not authenticated, navigate to login page
          return LoginPage();
        }
      },
    );
  }
}
