import 'package:firebase_auth/firebase_auth.dart';
import 'package:flashcard_project/providers/subject_provider.dart';
import 'package:flashcard_project/subject%20function/add_flashcardSets_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widgets/header.dart';
import '../navigation buttons/quiz_screen.dart';
import '../navigation buttons/subject_screen.dart';
import '../navigation buttons/profile_screen.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0; // Tracks the current tab index
  late final String uid;
  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    final User? user = FirebaseAuth.instance.currentUser; // Get the logged-in user
    uid = user?.uid ?? ''; // Safely handle cases where UID is null

    // Initialize the list of pages for the bottom navigation bar
    _pages = [
      HomeContent(uid: uid),
      QuizScreen(uid: uid),
      SubjectScreen(uid: uid),
      ProfileScreen(),
    ];
  }

  // Handles bottom navigation bar taps
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
          Header(title: 'QUIZ\nWHIZ', isHomePage: _currentIndex == 0), // Dynamic header
          Expanded(
            child: _pages[_currentIndex], // Show the page corresponding to the current tab
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
        selectedItemColor: Color.fromARGB(255, 17, 138, 178), // Highlight color for the selected tab
        unselectedItemColor: const Color.fromARGB(135, 68, 65, 65), // Dim color for unselected tabs
        backgroundColor: Colors.white,
        onTap: _onItemTapped,
      ),
    );
  }
}

// Home page main content widget
class HomeContent extends ConsumerWidget {
  final String uid;

  const HomeContent({super.key, required this.uid});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the subjectsProvider to fetch subjects
    final subjects = ref.watch(subjectsProvider(uid));
    final recentSubjects = subjects.reversed.take(5).toList(); // Get the 5 most recently created subjects

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search bar
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

            // Recent subjects header
            const Text(
              'Recent',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 10),

            // Show a message if there are no recent subjects
            if (recentSubjects.isEmpty)
              const Text(
                'No recent subjects.',
                style: TextStyle(color: Colors.black54),
              ),

            // Horizontal list of recent subjects
            if (recentSubjects.isNotEmpty)
              SizedBox(
                height: 115, // Fixed height for the horizontal list
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: recentSubjects.length,
                  itemBuilder: (context, index) {
                    final subject = recentSubjects[index];
                    return GestureDetector(
                      onTap: () {
                        // Navigate to the AddFlashcardSetScreen
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AddFlashcardSetScreen(subject: subject),
                          ),
                        );
                      },
                      child: Container(
                        width: 135, // Width of each card
                        margin: const EdgeInsets.only(right: 16), // Spacing between cards
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
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.folder, // Folder icon for each subject
                              size: 36,
                              color: Color.fromARGB(255, 255, 220, 127),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              subject.title,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                          ],
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
