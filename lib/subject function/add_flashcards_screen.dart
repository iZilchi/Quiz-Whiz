import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_player/video_player.dart';
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
  bool _isError = false;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.file(widget.file)
      ..initialize().then((_) {
        if (mounted) {
          setState(() {});
          _controller.play();
        }
      }).catchError((error) {
        print("Error initializing video player: $error");
        setState(() {
          _isError = true;
        });
      });
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
    return _controller.value.isInitialized
        ? AspectRatio(
            aspectRatio: _controller.value.aspectRatio,
            child: VideoPlayer(_controller),
          )
        : const Center(child: CircularProgressIndicator());
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
      return Scaffold(
        body: const Center(child: Text("User  not authenticated")),
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
                    child: _mediaFile!.path.endsWith('.mp4')
                        ? Container(
                            height: 150,
                            width: 150,
                            child: VideoPlayerWidget(file: File(_mediaFile!.path)),
                          )
                        : Image.file(
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
                      if (localPath != null) mediaPath = localPath;
                    }

                    ref
                        .read(flashcardsProvider(flashcardSet).notifier)
                        .addFlashcard(term, definition, mediaUrl: mediaPath, uid: uid);
                    
                    ref.read(displayedMediaProvider.notifier).state = null;
                    ref.read(isMediaShownProvider.notifier).state = false;

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
      TextEditingController termController = TextEditingController(text: flashcard.term);
      TextEditingController definitionController = TextEditingController(text: flashcard.definition);

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
                  final updatedDefinition = definitionController.text.trim();

                  if (updatedTerm.isNotEmpty && updatedDefinition.isNotEmpty) {
                    ref.read(displayedMediaProvider.notifier).state = null;
                    ref.read(isMediaShownProvider.notifier).state = false;

                    final oldTerm = flashcard.term;
                    final flashcardSetName = flashcardSet.title;

                    File? oldImageFile = await fetchMedia(flashcardSetName, oldTerm);

                    await createFlashcardFolder(updatedTerm, flashcardSetName);

                    if (oldImageFile != null) {
                      try {
                        final newImagePath = '${(await getApplicationDocumentsDirectory()).path}/$uid/$flashcardSetName/$updatedTerm/${oldImageFile.uri.pathSegments.last}';
                        await oldImageFile.copy(newImagePath);
                        print("Image moved to: $newImagePath");
                      } catch (e) {
                        print("Error moving image: $e");
                      }
                    }

                    await deleteFlashcardFolder(oldTerm, flashcardSetName);

                    ref.read(flashcardsProvider(flashcardSet).notifier)
                        .editFlashcard(flashcard.documentId, updatedTerm, updatedDefinition);
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

        ref.read(displayedMediaProvider.notifier).state = null;
        ref.read(isMediaShownProvider.notifier).state = false;

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
        ref.read(displayedMediaProvider.notifier).state = null;
        ref.read(isMediaShownProvider.notifier).state = false;
        ref.read(currentFlashcardIndexProvider.notifier).state =
            (currentFlashcardIndex - 1 + flashcards.length) % flashcards.length;
      }
    }

    void navigateToNextFlashcard() {
      if (flashcards.isNotEmpty) {
        ref.read(displayedMediaProvider.notifier).state = null;
        ref.read(isMediaShownProvider.notifier).state = false;

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
          title: Text('Flashcards for ${flashcardSet.title}'),
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
                        print("isShowingTerm toggled: ${ref.read(isShowingTermProvider)}");
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
                            ],
                          ),
                        ),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        final currentFlashcard = flashcards[currentFlashcardIndex];
                        final mediaExists = await fetchMedia(flashcardSet.title, currentFlashcard.term) != null;

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
                      child: Text(ref.watch(isMediaShownProvider) ? 'Hide Media' : 'Show Media'),
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.grey,
                        disabledForegroundColor: ref.watch(isMediaShownProvider) ? Colors.blue : Colors.grey.withOpacity(0.38),
                        disabledBackgroundColor: ref.watch(isMediaShownProvider) ? Colors.blue : Colors.grey.withOpacity(0.12),
                      ),
                    ),
                    if (ref.watch(isMediaShownProvider) && ref.watch(displayedMediaProvider) != null)
                      GestureDetector(
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                content: ref.watch(displayedMediaProvider)!.path.endsWith('.mp4')
                                    ? VideoPlayerWidget(file: ref.watch(displayedMediaProvider)! )
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
                              ? Container(
                                  height: 200,
                                  width: 200,
                                  child: VideoPlayerWidget(file: ref.watch(displayedMediaProvider)!),
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