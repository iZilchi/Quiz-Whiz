import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../subject function/add_flashcardSets_screen.dart';
import '../providers/subject_provider.dart'; // Import the provider

final hoverIndexProvider = StateProvider<int?>((ref) => null);

class SubjectScreen extends ConsumerWidget {
  final String uid;

  const SubjectScreen({Key? key, required this.uid});

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
            content: TextField(
              controller: subjectController,
              decoration: const InputDecoration(labelText: 'Subject Title'),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  final setName = subjectController.text.trim();
                  if (setName.isNotEmpty) {
                    ref.read(subjectsProvider(uid).notifier).addSubject(setName);  // Use Riverpod to add subject
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

    void editSubject(int index) {
    TextEditingController subjectController = TextEditingController();

      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Edit Subject Title'),
            content: TextField(
              controller: subjectController,
              decoration: const InputDecoration(labelText: 'Set Subject Title'),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  final setName = subjectController.text.trim();
                    if (setName.isNotEmpty) {
                      ref.read(subjectsProvider(uid).notifier).editSubject(index, setName);  // Use Riverpod to add subject
                    Navigator.pop(context);
                  }
                },
                child: const Text('Save'),
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
            content: const Text('Deleting this subject will also delete everything that is created inside it.'),
            actions: [
              TextButton(
                onPressed: () {
                  ref.read(subjectsProvider(uid).notifier).deleteSubject(index);
                  Navigator.pop(context);
                },
                child: const Text('Delete'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('Cancel'),
              ),
            ],
          );
        },
      );
    }

    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        title: const Text('Subjects'),
        backgroundColor: Colors.grey[200],
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
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
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
                                subjects[index].title,
                                textAlign: TextAlign.center,
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                          if (hoverIndex == index) // Show buttons on hover
                            Positioned(
                              top: 8,
                              right: 8,
                              child: Row(
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.edit, color: Colors.blue),
                                    onPressed: () {
                                      editSubject(index);
                                    },
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete, color: Colors.red),
                                    onPressed: () {
                                      deleteSubject(index);
                                    },
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
        backgroundColor: const Color.fromARGB(255, 255, 255, 255),
        child: const Icon(Icons.add),
      ),
    );
  }
}
