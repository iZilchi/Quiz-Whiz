// ignore_for_file: library_private_types_in_public_api, prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flashcard_project/providers/subject_provider.dart';
import 'package:flashcard_project/subject%20function/add_flashcardSets_screen.dart';
import 'package:flashcard_project/subject%20function/add_flashcards_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_calendar/table_calendar.dart'; // Import the table_calendar package
import '../widgets/header.dart';
import '../firebase/firestore_services.dart';
import '../navigation buttons/quiz_screen.dart';
import '../navigation buttons/subject_screen.dart';
import '../navigation buttons/profile_screen.dart';
import '../models.dart';
import "package:google_fonts/google_fonts.dart";

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
class HomeContent extends ConsumerStatefulWidget {
  final String uid;
  const HomeContent({super.key, required this.uid});

  @override
  _HomeContentState createState() => _HomeContentState();
}

class _HomeContentState extends ConsumerState<HomeContent> {
  List<dynamic> searchResults = [];
  final FocusNode _searchFocusNode = FocusNode(); // FocusNode to track search bar focus
  final TextEditingController _searchController = TextEditingController(); // Text controller for the search input

  // Calendar variables
  
  late final DateTime _focusedDay;
  late final ValueNotifier<Set<DateTime>> _activityDays;

  @override
  void initState() {
    super.initState();
    _focusedDay = DateTime.now();
    _activityDays = ValueNotifier<Set<DateTime>>({});

    _searchController.addListener(() {
      _performSearch(_searchController.text);
    });

    _fetchActivityDays();
  }

  Future<void> _fetchActivityDays() async {
    final days = await FirestoreService().getActivityDates(widget.uid);
    setState(() {
      _activityDays.value = days.toSet();
    });
  }


  void _performSearch(String query) async {
    if (query.isNotEmpty) {
      final results = await FirestoreService().searchData(widget.uid, query);
      setState(() {
        searchResults = results;
      });
    } else {
      setState(() {
        searchResults = [];
      });
    }
  }

  @override
  void dispose() {
    _searchFocusNode.dispose();
    _searchController.dispose(); // Dispose of the text controller
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final recentSubjects = ref.watch(subjectsProvider(widget.uid)).reversed.take(5).toList();

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search Bar
            TextField(
              focusNode: _searchFocusNode, // Attach the FocusNode
              controller: _searchController, // Attach the TextEditingController
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search, color: Colors.black87),
                hintText: 'Search for subjects or flashcard sets...',
                hintStyle: TextStyle(color: Colors.black.withOpacity(0.6)),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 12.0),
              ),
            ),
            const SizedBox(height: 20),

            // Display search results if available
            if (_searchFocusNode.hasFocus && searchResults.isNotEmpty)
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 8,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: ListView.builder(
                  padding: EdgeInsets.zero, // Remove unnecessary padding
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: searchResults.length,
                  itemBuilder: (context, index) {
                    final item = searchResults[index];
                    return ListTile(
                      title: Text(item.title),
                      subtitle: item is FlashcardSet ? Text('Flashcard Set') : Text('Subject'),
                      onTap: () {
                        if (item is Subject) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AddFlashcardSetScreen(subject: item),
                            ),
                          );
                        } else if (item is FlashcardSet) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AddFlashcardScreen(flashcardSet: item),
                            ),
                          );
                        }
                      },
                    );
                  },
                ),
              )
            else if (_searchFocusNode.hasFocus && searchResults.isEmpty)
              const Text(
                'No results found',
                style: TextStyle(color: Colors.black54),
              ),

            // Display recent subjects
            Text(
              'Recent',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.normal,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 10),

            if (recentSubjects.isEmpty)
              const Text(
                'No recent subjects.',
                style: TextStyle(color: Colors.black54),
              ),

            if (recentSubjects.isNotEmpty)
              SizedBox(
                height: 115,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: recentSubjects.length,
                  itemBuilder: (context, index) {
                    final subject = recentSubjects[index];
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AddFlashcardSetScreen(subject: subject),
                          ),
                        );
                      },
                      child: Container(
                        width: 135,
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
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.folder,
                              size: 36,
                              color: Color.fromARGB(255, 255, 220, 127),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              subject.title,
                              textAlign: TextAlign.center,
                              style: GoogleFonts.nunito(
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
            const SizedBox(height: 20),

            // Calendar Streak
            Text(
              'Calendar Streak',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.normal,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 10),

            Container(
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
              child: TableCalendar(
                focusedDay: _focusedDay,
                firstDay: DateTime.utc(2020, 1, 1),
                lastDay: DateTime.utc(2030, 12, 31),

                availableCalendarFormats: const {
                  CalendarFormat.month: 'Month',
                },

                // Use eventLoader to load activity data from Firestore
                eventLoader: (day) {
                  final normalizedDay = DateTime(day.year, day.month, day.day); // Normalize the date to ignore time
                  return _activityDays.value.where((storedDay) {
                    final normalizedStoredDay = DateTime(storedDay.year, storedDay.month, storedDay.day);
                    return normalizedStoredDay.isAtSameMomentAs(normalizedDay);
                  }).toList();
                },

                // Normalize the date to ignore the time
                selectedDayPredicate: (day) {
                  final normalizedDay = DateTime(day.year, day.month, day.day);
                  return _activityDays.value.any((storedDay) {
                    final normalizedStoredDay = DateTime(storedDay.year, storedDay.month, storedDay.day);
                    return normalizedStoredDay.isAtSameMomentAs(normalizedDay);
                  });
                },

                // Calendar Style
                calendarStyle: CalendarStyle(
                  todayDecoration: BoxDecoration(
                    color: Colors.blue, // Blue color for today
                    shape: BoxShape.circle,
                  ),
                  // No marker decoration here, we'll manage it through selectedDayPredicate
                  selectedDecoration: BoxDecoration(
                    color: Colors.orange, // Green color for streak days
                    shape: BoxShape.circle,
                  ),
                  markersMaxCount: 0,
                ),

                headerStyle: HeaderStyle(
                  formatButtonVisible: false, // Hide the format button
                  titleCentered: true, // Center the title
                  leftChevronVisible: true, // Optional: hide the left chevron
                  rightChevronVisible: true, // Optional: hide the right chevron
                ),

                // No need for eventLoader as we're directly using selectedDayPredicate to handle the streak days
                onDaySelected: (selectedDay, focusedDay) {
                  //Do nothing
                },
              )
            ),
          ],
        ),
      ),
    );
  }
}
