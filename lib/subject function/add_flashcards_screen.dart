// ignore_for_file: no_leading_underscores_for_local_identifiers, depend_on_referenced_packages, use_super_parameters, library_private_types_in_public_api, use_build_context_synchronously, deprecated_member_use

import 'dart:io';
import 'package:flip_card/flip_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_player/video_player.dart';
import '../firebase/firestore_services.dart';
import '../models.dart';
import '../providers/flashcards_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:path/path.dart' as p;
final hoverIndexProvider = StateProvider<int?>((ref) => null);
final currentFlashcardIndexProvider = StateProvider<int>((ref) => 0);
final isShowingTermProvider = StateProvider<bool>((ref) => true);
final isShuffledProvider = StateProvider<bool>((ref) => false);
final displayedMediaProvider = StateProvider<File?>((ref) => null);
final isMediaShownProvider = StateProvider<bool>((ref) => false);

class VideoPlayerWidget extends StatefulWidget {
  final File file;

  const VideoPlayerWidget({Key? key, required this.file}) : super(key: key);

  @override
  _VideoPlayerWidgetState createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  late VideoPlayerController _controller;
  bool _isInitialized = false;
  bool _isError = false;

  @override
  void initState() {
    super.initState();
    initializeVideoPlayer();
  }

  Future<void> initializeVideoPlayer() async {
    _controller = VideoPlayerController.file(widget.file);

    try {
      await _controller.initialize();
      if (mounted) {
        setState(() {
          _isInitialized = true;
          _controller.play();
        });
      }
    } catch (e, stack) {
      // ignore: avoid_print
      print('Error initializing video player: $e');
      // ignore: avoid_print
      print(stack); // Print stack trace for debugging.
      setState(() {
        _isError = true;
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isError) {
      return const Center(child: Text('Error loading video'));
    }

    if (!_isInitialized) {
      return const Center(child: CircularProgressIndicator());
    }

    return AspectRatio(
      aspectRatio: _controller.value.aspectRatio,
      child: VideoPlayer(_controller),
    );
  }
}

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

    final String? uid = FirebaseAuth.instance.currentUser ?.uid;
    if (uid == null) {
      return const Scaffold(
        body: Center(child: Text("User  not authenticated")),
      );
    }

    Future<void> _pickMedia() async {
      final pickedFile = await showDialog<XFile?>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Select Media'),
            content: const Text('Choose an option to upload:'),
            actions: [
              TextButton(
                onPressed: () async {
                  final file = await _picker.pickImage(source: ImageSource.gallery);
                  Navigator.of(context).pop(file);
                },
                child: const Text('Image'),
              ),
              TextButton(
                onPressed: () async {
                  final file = await _picker.pickVideo(source: ImageSource.gallery);
                  Navigator.of(context).pop(file);
                },
                child: const Text('Video'),
              ),
            ],
          );
        },
      );

      if (pickedFile != null) {
        _mediaFile = pickedFile;
        print("Picked media file: ${_mediaFile!.path}");
      }
    }

    Future<File?> fetchMedia(String flashcardSetName, String term) async {
      try {
        final directory = await getApplicationDocumentsDirectory();
        final filePath = '${directory.path}/$uid/$flashcardSetName/$term/';
        print('Checking directory path: $filePath');

        final dirExists = Directory(filePath).existsSync();
        print("Directory exists: $dirExists");

        if (!dirExists) return null;

        final allFiles = Directory(filePath).listSync().toList();
        print("Files in directory: ${allFiles.map((e) => e.path).toList()}");

        final mediaFileList = allFiles
            .whereType<File>()
            .where((file) =>
                file.path.endsWith('.png') ||
                file.path.endsWith('.jpg') ||
                file.path.endsWith('.jpeg') ||
                file.path.endsWith('.mp4') ||
                file.path.endsWith('.mkv'))
            .toList();

        if (mediaFileList.isEmpty) {
          print("No media files found in: $filePath");
          return null;
        }

        print("Media found: ${mediaFileList.first.path}");
        return mediaFileList.first;
      } catch (e) {
        print("Error in fetchMedia: $e");
        return null;
      }
    }

    Future<void> fetchAndDisplayMedia(String term) async {
      final file = await fetchMedia(flashcardSet.title, term);
      if (file != null && await file.exists()) {
        ref.read(displayedMediaProvider.notifier).state = file;
        ref.read(isMediaShownProvider.notifier).state = true;
      } else {
        ref.read(isMediaShownProvider.notifier).state = false;
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
        print("Media saved to path: $filePath");

        final mediaName = p.basename(filePath);
        print("Extracted media name: $mediaName");

        return filePath;
      } catch (e) {
        print("Error saving media locally: $e");
        return null;
      }
    }

  void recordActivity(String uid) {
    final today = DateTime.now();
    FirestoreService().addActivity(uid, today);
  }

  void addFlashcard() {
    TextEditingController termController = TextEditingController();
    TextEditingController definitionController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: const Text(
            'Create Flashcard',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Term Input Field
                TextField(
                  controller: termController,
                  decoration: InputDecoration(
                    labelText: 'Term',
                    prefixIcon: const Icon(Icons.text_fields),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Definition Input Field
                TextField(
                  controller: definitionController,
                  decoration: InputDecoration(
                    labelText: 'Definition',
                    prefixIcon: const Icon(Icons.description),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Media Upload Button
                Row(
                  children: [
                    ElevatedButton.icon(
                      onPressed: _pickMedia,
                      icon: const Icon(Icons.upload_file),
                      label: const Text('Upload Media'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            vertical: 10, horizontal: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                    if (_mediaFile != null)
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(left: 10),
                          child: Text(
                            'Selected: ${_mediaFile?.name ?? ''}',
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(color: Colors.black54),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 16),

                // Media Preview
                if (_mediaFile != null)
                  Center(
                    child: _mediaFile!.path.endsWith('.mp4')
                        ? SizedBox(
                            height: 200,
                            width: 200,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: VideoPlayerWidget(file: File(_mediaFile!.path)),
                            ),
                          )
                        : ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.file(
                              File(_mediaFile!.path),
                              height: 200,
                              width: 200,
                              fit: BoxFit.cover,
                            ),
                          ),
                  ),
              ],
            ),
          ),
          actions: [
            // Cancel Button
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text(
                'Cancel',
                style: TextStyle(color: Colors.grey),
              ),
            ),
            // Add Button
            ElevatedButton(
              onPressed: () async {
                final term = termController.text.trim();
                final definition = definitionController.text.trim();

                if (term.isEmpty || definition.isEmpty) {
                  // Show an error if fields are empty
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please fill out all fields!'),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }

                String? mediaPath;
                if (_mediaFile != null) {
                  final localPath = await _saveMediaLocally(
                    _mediaFile!,
                    flashcardSet.title,
                    term,
                  );
                  if (localPath != null) mediaPath = localPath;
                }

                ref
                    .read(flashcardsProvider(flashcardSet).notifier)
                    .addFlashcard(term, definition, mediaUrl: mediaPath, uid: uid);

                // Clear media references
                ref.read(displayedMediaProvider.notifier).state = null;
                ref.read(isMediaShownProvider.notifier).state = false;

                recordActivity(uid);

              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
            child: const Text('Add'),
          ),
        ],
      );
    },
  );
}

  void editFlashcard(int index) {
  final flashcard = ref.read(flashcardsProvider(flashcardSet))[index];
  TextEditingController termController = TextEditingController(text: flashcard.term);
  TextEditingController definitionController =
      TextEditingController(text: flashcard.definition);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          title: const Text(
            'Edit Flashcard',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Term Input Field
                TextField(
                  controller: termController,
                  decoration: InputDecoration(
                    labelText: 'Term',
                    prefixIcon: const Icon(Icons.text_fields),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Definition Input Field
                TextField(
                  controller: definitionController,
                  decoration: InputDecoration(
                    labelText: 'Definition',
                    prefixIcon: const Icon(Icons.description),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            // Cancel Button
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Cancel',
                style: TextStyle(color: Colors.grey),
              ),
            ),

            // Save Button
            ElevatedButton(
              onPressed: () async {
                final updatedTerm = termController.text.trim();
                final updatedDefinition = definitionController.text.trim();

                if (updatedTerm.isEmpty || updatedDefinition.isEmpty) {
                  // Show error if fields are empty
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please fill out all fields!'),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }

                // Update Media Files and Flashcard Content
                ref.read(displayedMediaProvider.notifier).state = null;
                ref.read(isMediaShownProvider.notifier).state = false;

                final oldTerm = flashcard.term;
                final flashcardSetName = flashcardSet.title;

                // Fetch old media file
                File? oldMediaFile = await fetchMedia(flashcardSetName, oldTerm);

                // Create a new folder for the updated term
                await createFlashcardFolder(updatedTerm, flashcardSetName);

                if (oldMediaFile != null) {
                  try {
                    final newMediaPath =
                        '${(await getApplicationDocumentsDirectory()).path}/$uid/$flashcardSetName/$updatedTerm/${oldMediaFile.uri.pathSegments.last}';
                    await oldMediaFile.copy(newMediaPath);
                    print("Media moved to: $newMediaPath");
                  } catch (e) {
                    print("Error moving media: $e");
                  }
                }

                // Delete the old folder
                await deleteFlashcardFolder(oldTerm, flashcardSetName);

                // Update the flashcard data
                ref
                    .read(flashcardsProvider(flashcardSet).notifier)
                    .editFlashcard(
                      flashcard.documentId,
                      updatedTerm,
                      updatedDefinition,
                    );

                recordActivity(uid);

                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Flashcard updated successfully!'),
                    backgroundColor: Colors.green,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void deleteFlashcard(int index) {
    final flashcards = ref.read(flashcardsProvider(flashcardSet));

    if (index < 0 || index >= flashcards.length) {
      // Handle invalid index gracefully
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Invalid flashcard index.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final flashcard = flashcards[index];
    final term = flashcard.term;
    final flashcardSetName = flashcardSet.title;

    // Show confirmation dialog before deletion
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Flashcard'),
          content: const Text(
            'Are you sure you want to delete this flashcard? This action cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context), // Cancel deletion
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              onPressed: () async {
                Navigator.pop(context); // Close dialog

                // Delete flashcard from the provider
                ref
                    .read(flashcardsProvider(flashcardSet).notifier)
                    .deleteFlashcard(flashcard.documentId);

                // Delete associated folder/media files
                try {
                  await deleteFlashcardFolder(term, flashcardSetName);
                } catch (e) {
                  print("Error deleting flashcard folder: $e");
                }

                // Reset media-related state
                ref.read(displayedMediaProvider.notifier).state = null;
                ref.read(isMediaShownProvider.notifier).state = false;

                // Adjust the current flashcard index if needed
                final newFlashcardCount = flashcards.length - 1;
                if (newFlashcardCount == 0) {
                  ref.read(currentFlashcardIndexProvider.notifier).state = 0;
                } else if (index >= newFlashcardCount) {
                  ref.read(currentFlashcardIndexProvider.notifier).state =
                      newFlashcardCount - 1;
                }

                // Provide user feedback
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Flashcard deleted successfully.'),
                    backgroundColor: Colors.green,
                  ),
                );
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  void navigateToPreviousFlashcard() {
    if (flashcards.isEmpty) {
      // Provide feedback if no flashcards are available
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No flashcards available to navigate.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Clear media state
    ref.read(displayedMediaProvider.notifier).state = null;
    ref.read(isMediaShownProvider.notifier).state = false;

    // Safely calculate the previous flashcard index
    final previousIndex =
        (currentFlashcardIndex - 1 + flashcards.length) % flashcards.length;

    // Update the current flashcard index
    ref.read(currentFlashcardIndexProvider.notifier).state = previousIndex;

    // Provide optional feedback (if necessary)
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Navigated to flashcard ${previousIndex + 1} of ${flashcards.length}.'),
        backgroundColor: Colors.blueGrey,
        duration: const Duration(seconds: 1),
      ),
    );
  }

  void navigateToNextFlashcard() {
    if (flashcards.isEmpty) {
      // Show an improved notification with action
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('No flashcards available to navigate.'),
          backgroundColor: Colors.redAccent,
          duration: const Duration(seconds: 2),
          action: SnackBarAction(
            label: 'OK',
            textColor: Colors.white,
            onPressed: () {
              // Optional: Handle additional actions on press if needed
            },
          ),
        ),
      );
      return;
    }

    // Clear any displayed media or states in a concise way
    ref.read(displayedMediaProvider.notifier).state = null;
    ref.read(isMediaShownProvider.notifier).state = false;

    // Calculate the next flashcard index and update the current flashcard index
    final nextIndex = (currentFlashcardIndex + 1) % flashcards.length;
    ref.read(currentFlashcardIndexProvider.notifier).state = nextIndex;

    // Provide smooth user feedback with a customized SnackBar
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Center(
          child: Text(
            'Flashcard: ${nextIndex + 1} of ${flashcards.length}.',
            textAlign: TextAlign.center,  // Ensures the text is centered
          ),
        ),
        backgroundColor: Colors.blueGrey.shade700,
        duration: const Duration(seconds: 2),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),  // Rounded corners for the SnackBar
        ),
        behavior: SnackBarBehavior.floating,  // Floating SnackBar for modern UI
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10), // Added margin for spacing
      ),
    );
  }

  void toggleShuffle() {
    if (isShuffled) {
        ref
            .read(flashcardsProvider(flashcardSet).notifier)
            .restoreOriginalOrder();
      } else {
        ref
            .read (flashcardsProvider(flashcardSet).notifier)
            .shuffleFlashcards();
      }
      ref.read(isShuffledProvider.notifier).state = !isShuffled;
  }



    return WillPopScope(
      onWillPop: () async {
        ref.read(displayedMediaProvider.notifier).state = null;
        ref.read(isMediaShownProvider.notifier).state = false;
        ref.read(currentFlashcardIndexProvider.notifier).state = 0;
        return true;
      },
      child: Scaffold(
        backgroundColor: Colors.grey[200],
        appBar: AppBar(
          title: Text('Flashcards for ${flashcardSet.title}',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
          backgroundColor: Colors.grey[200],
        ),
        body: flashcards.isEmpty
            ? const Center(child: Text('No flashcards created yet.'))
            : Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    GestureDetector(
                      onTap: () {
                        ref.read(isShowingTermProvider.notifier).state =
                            !ref.read(isShowingTermProvider);
                        recordActivity(uid);
                      },
                      child: FlipCard(
                        front: Card(
                          elevation: 5,
                          margin: const EdgeInsets.all(16),
                          child: Container(
                            width: 1000, 
       
                            alignment: Alignment.center,
                            child: Padding(
                              padding: const EdgeInsets.all(30),
                              child: Column(
                                mainAxisSize: MainAxisSize.min, // Ensures column takes up minimal space
                                crossAxisAlignment: CrossAxisAlignment.center, // Centers content horizontally
                                children: [
                                  Text(
                                    flashcards[currentFlashcardIndex].term,
                                    style: GoogleFonts.poppins(fontSize: 24),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        back: Card(
                          elevation: 5,
                          margin: const EdgeInsets.all(16),
                          child: Container(
                            width: 1000, 
                            alignment: Alignment.center,
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                mainAxisSize: MainAxisSize.min, // Ensures column takes up minimal space
                                crossAxisAlignment: CrossAxisAlignment.center, // Centers content horizontally
                                children: [
                                  Text(
                                    flashcards[currentFlashcardIndex].definition,
                                    style: GoogleFonts.poppins(fontSize: 24),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 16), // Add space below the definition
                                ],
                              ),
                            ),
                          ),
                        ),
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
                          Row(
                            children: [
                              IconButton(
                                icon: Icon(
                                  isShuffled ? Icons.shuffle_on_outlined : Icons.shuffle,
                                  color: Colors.orange,
                                ),
                                onPressed: toggleShuffle,  // Call shuffle toggle
                              ),
                              IconButton(
                                icon: const Icon(Icons.edit, color: Colors.green),
                                onPressed: () => editFlashcard(currentFlashcardIndex),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                onPressed: () => deleteFlashcard(currentFlashcardIndex),
                              ),
                            ],
                          ),
                          IconButton(
                            icon: const Icon(Icons.arrow_forward, color: Colors.blue),
                            onPressed: navigateToNextFlashcard,
                          ),
                        ],
                      ),
                    ElevatedButton(
                      onPressed: () async {
                        final currentFlashcard = flashcards[currentFlashcardIndex];
                        final mediaExists =
                            await fetchMedia(flashcardSet.title, currentFlashcard.term) != null;

                        if (mediaExists) {
                          final isMediaShown = ref.read(isMediaShownProvider.notifier).state;
                          if (isMediaShown) {
                            ref.read(isMediaShownProvider.notifier).state = false;
                            ref.read(displayedMediaProvider.notifier).state = null;
                          } else {
                            fetchAndDisplayMedia(currentFlashcard.term);
                          }
                        } else {
                          showDialog(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                title: const Text('No Media'),
                                content: const Text('There is no media to show for this flashcard.'),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.of(context).pop(),
                                    child: const Text('OK'),
                                  ),
                                ],
                              );
                            },
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.grey,
                        disabledForegroundColor: ref.watch(isMediaShownProvider)
                            ? Colors.blue
                            : Colors.grey.withOpacity(0.38),
                        disabledBackgroundColor: ref.watch(isMediaShownProvider)
                            ? Colors.blue
                            : Colors.grey.withOpacity(0.12),
                      ),
                      child: Text(ref.watch(isMediaShownProvider) ? 'Hide Media' : 'Show Media'),
                    ),
                    if (ref.watch(isMediaShownProvider) &&
                        ref.watch(displayedMediaProvider) != null)
                      GestureDetector(
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                content: ref.watch(displayedMediaProvider)!.path.endsWith('.mp4')
                                    ? VideoPlayerWidget(
                                        file: ref.watch(displayedMediaProvider)!)
                                    : Image.file(
                                        ref.watch(displayedMediaProvider)!,
                                        fit: BoxFit.cover,
                                      ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.of(context).pop(),
                                    child: const Text('Close'),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: ref.watch(displayedMediaProvider)!.path.endsWith('.mp4')
                              ? SizedBox(
                                  height: 200,
                                  width: 200,
                                  child: VideoPlayerWidget(
                                      file: ref.watch(displayedMediaProvider)!),
                                )
                              : Image.file(
                                  ref.watch(displayedMediaProvider)!,
                                  height: 200,
                                  width: 200,
                                  fit: BoxFit.cover,
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
        floatingActionButton: FloatingActionButton(
          onPressed: addFlashcard,
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}