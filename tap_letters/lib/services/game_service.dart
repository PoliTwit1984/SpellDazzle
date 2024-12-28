import 'dart:math';
import '../constants/game_constants.dart';
import 'dictionary_service.dart';

class GameService {
  final Random _random = Random();
  final DictionaryService _dictionaryService = DictionaryService();
  DateTime? _lastWordTime;

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

  double calculateLengthBonus(int wordLength) {
    if (wordLength >= 5) return GameConstants.fiveLetterBonus.toDouble();
    if (wordLength >= 4) return GameConstants.fourLetterBonus.toDouble();
    return 0.0;
  }

  double calculateSpeedBonus() {
    if (_lastWordTime == null) {
      _lastWordTime = DateTime.now();
      return 0.0;
    }

    final now = DateTime.now();
    final timeDiff = now.difference(_lastWordTime!).inSeconds;
    _lastWordTime = now;

    if (timeDiff > GameConstants.speedBonusTimeWindow) return 0.0;

    return (GameConstants.speedBonusTimeWindow - timeDiff) / 
           GameConstants.speedBonusTimeWindow * 
           GameConstants.speedBonusMax;
  }
}
