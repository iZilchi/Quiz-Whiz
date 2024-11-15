import 'package:flutter/material.dart';
import '../widgets/header.dart';
import '../widgets/subject_card.dart';
import '../navigation buttons/quiz_screen.dart';
import '../navigation buttons/subject_screen.dart';
import '../navigation buttons/profile_screen.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    HomeContent(),
    QuizScreen(),
    SubjectScreen(),
    ProfileScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: Column(
        children: [
          Header(title: 'QUIZ\nWHIZ', isHomePage: _currentIndex == 0),
          Expanded(
            child: _pages[_currentIndex],
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.task), label: 'Quiz'),
          BottomNavigationBarItem(icon: Icon(Icons.book), label: 'Subjects'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
        currentIndex: _currentIndex,
        selectedItemColor: Colors.green,
        unselectedItemColor: const Color.fromARGB(135, 68, 65, 65),
        backgroundColor: Colors.white,
        onTap: _onItemTapped,
      ),
    );
  }
}

// Main content widget for the home page
class HomeContent extends StatelessWidget {
  const HomeContent({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  decoration: InputDecoration(
                    prefixIcon: const Opacity(
                      opacity: 0.7, // Adjusts the opacity of the search icon
                      child: Icon(Icons.search, color: Colors.black),
                    ),
                    hintText: 'Search for subjects',
                    hintStyle: TextStyle(color: Colors.black.withOpacity(0.6)),
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.9), // Adds a slightly transparent background
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Recent',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SubjectCard(),
                    SubjectCard(),
                    SubjectCard(),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
