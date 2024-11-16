import 'package:flutter/material.dart';
import '../subject function/add_flashcardSets_screen.dart';

class Subject {
  String title;
  List<FlashcardSet> flashcardSets;

  Subject(this.title) : flashcardSets = [];
}

class SubjectScreen extends StatefulWidget {
  const SubjectScreen({super.key});

  @override
  _SubjectScreenState createState() => _SubjectScreenState();
}

class _SubjectScreenState extends State<SubjectScreen> {
  List<Subject> subjects = [];
  int? _hoveredIndex;

  void _addSubject() {
    TextEditingController subjectController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        
        return AlertDialog(
          title: const Text('Create Subject'),
          content: TextField(
            controller: subjectController,
            decoration: const InputDecoration(labelText: 'Subject Title'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                final setName = subjectController.text.trim();
                if (setName.isNotEmpty) {
                  setState(() {
                    subjects.add(Subject(subjectController.text));
                  });
                  Navigator.pop(context);
                }
              },
              child: const Text('Create'),
            ),
          ],
        );
      },
    );
  }

  void _editSubject(int index) {
    TextEditingController subjectController = TextEditingController(text: subjects[index].title);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Subject'),
          content: TextField(
            controller: subjectController,
            decoration: const InputDecoration(labelText: 'Set New Title'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                setState(() {
                  subjects[index].title = subjectController.text.trim();
                });
                Navigator.pop(context);
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  // Function to delete a specific flashcard set
  void _deleteSubject(int index) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Subject'),
          content: const Text('Deleting this subject will delete everything inside it.'),
          actions: [
            TextButton(
              onPressed: () {
                setState(() {
                  subjects.removeAt(index);
                });
                Navigator.pop(context);
              },
              child: const Text('Delete'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog without deleting
              },
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  void _openSubject(Subject subject) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddFlashcardSetScreen(subject: subject),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200], // Set the background color of the entire Scaffold
      appBar: AppBar(
        title: const Text('Subjects'),
        backgroundColor: Colors.grey[200], // Ensure AppBar is also grey to match the background
      ),
      body: subjects.isEmpty 
        ? Center(
          child: Text('No subjects created yet.'),
        ) 
        : Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.5,
          ),
          itemCount: subjects.length,
          itemBuilder: (context, index) {
            return MouseRegion(

              onEnter: (_) {
                setState(() {
                  _hoveredIndex = index;
                });
              },
              onExit: (_) {
                setState(() {
                  _hoveredIndex = null;
                });
              },

              child: GestureDetector(
                onTap: () => _openSubject(subjects[index]), // Open set on tap
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[100], // Set the container's background color to a slightly darker grey
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 4,
                        offset: Offset(2, 2),
                      ),
                    ],
                  ),
                  child: Stack(
                    children: [
                      Center(
                        child: Text(
                          subjects[index].title,
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ),
                      if (_hoveredIndex == index)
                        Positioned(
                          top: 8,
                          right: 8,
                          child: Row(
                            children: [
                              IconButton(
                                    icon: Icon(Icons.edit),
                                    onPressed: () => _editSubject(index),
                                  ),
                              IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                onPressed: () => _deleteSubject(index), // Delete on press
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addSubject,
        backgroundColor: const Color.fromARGB(255, 255, 255, 255),
        child: const Icon(Icons.add),
      ),
    );
  }
}
