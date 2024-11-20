import 'package:flashcard_project/providers/subject_provider.dart';
import 'package:flashcard_project/subject%20function/add_flashcardSets_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
    const HomeContent(),
    const QuizScreen(),
    const SubjectScreen(),
    const ProfileScreen(),
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
class HomeContent extends ConsumerWidget {
  const HomeContent({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subjects = ref.watch(subjectsProvider); // Get the full list of subjects
    final recentSubjects = subjects.reversed.take(5).toList(); // Nireverse yung order ng list ng subject tas kinuha yung first 5 subjects created para makuha yung latest subjects.

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search, color: Colors.black87),
                hintText: 'Search for subjects',
                hintStyle: TextStyle(color: Colors.black.withOpacity(0.6)),
                filled: true,
                fillColor: Colors.white.withOpacity(0.9),
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
            if (recentSubjects.isEmpty)
              const Text('No recent subjects.', style: TextStyle(color: Colors.black54)),
            if (recentSubjects.isNotEmpty)
              SizedBox(
                height: 115, // Set a fixed height for the horizontal list
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: recentSubjects.length,
                  itemBuilder: (context, index) {
                    final subject = recentSubjects[index];
                    return GestureDetector(
                      onTap: () {
                        // Navigate to the specific subject
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AddFlashcardSetScreen(subject: subject),
                          ),
                        );
                      },
                      child: Container(
                        width: 135, // Width of each card
                        margin: const EdgeInsets.only(right: 16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 4,
                              offset: Offset(2, 2),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            subject.title,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}
