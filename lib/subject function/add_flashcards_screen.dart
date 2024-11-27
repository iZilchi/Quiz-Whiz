import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models.dart';
import '../providers/flashcards_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';

final hoverIndexProvider = StateProvider<int?>((ref) => null);
final currentFlashcardIndexProvider = StateProvider<int>((ref) => 0);
final isShowingTermProvider = StateProvider<bool>((ref) => true);
final isShuffledProvider = StateProvider<bool>((ref) => false);

class AddFlashcardScreen extends ConsumerWidget {
  final FlashcardSet flashcardSet;

  const AddFlashcardScreen({super.key, required this.flashcardSet});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final flashcards = ref.watch(flashcardsProvider(flashcardSet));
    final currentFlashcardIndex = ref.watch(currentFlashcardIndexProvider);
    final isShuffled = ref.watch(isShuffledProvider);
    
    
    XFile? _mediaFile;
        final ImagePicker _picker = ImagePicker();

        final String? uid = FirebaseAuth.instance.currentUser?.uid;
        if (uid == null) {
          return Scaffold(
            body: const Center(child: Text("User not authenticated")),
          );
        }

    Future<void> _pickMedia() async {
      final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        _mediaFile = pickedFile;
      }
    }

    Future<void> createFlashcardFolder(String term, String flashcardSetName) async {
      try {
        final directory = await getApplicationDocumentsDirectory();
        final userDirectory = Directory('${directory.path}/$uid');
        if (!await userDirectory.exists()) {
          await userDirectory.create(recursive: true);
        }

        final flashcardSetDirectory = Directory('${userDirectory.path}/$flashcardSetName');
        if (!await flashcardSetDirectory.exists()) {
          await flashcardSetDirectory.create(recursive: true);
        }

        final flashcardDirectory = Directory('${flashcardSetDirectory.path}/$term');
        if (!await flashcardDirectory.exists()) {
          await flashcardDirectory.create(recursive: true);
          print("Folder for $term created successfully.");
        }
      } catch (e) {
        print("Error creating folder: $e");
      }
    }

    Future<void> deleteFlashcardFolder(String term, String flashcardSetName) async {
      try {
        final directory = await getApplicationDocumentsDirectory();
        final userDirectory = Directory('${directory.path}/$uid');
        if (!await userDirectory.exists()) {
          await userDirectory.create(recursive: true);
        }

        final flashcardSetDirectory = Directory('${userDirectory.path}/$flashcardSetName');
        if (!await flashcardSetDirectory.exists()) {
          await flashcardSetDirectory.create(recursive: true);
        }

        final flashcardDirectory = Directory('${flashcardSetDirectory.path}/$term');

        if (await flashcardDirectory.exists()) {
          await flashcardDirectory.delete(recursive: true);
          print("Folder for $term deleted successfully.");
        } else {
          print("Folder does not exist: ${flashcardDirectory.path}");
        }
      } catch (e) {
        print("Error deleting folder: $e");
      }
    }

    Future<String?> _saveMediaLocally(XFile file, String flashcardSetName, String flashcardId) async {
      try {
        final directory = await getApplicationDocumentsDirectory();
        final userDirectory = Directory('${directory.path}/$uid');
        if (!await userDirectory.exists()) {
          await userDirectory.create(recursive: true);
        }

        final flashcardSetDirectory = Directory('${userDirectory.path}/$flashcardSetName');
        if (!await flashcardSetDirectory.exists()) {
          await flashcardSetDirectory.create(recursive: true);
        }

        final flashcardDirectory = Directory('${flashcardSetDirectory.path}/$flashcardId');
        if (!await flashcardDirectory.exists()) {
          await flashcardDirectory.create(recursive: true);
        }

        final filePath = '${flashcardDirectory.path}/${file.name}';
        await File(file.path).copy(filePath);
        print("Image saved to path: $filePath");

        return filePath; // Return the saved path
      } catch (e) {
        print("Error saving media locally: $e");
        return null;
      }
    }


    void addFlashcard() {
      TextEditingController termController = TextEditingController();
      TextEditingController definitionController = TextEditingController();

      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Create Flashcard'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: termController,
                  decoration: const InputDecoration(labelText: 'Term'),
                ),
                TextField(
                  controller: definitionController,
                  decoration: const InputDecoration(labelText: 'Definition'),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    ElevatedButton(
                      onPressed: _pickMedia,
                      child: const Text('Upload Media'),
                    ),
                    if (_mediaFile != null)
                      Padding(
                        padding: const EdgeInsets.only(left: 10),
                        child: Text('Selected: ${_mediaFile?.name ?? ''}'),
                      ),
                  ],
                ),
                if (_mediaFile != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: Image.file(
                      File(_mediaFile!.path),
                      height: 150,
                      width: 150,
                      fit: BoxFit.cover,
                    ),
                  ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () async {
                  final term = termController.text.trim();
                  final definition = definitionController.text.trim();
                  if (term.isNotEmpty && definition.isNotEmpty) {
                    String? mediaPath;

                    if (_mediaFile != null) {
                      final localPath = await _saveMediaLocally(
                        _mediaFile!,
                        flashcardSet.title, 
                        term,
                      );
                      if (localPath != null) {
                        mediaPath = localPath;
                      }
                    }

                    ref
                        .read(flashcardsProvider(flashcardSet).notifier)
                        .addFlashcard(term, definition, imageUrl: mediaPath, uid: uid);
                    Navigator.pop(context);
                  }
                },
                child: const Text('Add'),
              ),
            ],
          );
        },
      );
    }

    void editFlashcard(int index) {
      final flashcard = ref.read(flashcardsProvider(flashcardSet))[index];
      TextEditingController termController =
          TextEditingController(text: flashcard.term);
      TextEditingController definitionController =
          TextEditingController(text: flashcard.definition);

      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Edit Flashcard'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: termController,
                  decoration: const InputDecoration(labelText: 'Term'),
                ),
                TextField(
                  controller: definitionController,
                  decoration: const InputDecoration(labelText: 'Definition'),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () async {
                  final updatedTerm = termController.text.trim();
                  final updatedDefinition =
                      definitionController.text.trim();

                  if (updatedTerm.isNotEmpty && updatedDefinition.isNotEmpty) {
                    final oldTerm = flashcard.term;
                    final flashcardSetName = flashcardSet.title;
                    await deleteFlashcardFolder(oldTerm, flashcardSetName);

                    ref
                        .read(flashcardsProvider(flashcardSet).notifier)
                        .editFlashcard(flashcard.documentId, updatedTerm, updatedDefinition);

                    await createFlashcardFolder(updatedTerm, flashcardSetName);
                  }

                  Navigator.pop(context);
                },
                child: const Text('Save'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
            ],
          );
        },
      );
    }


    void deleteFlashcard(int index) {
      final flashcards = ref.read(flashcardsProvider(flashcardSet));

      if (index >= 0 && index < flashcards.length) {
        final flashcard = flashcards[index];
        final term = flashcard.term;
        final flashcardSetName = flashcardSet.title;

        ref
            .read(flashcardsProvider(flashcardSet).notifier)
            .deleteFlashcard(flashcard.documentId);

        deleteFlashcardFolder(term, flashcardSetName);

        final newFlashcardCount = flashcards.length - 1;
        if (newFlashcardCount == 0) {
          ref.read(currentFlashcardIndexProvider.notifier).state = 0;
        } else if (index >= newFlashcardCount) {
          ref.read(currentFlashcardIndexProvider.notifier).state =
              newFlashcardCount - 1;
        }
      }
    }


    void navigateToPreviousFlashcard() {
      if (flashcards.isNotEmpty) {
        ref.read(currentFlashcardIndexProvider.notifier).state =
            (currentFlashcardIndex - 1 + flashcards.length) %
                flashcards.length;
      }
    }

    void navigateToNextFlashcard() {
      if (flashcards.isNotEmpty) {
        ref.read(currentFlashcardIndexProvider.notifier).state =
            (currentFlashcardIndex + 1) % flashcards.length;
      }
    }

    void toggleShuffle() {
      if (isShuffled) {
        ref
            .read(flashcardsProvider(flashcardSet).notifier)
            .restoreOriginalOrder();
      } else {
        ref
            .read(flashcardsProvider(flashcardSet).notifier)
            .shuffleFlashcards();
      }
      ref.read(isShuffledProvider.notifier).state = !isShuffled;
    }

    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        title: Text('Flashcards for ${flashcardSet.title}'),
        backgroundColor: Colors.grey[200],
      ),
      body: flashcards.isEmpty
          ? const Center(child: Text('No flashcards created yet.'))
          : Center(
            child: GestureDetector(
              onTap: () {
                ref.read(isShowingTermProvider.notifier).state =
                !ref.read(isShowingTermProvider);
          },
          child: Card(
            elevation: 5,
            margin: const EdgeInsets.all(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    ref.watch(isShowingTermProvider)
                        ? flashcards[currentFlashcardIndex].term
                        : flashcards[currentFlashcardIndex].definition,
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),

                  if (flashcards[currentFlashcardIndex].imageUrl != null &&
                      File(flashcards[currentFlashcardIndex].imageUrl!).existsSync())
                    Padding(
                      padding: const EdgeInsets.only(top: 16),
                      child: Image.file(
                        File(flashcards[currentFlashcardIndex].imageUrl!),
                        height: 200,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    )
                  else if (flashcards[currentFlashcardIndex].imageUrl != null)
                    const Padding(
                      padding: EdgeInsets.only(top: 16),
                      child: Text(
                        'Image not found',
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  const SizedBox(height: 16),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.blue),
                        onPressed: navigateToPreviousFlashcard,
                      ),
                      IconButton(
                        icon: const Icon(Icons.arrow_forward, color: Colors.blue),
                        onPressed: navigateToNextFlashcard,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: Icon(
                          isShuffled ? Icons.shuffle_on : Icons.shuffle,
                          color: Colors.orange,
                        ),
                        onPressed: toggleShuffle,
                      ),
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () {
                          editFlashcard(currentFlashcardIndex);
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          deleteFlashcard(currentFlashcardIndex);
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: addFlashcard,
        child: const Icon(Icons.add),
      ),
    );
  }
}
