import 'dart:math';
import '../constants/game_constants.dart';
import 'dictionary_service.dart';

class GameService {
  final Random _random = Random();
  final DictionaryService _dictionaryService = DictionaryService();

  Future<void> initialize() async {
    await _dictionaryService.initialize();
  }

  String getRandomLetter() {
    final List<String> weightedLetters = [];
    GameConstants.letterPool.forEach((letter, weight) {
      for (int i = 0; i < weight; i++) {
        weightedLetters.add(letter);
      }
    });
    return weightedLetters[_random.nextInt(weightedLetters.length)];
  }

  Future<bool> isValidWord(String word) async {
    return await _dictionaryService.isValidWord(word);
  }
}
