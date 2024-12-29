import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../constants/game_constants.dart';
import '../services/dictionary_service.dart';
import '../services/scoring_engine.dart';
import '../models/game_state.dart';

class GameManager {
  // Game state
  final GameState gameState;
  final Random random = Random();
  final DictionaryService dictionaryService = DictionaryService();
  bool hasSubmittedWord = false;
  
  // Score and timing
  int score = 0;
  int roundScore = 0;
  int timeLeft = GameConstants.roundTimeSeconds;
  int level = 1;
  
  // Round stats
  String bestWord = '';
  int bestWordScore = 0;
  
  // Timers
  Timer? spawnTimer;
  Timer? gameTimer;
  Timer? checkTimer;
  Timer? initialSpawnTimer;
  
  // Game area size
  Size? _gameAreaSize;
  
  // Target letter count
  int _targetLetterCount = GameConstants.minSpawnedLetters;
  int _currentLetterCount = 0;
  
  // Callbacks
  final Function(int) onScoreChanged;
  final Function(int) onLevelChanged;
  final Function(int) onTimeChanged;
  final void Function(String, Offset, bool) onLetterSpawned;
  final VoidCallback? onGameOver;
  final Function(int, String, int, int)? onRoundComplete;
  
  GameManager({
    required this.gameState,
    required this.onScoreChanged,
    required this.onLevelChanged,
    required this.onTimeChanged,
    required this.onLetterSpawned,
    this.onGameOver,
    this.onRoundComplete,
  });

  void initializeGrid(Size screenSize, double headerHeight, double bottomPanelHeight) {
    _gameAreaSize = Size(
      screenSize.width,
      screenSize.height - headerHeight - bottomPanelHeight,
    );
    
    // Start initial spawn
    startInitialSpawn();
  }

  void startInitialSpawn() {
    _currentLetterCount = 0;
    _targetLetterCount = _getRandomTargetCount();
    
    // Spawn initial letters with staggered timing
    for (var i = 0; i < _targetLetterCount; i++) {
      Future.delayed(Duration(milliseconds: i * 200), () {
        if (_currentLetterCount < _targetLetterCount) {
          spawnLetter();
          _currentLetterCount++;
          
          // Start continuous spawning after all initial letters are spawned
          if (_currentLetterCount >= _targetLetterCount) {
            startSpawning();
          }
        }
      });
    }
  }

  int _getRandomTargetCount() {
    // Return random number between 8-12
    return 8 + random.nextInt(5);
  }

  void startGame() {
    timeLeft = GameConstants.roundTimeSeconds;
    hasSubmittedWord = false;
    roundScore = 0;
    bestWord = '';
    bestWordScore = 0;
    startGameTimer();
  }

  void startGameTimer() {
    gameTimer?.cancel();
    gameTimer = Timer.periodic(
      const Duration(seconds: 1),
      (timer) {
        timeLeft--;
        onTimeChanged(timeLeft);
        if (timeLeft <= 0) {
          timer.cancel();
          if (!hasSubmittedWord) {
            // Game over - no words submitted in time
            endGame();
          } else {
            // Round complete
            onRoundComplete?.call(roundScore, bestWord, bestWordScore, level + 1);
          }
        }
      },
    );
  }

  void startNextRound() {
    // Stop all timers
    spawnTimer?.cancel();
    gameTimer?.cancel();
    
    // Reset round state
    level++;
    onLevelChanged(level);
    timeLeft = GameConstants.roundTimeSeconds;
    hasSubmittedWord = false;
    roundScore = 0;
    bestWord = '';
    bestWordScore = 0;
    _currentLetterCount = 0;
    
    // Start new round
    startInitialSpawn();
    startGameTimer();
  }

  void endGame() {
    spawnTimer?.cancel();
    gameTimer?.cancel();
    initialSpawnTimer?.cancel();
    onGameOver?.call();
  }

  void startSpawning() {
    spawnTimer?.cancel();
    spawnTimer = Timer.periodic(
      const Duration(milliseconds: GameConstants.spawnIntervalMs),
      (timer) {
        // Update target count randomly
        _targetLetterCount = _getRandomTargetCount();
        
        // Spawn new letters if needed
        final lettersNeeded = _targetLetterCount - _currentLetterCount;
        if (lettersNeeded > 0) {
          spawnLetter();
          _currentLetterCount++;
        }
      },
    );
  }

  Offset _getRandomPosition() {
    if (_gameAreaSize == null) return Offset.zero;
    
    final margin = GameConstants.letterSize;
    return Offset(
      margin + random.nextDouble() * (_gameAreaSize!.width - margin * 2),
      margin + random.nextDouble() * (_gameAreaSize!.height - margin * 2),
    );
  }

  void spawnLetter() {
    if (_gameAreaSize == null) return;
    
    final letter = _getRandomWeightedLetter();
    final position = _getRandomPosition();
    // 10% chance for bonus letter
    final isBonus = random.nextDouble() < 0.10;
    onLetterSpawned(letter, position, isBonus);
  }

  String _getRandomWeightedLetter() {
    final List<String> weightedLetters = [];
    GameConstants.letterPool.forEach((letter, weight) {
      for (int i = 0; i < weight; i++) {
        weightedLetters.add(letter);
      }
    });
    return weightedLetters[random.nextInt(weightedLetters.length)];
  }

  void onLetterCollected() {
    _handleLetterRemoval();
  }

  void onLetterExpired() {
    _handleLetterRemoval();
  }

  void _handleLetterRemoval() {
    _currentLetterCount--;
    
    // Update target count randomly
    _targetLetterCount = _getRandomTargetCount();
    
    // Spawn new letters if needed
    final lettersNeeded = _targetLetterCount - _currentLetterCount;
    if (lettersNeeded > 0) {
      // Add slight delay before spawning new letter
      Future.delayed(const Duration(milliseconds: 300), () {
        spawnLetter();
        _currentLetterCount++;
      });
    }
  }

  Future<bool> submitWord() async {
    final letters = gameState.collectedLetters.value;
    final bonuses = gameState.bonusLetters.value;
    if (letters.isEmpty) return false;
    
    final word = letters.join().toUpperCase();
    if (word.length < GameConstants.minWordLength) return false;

    final isValid = await dictionaryService.isValidWord(word);
    if (!isValid) {
      // Game over - invalid word
      endGame();
      return false;
    }

    // Calculate score using scoring engine with bonus letters
    final points = ScoringEngine.calculateWordScore(word, bonusLetters: bonuses);
    score += points;
    roundScore += points;
    
    // Update best word if needed
    if (points > bestWordScore) {
      bestWord = word;
      bestWordScore = points;
    }
    
    gameState.clearCollectedLetters();
    hasSubmittedWord = true;
    
    onScoreChanged(score);
    
    return true;
  }

  void dispose() {
    spawnTimer?.cancel();
    gameTimer?.cancel();
    initialSpawnTimer?.cancel();
  }
}
