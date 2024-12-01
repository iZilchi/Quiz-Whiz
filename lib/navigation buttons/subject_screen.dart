import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../subject function/add_flashcardSets_screen.dart';
import '../providers/subject_provider.dart'; // Import the provider

final hoverIndexProvider = StateProvider<int?>((ref) => null);

class SubjectScreen extends ConsumerWidget {
  final String uid;

  const SubjectScreen({super.key, required this.uid});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subjects = ref.watch(subjectsProvider(uid));  // Watch the subjects list
    final hoverIndex = ref.watch(hoverIndexProvider);

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
              ),
              autofocus: true,
            ),
            const SizedBox(height: 10),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              final setName = subjectController.text.trim();
              if (setName.isEmpty) {
                // Show a snack bar if the input is empty
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

              // Show success message
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Subject created successfully!'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: const Text('Create'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close the dialog without action
            },
            child: const Text('Cancel'),
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
      return AlertDialog(
        title: const Text('Edit Subject Title'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: subjectController,
              decoration: const InputDecoration(
                labelText: 'Set Subject Title',
                border: OutlineInputBorder(),
                hintText: 'Edit subject title here',
              ),
              autofocus: true,
            ),
            const SizedBox(height: 10),
          ],
        ),
        actions: [
          TextButton(
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

              // Show success message
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Subject updated successfully!'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: const Text('Save'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close the dialog without action
            },
            child: const Text('Cancel'),
          ),
        ],
      );
    },
  );
}


    void deleteSubject(int index) {
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text('Delete Subject'),
        content: const Text(
          'Are you sure you want to delete this subject? This action will also delete everything created inside it, including flashcards and sets.',
          style: TextStyle(color: Colors.redAccent),
        ),
        actions: [
          TextButton(
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
            child: const Text('Delete', style: TextStyle(color: Colors.redAccent)),
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
            child: const Text('Cancel'),
          ),
        ],
      );
    },
  );
}


    return Scaffold(
  backgroundColor: Colors.grey[50],
  appBar: AppBar(
    title: const Text('Subjects'),
    backgroundColor: Colors.grey[200],
    leading: null, // Removes the default back button
    elevation: 0,  // Flat app bar
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
              return MouseRegion(
                onEnter: (_) => ref.read(hoverIndexProvider.notifier).state = index,
                onExit: (_) => ref.read(hoverIndexProvider.notifier).state = null,
                child: GestureDetector(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AddFlashcardSetScreen(subject: subjects[index]),
                    ),
                  ),
                  child: Stack(
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 6,
                              offset: Offset(2, 2),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            subjects[index].title,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                      ),
                      if (hoverIndex == index) // Show buttons on hover
                        Positioned(
                          top: 8,
                          right: 8,
                          child: Row(
                            children: [
                              AnimatedOpacity(
                                opacity: hoverIndex == index ? 1 : 0,
                                duration: const Duration(milliseconds: 200),
                                child: IconButton(
                                  icon: const Icon(Icons.edit, color: Colors.blue),
                                  onPressed: () {
                                    editSubject(index);
                                  },
                                ),
                              ),
                              AnimatedOpacity(
                                opacity: hoverIndex == index ? 1 : 0,
                                duration: const Duration(milliseconds: 200),
                                child: IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.red),
                                  onPressed: () {
                                    deleteSubject(index);
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
  floatingActionButton: FloatingActionButton(
    onPressed: addSubject,
    backgroundColor: Colors.blueAccent,  // Custom background color for FAB
    child: const Icon(Icons.add, color: Colors.white),  // Icon color adjusted for contrast
    tooltip: 'Add Subject',  // Added tooltip for better UX
  ),
);
  }
}