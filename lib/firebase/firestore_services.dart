import '../models.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // SUBJECT CRUD

  // CREATE
  Future<void> addSubject(Subject subject) async {
    await _db.collection('subjects').add({'title': subject.title});
  }

  // DELETE
  Future<void> deleteSubject(String subjectId) async {
    await _db.collection('subjects').doc(subjectId).delete();
  }

  // UPDATE
  Future<void> updateSubject(String subjectId, String newTitle) async {
    await _db.collection('subjects').doc(subjectId).update({'title': newTitle});
  }

  // READ
  Stream<List<Subject>> getSubjects() {
    return _db.collection('subjects').snapshots().map((snapshot) => snapshot.docs.map((doc) {
      final data = doc.data();
      return Subject(data['title'], doc.id); // Store document ID along with title
    }).toList());
  }

  // FLASHCARD SET CRUD

  // CREATE
  Future<void> addFlashcardSet(String subjectId, FlashcardSet flashcardSet) async {
    await _db
        .collection('subjects')
        .doc(subjectId)
        .collection('flashcardSets')
        .add({'title': flashcardSet.title});
  }

  // DELETE
  Future<void> deleteFlashcardSet(String subjectId, String flashcardSetId) async {
    await _db
        .collection('subjects')
        .doc(subjectId)
        .collection('flashcardSets')
        .doc(flashcardSetId)
        .delete();
  }

  // UPDATE
  Future<void> updateFlashcardSet(String subjectId, String flashcardSetId, String newTitle) async {
    await _db
        .collection('subjects')
        .doc(subjectId)
        .collection('flashcardSets')
        .doc(flashcardSetId)
        .update({'title': newTitle});
  }

  // READ
  Stream<List<FlashcardSet>> getFlashcardSets(String subjectId) {
  return _db
      .collection('subjects')
      .doc(subjectId)
      .collection('flashcardSets')
      .snapshots()
      .map((snapshot) => snapshot.docs.map((doc) {
            final data = doc.data();
            return FlashcardSet(
              data['title'],         // Title of the flashcard set
              doc.id,                // Document ID of the flashcard set
              subjectId,             // The subjectId associated with this flashcard set
            );
          }).toList());
}

  // FLASHCARD CRUD

  // CREATE
  Future<void> addFlashcard(String subjectId, String flashcardSetId, Flashcard flashcard) async {
    await _db
        .collection('subjects')
        .doc(subjectId)
        .collection('flashcardSets')
        .doc(flashcardSetId)
        .collection('flashcards')
        .add({'term': flashcard.term, 'definition': flashcard.definition});
  }

  // DELETE
  Future<void> deleteFlashcard(String subjectId, String flashcardSetId, String flashcardId) async {
    await _db
        .collection('subjects')
        .doc(subjectId)
        .collection('flashcardSets')
        .doc(flashcardSetId)
        .collection('flashcards')
        .doc(flashcardId)
        .delete();
  }

  // UPDATE
  Future<void> updateFlashcard(
    String subjectId,
    String flashcardSetId,
    String flashcardId,
    String newTerm,
    String newDefinition,
  ) async {
    await _db
        .collection('subjects')
        .doc(subjectId)
        .collection('flashcardSets')
        .doc(flashcardSetId)
        .collection('flashcards')
        .doc(flashcardId)
        .update({'term': newTerm, 'definition': newDefinition});
  }

  // READ
  Stream<List<Flashcard>> getFlashcards(String subjectId, String flashcardSetId) {
    return _db
        .collection('subjects')
        .doc(subjectId)
        .collection('flashcardSets')
        .doc(flashcardSetId)
        .collection('flashcards')
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
              final data = doc.data();
              return Flashcard(data['term'], data['definition'], doc.id);
            }).toList());
  }
}