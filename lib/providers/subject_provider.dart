import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models.dart';
import '../firebase/firestore_services.dart'; // Import FirestoreService

class SubjectsNotifier extends StateNotifier<List<Subject>> {
  final FirestoreService _firestoreService = FirestoreService();

  SubjectsNotifier() : super([]) {
    // Initialize subjects from Firestore
    _initializeSubjects();
  }

  // READ subjects from Firestore
  Future<void> _initializeSubjects() async {
    _firestoreService.getSubjects().listen((subjects) {
      state = subjects;
    });
  }

  // CREATE a new subject
  Future<void> addSubject(String title) async {
    final newSubject = Subject(title, ''); // documentId will be assigned by Firestore
    state = [...state, newSubject]; // Optimistic update
    await _firestoreService.addSubject(newSubject);
  }

  // UPDATE an existing subject
  Future<void> editSubject(int index, String newTitle) async {
    final subjectId = state[index].documentId; // Use the document ID for update
    final updatedSubjects = List<Subject>.from(state);
    updatedSubjects[index].title = newTitle;

    state = updatedSubjects; // Optimistic update
    await _firestoreService.updateSubject(subjectId, newTitle);
  }

  // DELETE a subject
  Future<void> deleteSubject(int index) async {
    final subjectId = state[index].documentId; // Use the document ID for deletion
    final updatedSubjects = List<Subject>.from(state)..removeAt(index);

    state = updatedSubjects; // Optimistic update
    await _firestoreService.deleteSubject(subjectId);
  }
}

final subjectsProvider = StateNotifierProvider<SubjectsNotifier, List<Subject>>(
  (ref) => SubjectsNotifier(),
);