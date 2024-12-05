import '../models.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  //ACCOUNT CREATE USERNAME
  // Create or initialize a user document
  Future<void> initializeUser(String uid, String email) async {
    try {
      final userDoc = _db.collection('users').doc(uid);
      final docSnapshot = await userDoc.get();

      if (!docSnapshot.exists) {
        // Create a new user document with default fields
        await userDoc.set({
          'email': email,
          'username': 'guest', // Default username
        });
      }
    } catch (e) {
      throw Exception('Error initializing user: $e');
    }
  }
  
  //ACCOUNT UPDATE
  Future<void> updateUsername(String uid, String newUsername) async {
    try {
      final userDoc = _db.collection('users').doc(uid);
      final docSnapshot = await userDoc.get();

      if (docSnapshot.exists) {
        await userDoc.update({'username': newUsername});
      } else {
        throw Exception('User document does not exist.');
      }
    } catch (e) {
      throw Exception('Error updating username: $e');
    }
  }

  // READ ACCOUNT USERNAME AND EMAIL
  Future<Map<String, String>> getUserDetails(String uid) async {
    try {
      final userDoc = await _db.collection('users').doc(uid).get();

      if (userDoc.exists) {
        final data = userDoc.data()!;
        return {
          'username': data['username'] ?? 'guest',
          'email': data['email'] ?? 'No email available',
        };
      } else {
        throw Exception('User document does not exist.');
      }
    } catch (e) {
      throw Exception('Error retrieving user details: $e');
    }
  }
  

  
  // SUBJECT CRUD

  // CREATE
  Future<void> addSubject(String uid, Subject subject) async {
    await _db.collection('subjects').add({
      'title': subject.title,
      'uid': uid, // Associate with user ID
    });
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
  Stream<List<Subject>> getSubjects(String uid) {
  return _db
      .collection('subjects')
      .where('uid', isEqualTo: uid) // Filter by user ID
      .snapshots()
      .map((snapshot) => snapshot.docs.map((doc) {
            final data = doc.data();
            return Subject(data['title'], doc.id);
          }).toList());
}

  // FLASHCARD SET CRUD

  // CREATE
  Future<void> addFlashcardSet(String uid, String subjectId, FlashcardSet flashcardSet) async {
    await _db
        .collection('subjects')
        .doc(subjectId)
        .collection('flashcardSets')
        .add({
      'title': flashcardSet.title,
      'uid': uid, // Associate with user ID
    });
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
  Stream<List<FlashcardSet>> getFlashcardSets(String uid, String subjectId) {
    return _db
        .collection('subjects')
        .doc(subjectId)
        .collection('flashcardSets')
        .where('uid', isEqualTo: uid) // Filter by user ID
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
  Future<void> addFlashcard(String uid, String subjectId, String flashcardSetId, Flashcard flashcard) async {
    await _db
        .collection('subjects')
        .doc(subjectId)
        .collection('flashcardSets')
        .doc(flashcardSetId)
        .collection('flashcards')
        .add({
      'term': flashcard.term,
      'definition': flashcard.definition,
      'uid': uid, // Associate with user ID
    });
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
  Stream<List<Flashcard>> getFlashcards(String uid, String subjectId, String flashcardSetId) {
    return _db
        .collection('subjects')
        .doc(subjectId)
        .collection('flashcardSets')
        .doc(flashcardSetId)
        .collection('flashcards')
        .where('uid', isEqualTo: uid) // Filter by user ID
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
              final data = doc.data();
              return Flashcard(data['term'], data['definition'], doc.id);
            }).toList());
  }

  //SEARCH FUNCTION
  //SEARCH FOR SUBJECT OR FLASHCARD SET
  Future<List<dynamic>> searchData(String uid, String query) async {
    final List<dynamic> results = [];

    try {
      // Search in subjects
      final subjectsSnapshot = await _db
          .collection('subjects')
          .where('uid', isEqualTo: uid)
          .where('title', isGreaterThanOrEqualTo: query)
          .where('title', isLessThanOrEqualTo: query + '\uf8ff')
          .get();

      results.addAll(subjectsSnapshot.docs.map((doc) => Subject(doc['title'], doc.id)));

      // Search in flashcard sets
      final flashcardSetsSnapshot = await _db
          .collectionGroup('flashcardSets')
          .where('uid', isEqualTo: uid)
          .where('title', isGreaterThanOrEqualTo: query)
          .where('title', isLessThanOrEqualTo: query + '\uf8ff')
          .get();

      results.addAll(flashcardSetsSnapshot.docs.map((doc) => FlashcardSet(doc['title'], doc.id, doc.reference.parent.parent!.id)));

    } catch (e) {
      throw Exception('Error during search: $e');
    }

    return results;
  }
}