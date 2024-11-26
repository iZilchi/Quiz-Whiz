class Flashcard {
  String term;
  String definition;
  String documentId;
  String? mediaUrl;

  Flashcard(this.term, this.definition, this.documentId, {this.mediaUrl});
}


class FlashcardSet {
  String title;
  String documentId;
  String flashcardSetSubjectId;
  List<Flashcard> flashcards;

  FlashcardSet(this.title, this.documentId, this.flashcardSetSubjectId) : flashcards = [];
}

class Subject {
  String title;
  String documentId;  // Added documentId to track Firestore document ID
  List<FlashcardSet> flashcardSets;

  Subject(this.title, this.documentId) : flashcardSets = [];
}
