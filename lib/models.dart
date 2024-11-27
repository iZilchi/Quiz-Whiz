class Flashcard {
  final String term;
  final String definition;
  final String documentId;
  final String? imageUrl;

  Flashcard(this.term, this.definition, this.documentId, {this.imageUrl});
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
  String documentId;
  List<FlashcardSet> flashcardSets;

  Subject(this.title, this.documentId) : flashcardSets = [];
}
