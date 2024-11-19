import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models.dart';

class SubjectsNotifier extends StateNotifier<List<Subject>> {
  SubjectsNotifier() : super([]);

  void addSubject(String title) {
    state = [...state, Subject(title)];
  }

  void editSubject(int index, String newTitle) {
    final updatedSubjects = List<Subject>.from(state);
    updatedSubjects[index].title = newTitle;
    state = updatedSubjects;
  }

  void deleteSubject(int index) {
    final updatedSubjects = List<Subject>.from(state)..removeAt(index);
    state = updatedSubjects;
  }
}

final subjectsProvider = StateNotifierProvider<SubjectsNotifier, List<Subject>>(
  (ref) => SubjectsNotifier(),
);
