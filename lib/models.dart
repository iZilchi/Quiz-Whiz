class Flashcard {
  String term;
  String definition;

  Flashcard(this.term, this.definition);
}

class FlashcardSet {
  String title;
  List<Flashcard> flashcards;

  FlashcardSet(this.title) : flashcards = [];
}

class Subject {
  String title;
  List<FlashcardSet> flashcardSets;

  Subject(this.title) : flashcardSets = [];
}
