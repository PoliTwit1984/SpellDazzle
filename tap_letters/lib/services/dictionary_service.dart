import 'dart:async';
import 'package:flutter/services.dart';

class DictionaryService {
  static final DictionaryService _instance = DictionaryService._internal();
  Set<String> _dictionary = {};
  bool _isInitialized = false;

  factory DictionaryService() {
    return _instance;
  }

  DictionaryService._internal();

  Future<void> initialize() async {
    if (_isInitialized) return;

    // Load dictionary file
    final String content = await rootBundle.loadString('assets/words_alpha.txt');
    _dictionary = content.split('\n').map((word) => word.trim().toUpperCase()).toSet();
    _isInitialized = true;
  }

  Future<bool> isValidWord(String word) async {
    if (!_isInitialized) {
      await initialize();
    }
    return _dictionary.contains(word.trim().toUpperCase());
  }
}
