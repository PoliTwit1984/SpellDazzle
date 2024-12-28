import 'package:flutter/services.dart';
import '../constants/game_constants.dart';

class DictionaryService {
  Set<String> _dictionary = {};
  bool _isInitialized = false;

  Future<void> initialize() async {
    if (_isInitialized) return;

    final String wordsString = await rootBundle.loadString('assets/words_alpha.txt');
    _dictionary = Set.from(wordsString.split('\n').map((w) => w.trim().toUpperCase()));
    _dictionary.addAll(GameConstants.additionalWords);
    _isInitialized = true;
  }

  Future<bool> isValidWord(String word) async {
    if (!_isInitialized) await initialize();
    return _dictionary.contains(word.toUpperCase());
  }
}
