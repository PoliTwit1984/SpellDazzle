import 'package:flutter/foundation.dart';

class GameState {
  // Score
  final ValueNotifier<int> score = ValueNotifier(0);
  final ValueNotifier<int> level = ValueNotifier(1);
  final ValueNotifier<int> timeLeft = ValueNotifier(30);
  
  // Letters
  final ValueNotifier<List<String>> collectedLetters = ValueNotifier([]);
  final ValueNotifier<List<bool>> bonusLetters = ValueNotifier([]);
  
  void updateScore(int newScore) {
    score.value = newScore;
  }
  
  void updateLevel(int newLevel) {
    level.value = newLevel;
  }
  
  void updateTimeLeft(int newTime) {
    timeLeft.value = newTime;
  }
  
  void addCollectedLetter(String letter, {bool isBonus = false}) {
    final letters = List<String>.from(collectedLetters.value);
    final bonuses = List<bool>.from(bonusLetters.value);
    letters.add(letter);
    bonuses.add(isBonus);
    collectedLetters.value = letters;
    bonusLetters.value = bonuses;
  }
  
  void removeCollectedLetter(int index) {
    final letters = List<String>.from(collectedLetters.value);
    final bonuses = List<bool>.from(bonusLetters.value);
    letters.removeAt(index);
    bonuses.removeAt(index);
    collectedLetters.value = letters;
    bonusLetters.value = bonuses;
  }
  
  void reorderCollectedLetters(int oldIndex, int newIndex) {
    final letters = List<String>.from(collectedLetters.value);
    final bonuses = List<bool>.from(bonusLetters.value);
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }
    final letter = letters.removeAt(oldIndex);
    final isBonus = bonuses.removeAt(oldIndex);
    letters.insert(newIndex, letter);
    bonuses.insert(newIndex, isBonus);
    collectedLetters.value = letters;
    bonusLetters.value = bonuses;
  }
  
  void clearCollectedLetters() {
    collectedLetters.value = [];
    bonusLetters.value = [];
  }
  
  void dispose() {
    score.dispose();
    level.dispose();
    timeLeft.dispose();
    collectedLetters.dispose();
    bonusLetters.dispose();
  }
}
