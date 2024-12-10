import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../firebase/firestore_services.dart';
import '../subject function/add_flashcardSets_screen.dart';
import '../providers/subject_provider.dart'; // Import the provider

final showEditDeleteProvider = StateProvider<bool>((ref) => false);

class SubjectScreen extends ConsumerWidget {
  final String uid;

  const SubjectScreen({super.key, required this.uid});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subjects = ref.watch(subjectsProvider(uid));  // Watch the subjects list
    final showEditDelete = ref.watch(showEditDeleteProvider);

    void recordActivity(String uid) {
      final today = DateTime.now();
      FirestoreService().addActivity(uid, today);
    }

    void addSubject() {
      TextEditingController subjectController = TextEditingController();

      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Create Subject'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: subjectController,
                  decoration: const InputDecoration(
                    labelText: 'Subject Title',
                    border: OutlineInputBorder(),
                    hintText: 'Enter subject title here',
                    filled: true,
                    fillColor: Color(0xFFF5F5F5),
                  ),
                  autofocus: true,
                ),
                const SizedBox(height: 10),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context); // Close the dialog without action
                },
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 5, 89, 122), // Teal background
                ),
                onPressed: () {
                  final setName = subjectController.text.trim();
                  if (setName.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Subject title cannot be empty.'),
                        backgroundColor: Colors.redAccent,
                      ),
                    );
                    return;
                  }

                  // Check if the subject already exists to avoid duplication
                  final existingSubjects = ref.read(subjectsProvider(uid));
                  if (existingSubjects.any((subject) => subject.title == setName)) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('This subject already exists.'),
                        backgroundColor: Colors.orangeAccent,
                      ),
                    );
                    return;
                  }

                  // Add the subject using Riverpod and close the dialog
                  ref.read(subjectsProvider(uid).notifier).addSubject(setName);
                  Navigator.pop(context);
                  recordActivity(uid);

                  // Show success message
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Subject created successfully!'),
                      backgroundColor: Colors.green,
                    ),
                  );
                },
                child: const Text(
                  'Create',
                  style: TextStyle(color: Colors.white), // White text for "Create"
                ),
              ),
            ],
          );
        },
      );
    }

    void editSubject(int index) {
      TextEditingController subjectController = TextEditingController();

      // Pre-fill the controller with the existing subject title for editing
      final currentSubject = ref.read(subjectsProvider(uid))[index];
      subjectController.text = currentSubject.title;

      showDialog(
        context: context,
        builder: (context) {
          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 0,
            backgroundColor: Colors.transparent,
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 15,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Edit Subject Title',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.blueGrey[700],
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: subjectController,
                    decoration: InputDecoration(
                      labelText: 'Edit Subject Title',
                      hintText: 'Enter new subject title',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: Colors.grey[100],
                      prefixIcon: Icon(Icons.edit, color: Colors.blueGrey),
                    ),
                    autofocus: true,
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          final setName = subjectController.text.trim();

                          // Validate if input is empty
                          if (setName.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Subject title cannot be empty.'),
                                backgroundColor: Colors.redAccent,
                              ),
                            );
                            return;
                          }

                          // Check if the subject already exists in the list to avoid duplication
                          final existingSubjects = ref.read(subjectsProvider(uid));
                          if (existingSubjects.any((subject) => subject.title == setName && subject.title != currentSubject.title)) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('This subject already exists.'),
                                backgroundColor: Colors.orangeAccent,
                              ),
                            );
                            return;
                          }

                          // Apply the edit using Riverpod and close the dialog
                          ref.read(subjectsProvider(uid).notifier).editSubject(index, setName);
                          Navigator.pop(context);
                          recordActivity(uid);

                          // Show success message
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Subject updated successfully!'),
                              backgroundColor: Colors.green,
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blueGrey,
                          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                        ),
                        child: const Text(
                          'Save',
                          style: TextStyle(color: Colors.white), // White text for "Save"
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context); // Close the dialog without action
                        },
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.grey, padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                        ),
                        child: const Text('Cancel'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      );
    }

    void deleteSubject(int index) {
      showDialog(
        context: context,
        builder: (context) {
          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 0,
            backgroundColor: Colors.transparent,
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 15,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Delete Subject',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.redAccent,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Are you sure you want to delete this subject? This action will also delete everything created inside it, including flashcards and sets.',
                    style: TextStyle(color: Color.fromARGB(255, 0, 0, 0)),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          // Perform the deletion using Riverpod
                          ref.read(subjectsProvider(uid).notifier).deleteSubject(index);
                          Navigator.pop(context);

                          // Show success message with a snack bar
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Subject and its contents deleted successfully.'),
                              backgroundColor: Colors.green,
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.redAccent,
                          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                        ),
                        child: const Text(
                          'Delete',
                          style: TextStyle(color: Colors.white), // White text for "Delete"
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context); // Close the dialog if the user cancels
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Delete operation cancelled.'),
                              backgroundColor: Colors.blueGrey,
                            ),
                          );
                        },
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.grey, padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                        ),
                        child: const Text('Cancel'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      );
    }

    return Scaffold(
      backgroundColor: Colors.grey[50],  // Lighter background to reduce contrast
      appBar: AppBar(
        title: Text(
          'Subjects',
          style: GoogleFonts.nunito(
            fontSize: 25,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 2,
        actions: [
          IconButton(
            icon: Icon(
              showEditDelete ? Icons.settings_applications_outlined : Icons.settings_applications,
              color: Colors.blueGrey,
            ),
            onPressed: () {
              ref.read(showEditDeleteProvider.notifier).state =
                  !showEditDelete; // Toggle visibility state
            },
          ),
        ],
      ),
      body: subjects.isEmpty
          ? const Center(child: Text('No subjects created yet.'))
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
                  return GestureDetector(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            AddFlashcardSetScreen(subject: subjects[index]),
                      ),
                    ),
                    child: Stack(
                      children: [
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
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.book,
                                  color: Colors.blueGrey[700],
                                  size: 40,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  subjects[index].title,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blueGrey[700],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        if (showEditDelete)
                          Positioned(
                            top: 8,
                            left: 8,
                            child: IconButton(
                              onPressed: () => editSubject(index),
                              iconSize: 30,  // Adjusted size for the icon
                              icon: const Icon(Icons.edit, color: Colors.blueGrey),
                            ),
                          ),
                        if (showEditDelete)
                          Positioned(
                            top: 8,
                            right: 8,
                            child: IconButton(
                              onPressed: () => deleteSubject(index),
                              iconSize: 30,  // Adjusted size for the icon
                              icon: const Icon(Icons.delete, color: Colors.redAccent),
                            ),
                          ),
                      ],
                    ),
                  );
                },
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: addSubject,
        foregroundColor: Colors.white,
        backgroundColor: const Color.fromARGB(255, 5, 89, 122),  // A teal color for the FAB
        child: const Icon(Icons.add),
      ),
    );
  }
}
