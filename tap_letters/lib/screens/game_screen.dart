import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../constants/game_constants.dart';
import '../models/spawned_letter.dart';
import '../services/dictionary_service.dart';
import '../widgets/game/bottom_panel.dart';
import '../widgets/game/letter_tile.dart';

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
  int _timeLeft = 30; // 30 seconds per level
  int _level = 1;
  final DictionaryService _dictionaryService = DictionaryService();
  final List<Offset> _gridPositions = [];
  final List<bool> _gridOccupied = [];

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
    const gridColumns = 4;
    const gridRows = 6;
    const letterSize = 60.0;
    const spacing = 20.0;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final screenWidth = MediaQuery.of(context).size.width;
      final screenHeight = MediaQuery.of(context).size.height;
      final startX = (screenWidth - (gridColumns * (letterSize + spacing))) / 2;
      final startY = 120.0; // Start below the header

      for (int row = 0; row < gridRows; row++) {
        for (int col = 0; col < gridColumns; col++) {
          final x = startX + col * (letterSize + spacing);
          final y = startY + row * (letterSize + spacing);
          if (y + letterSize < screenHeight - 200) { // Avoid bottom panel
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
    _timeLeft = 30;
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
      const Duration(milliseconds: 500),
      (timer) {
        if (_spawnedLetters.length < GameConstants.maxSpawnedLetters) {
          _spawnLetter();
        }
      },
    );
  }

  void _spawnLetter() {
    const letters = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
    final letter = letters[_random.nextInt(letters.length)];
    final position = _getAvailableGridPosition();

    if (position != null) {
      final gridIndex = _gridPositions.indexOf(position);
      setState(() {
        _spawnedLetters.add(
          SpawnedLetter(
            letter: letter,
            position: position,
          ),
        );
        _gridOccupied[gridIndex] = true;

        // Remove letter after 3 seconds if not collected
        Future.delayed(const Duration(seconds: 3), () {
          setState(() {
            _spawnedLetters.removeWhere((l) => l.position == position);
            _gridOccupied[gridIndex] = false;
          });
        });
      });
    }
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

  void _onSubmitWord() async {
    final word = _collectedLetters.join();
    if (word.length < 3) return;

    final isValid = await _dictionaryService.isValidWord(word);

    if (isValid) {
      // Calculate score with bonuses
      double baseScore = word.length.toDouble();
      double multiplier = 1.0;
      
      // Length bonus
      if (word.length >= 5) {
        multiplier = 2.0;
      } else if (word.length == 4) {
        multiplier = 1.5;
      }

      final points = (baseScore * multiplier).round();

      setState(() {
        _score += points;
        _collectedLetters.clear();
        _level++;
        _startGameTimer(); // Reset timer for next level
      });
    } else {
      _endGame();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isTimeLow = _timeLeft <= 5;

    return Scaffold(
      body: Stack(
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
                      Text(
                        'Score: $_score',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
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
    );
  }
}
