import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../constants/game_constants.dart';
import '../models/spawned_letter.dart';
import '../services/dictionary_service.dart';
import '../widgets/game/bottom_panel.dart';
import '../widgets/game/letter_tile.dart';
import '../widgets/animations/reward_animations.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  final List<SpawnedLetter> _spawnedLetters = [];
  final List<String> _collectedLetters = [];
  final Random _random = Random();
  Timer? _spawnTimer;
  Timer? _gameTimer;
  int _score = 0;
  int _timeLeft = GameConstants.roundTimeSeconds;
  int _level = 1;
  final DictionaryService _dictionaryService = DictionaryService();
  final List<Offset> _gridPositions = [];
  final List<bool> _gridOccupied = [];
  DateTime? _lastWordTime;
  final GlobalKey _scoreKey = GlobalKey();
  bool _showScoreAnimation = false;
  Offset? _lastWordPosition;
  int _lastPoints = 0;
  double _lastMultiplier = 1.0;

  @override
  void initState() {
    super.initState();
    _initializeGrid();
    _startGame();
  }

  @override
  void dispose() {
    _spawnTimer?.cancel();
    _gameTimer?.cancel();
    super.dispose();
  }

  void _initializeGrid() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final screenWidth = MediaQuery.of(context).size.width;
      final screenHeight = MediaQuery.of(context).size.height;
      final startX = (screenWidth - (GameConstants.gridColumns * (GameConstants.letterSize + GameConstants.gridSpacing))) / 2;
      final startY = 120.0;

      for (int row = 0; row < GameConstants.gridRows; row++) {
        for (int col = 0; col < GameConstants.gridColumns; col++) {
          final x = startX + col * (GameConstants.letterSize + GameConstants.gridSpacing);
          final y = startY + row * (GameConstants.letterSize + GameConstants.gridSpacing);
          if (y + GameConstants.letterSize < screenHeight - 200) {
            _gridPositions.add(Offset(x, y));
            _gridOccupied.add(false);
          }
        }
      }
    });
  }

  void _startGame() {
    _startSpawning();
    _startGameTimer();
  }

  void _startGameTimer() {
    _gameTimer?.cancel();
    _timeLeft = GameConstants.roundTimeSeconds;
    _gameTimer = Timer.periodic(
      const Duration(seconds: 1),
      (timer) {
        setState(() {
          if (_timeLeft > 0) {
            _timeLeft--;
          } else {
            _endGame();
          }
        });
      },
    );
  }

  void _endGame() {
    _spawnTimer?.cancel();
    _gameTimer?.cancel();
    // TODO: Show game over overlay
  }

  void _startSpawning() {
    _spawnTimer?.cancel();
    _spawnTimer = Timer.periodic(
      Duration(milliseconds: GameConstants.spawnIntervalMs),
      (timer) {
        if (_spawnedLetters.length < GameConstants.maxSpawnedLetters) {
          _spawnLetter();
        }
      },
    );
  }

  void _spawnLetter() {
    final position = _getAvailableGridPosition();
    if (position != null) {
      final gridIndex = _gridPositions.indexOf(position);
      final letter = _getRandomWeightedLetter();
      
      setState(() {
        _spawnedLetters.add(
          SpawnedLetter(
            letter: letter,
            position: position,
          ),
        );
        _gridOccupied[gridIndex] = true;

        Future.delayed(Duration(seconds: GameConstants.letterLifetimeSeconds), () {
          setState(() {
            _spawnedLetters.removeWhere((l) => l.position == position);
            _gridOccupied[gridIndex] = false;
          });
        });
      });
    }
  }

  String _getRandomWeightedLetter() {
    final List<String> weightedLetters = [];
    GameConstants.letterPool.forEach((letter, weight) {
      for (int i = 0; i < weight; i++) {
        weightedLetters.add(letter);
      }
    });
    return weightedLetters[_random.nextInt(weightedLetters.length)];
  }

  Offset? _getAvailableGridPosition() {
    if (_gridPositions.isEmpty) return null;

    final availableIndices = List<int>.generate(_gridOccupied.length, (i) => i)
        .where((i) => !_gridOccupied[i])
        .toList();

    if (availableIndices.isEmpty) return null;

    final randomIndex = availableIndices[_random.nextInt(availableIndices.length)];
    return _gridPositions[randomIndex];
  }

  void _onLetterTapped(SpawnedLetter letter) {
    if (_collectedLetters.length < GameConstants.maxCollectedLetters) {
      final gridIndex = _gridPositions.indexOf(letter.position);
      setState(() {
        _spawnedLetters.remove(letter);
        if (gridIndex != -1) {
          _gridOccupied[gridIndex] = false;
        }
        _collectedLetters.add(letter.letter);
      });
    }
  }

  void _onClearLetters() {
    setState(() {
      _collectedLetters.clear();
    });
  }

  void _onReorderLetters(int oldIndex, int newIndex) {
    setState(() {
      if (oldIndex < newIndex) {
        newIndex -= 1;
      }
      final letter = _collectedLetters.removeAt(oldIndex);
      _collectedLetters.insert(newIndex, letter);
    });
  }

  void _onLetterRemoved(String letter, int index) {
    setState(() {
      _collectedLetters.removeAt(index);
    });
  }

  double _calculateSpeedBonus() {
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

  void _onSubmitWord() async {
    final word = _collectedLetters.join();
    if (word.length < GameConstants.minWordLength) return;

    final isValid = await _dictionaryService.isValidWord(word);

    if (isValid) {
      // Calculate score with bonuses
      double baseScore = word.length.toDouble();
      double multiplier = 1.0;
      
      // Length bonus
      if (word.length >= 5) {
        multiplier = GameConstants.fiveLetterBonus;
      } else if (word.length == 4) {
        multiplier = GameConstants.fourLetterBonus;
      }

      // Speed bonus
      final speedBonus = _calculateSpeedBonus();
      multiplier += speedBonus;

      final points = (baseScore * multiplier).round();

      // Calculate center position of collected letters for animation
      final RenderBox box = context.findRenderObject() as RenderBox;
      final bottomPanelPosition = box.localToGlobal(Offset.zero);
      _lastWordPosition = Offset(
        bottomPanelPosition.dx + box.size.width / 2,
        bottomPanelPosition.dy + box.size.height / 2,
      );
      
      setState(() {
        _score += points;
        _lastPoints = points;
        _lastMultiplier = multiplier;
        _showScoreAnimation = true;
        _collectedLetters.clear();
        _level++;
        _startGameTimer(); // Reset timer for next level
      });

      // Reset animation flag after animation completes
      Future.delayed(const Duration(milliseconds: 1200), () {
        if (mounted) {
          setState(() {
            _showScoreAnimation = false;
          });
        }
      });
    } else {
      _endGame();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isTimeLow = _timeLeft <= GameConstants.lowTimeThreshold;

    return Scaffold(
      body: RewardAnimations(
        child: Stack(
          children: [
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF00C6FF),
                    Color(0xFF0072FF),
                  ],
                ),
              ),
            ),
            SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Level $_level',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Container(
                        key: _scoreKey,
                        child: Text(
                          'Score: $_score',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: isTimeLow ? Colors.red.withOpacity(0.3) : Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '$_timeLeft',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: isTimeLow ? Colors.red : Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Stack(
                    children: [
                      for (final letter in _spawnedLetters)
                        LetterTile(
                          key: ValueKey(letter),
                          letter: letter,
                          onTap: () => _onLetterTapped(letter),
                        ),
                    ],
                  ),
                ),
                BottomPanel(
                  letters: _collectedLetters,
                  onClear: _onClearLetters,
                  onReorder: _onReorderLetters,
                  onLetterRemoved: _onLetterRemoved,
                  onSubmit: _onSubmitWord,
                ),
              ],
            ),
          ),
          ],
        ),
        scoreKey: _scoreKey,
        showConfetti: _showScoreAnimation,
        scoreStartPosition: _lastWordPosition,
        points: _lastPoints,
        multiplier: _lastMultiplier,
        onAnimationComplete: () {
          if (mounted) {
            setState(() {
              _showScoreAnimation = false;
            });
          }
        },
      ),
    );
  }
}
