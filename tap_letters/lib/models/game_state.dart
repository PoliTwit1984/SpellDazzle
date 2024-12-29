import 'package:flutter/foundation.dart';

class GameState {
  // Score
  final ValueNotifier<int> score = ValueNotifier(0);
  final ValueNotifier<int> level = ValueNotifier(1);
  final ValueNotifier<int> timeLeft = ValueNotifier(30);
  
  // Letters
  final ValueNotifier<List<String>> collectedLetters = ValueNotifier([]);
  
  void updateScore(int newScore) {
    score.value = newScore;
  }
  
  void updateLevel(int newLevel) {
    level.value = newLevel;
  }
  
  void updateTimeLeft(int newTime) {
    timeLeft.value = newTime;
  }
  
  void addCollectedLetter(String letter) {
    final letters = List<String>.from(collectedLetters.value);
    letters.add(letter);
    collectedLetters.value = letters;
  }
  
  void removeCollectedLetter(int index) {
    final letters = List<String>.from(collectedLetters.value);
    letters.removeAt(index);
    collectedLetters.value = letters;
  }
  
  void reorderCollectedLetters(int oldIndex, int newIndex) {
    final letters = List<String>.from(collectedLetters.value);
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }
    final letter = letters.removeAt(oldIndex);
    letters.insert(newIndex, letter);
    collectedLetters.value = letters;
  }
  
  void clearCollectedLetters() {
    collectedLetters.value = [];
  }
  
  void dispose() {
    score.dispose();
    level.dispose();
    timeLeft.dispose();
    collectedLetters.dispose();
  }
}
