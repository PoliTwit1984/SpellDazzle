import 'package:flutter/material.dart';
import '../constants/layout_constants.dart';
import '../constants/game_constants.dart';
import '../managers/game_manager.dart';
import '../models/game_state.dart';
import '../models/animated_letter.dart';
import '../services/dictionary_service.dart';
import '../services/scoring_engine.dart';
import '../widgets/game/bottom_panel.dart';
import '../widgets/game/game_area.dart';
import '../widgets/game/game_header.dart';
import '../widgets/game/wave_background.dart';
import '../widgets/animations/reward_animations.dart';
import '../widgets/animations/points_pop_animation.dart';
import '../widgets/overlays/game_over_overlay.dart';
import '../widgets/overlays/round_summary_overlay.dart';
import '../constants/theme_constants.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> with TickerProviderStateMixin {
  late GameManager _gameManager;
  late GameState _gameState;
  final List<AnimatedLetter> _letters = [];
  final GlobalKey _scoreKey = GlobalKey();
  bool _showScoreAnimation = false;
  bool _isGameOver = false;
  bool _isLoading = true;
  bool _isSubmitting = false;
  bool _showRoundSummary = false;
  Offset? _lastWordPosition;
  int _lastPoints = 0;
  final double _lastMultiplier = 1.0;
  int _previousScore = 0;
  
  // Round summary data
  int _roundScore = 0;
  String _bestWord = '';
  int _bestWordScore = 0;
  int _nextLevel = 1;

  @override
  void initState() {
    super.initState();
    _initializeServices();
  }

  Future<void> _initializeServices() async {
    // Initialize dictionary service
    await DictionaryService().initialize();
    
    setState(() {
      _isLoading = false;
      _gameState = GameState();
    });
    
    _initializeGame();
  }

  void _initializeGame() {
    _gameManager = GameManager(
      gameState: _gameState,
      onScoreChanged: (score) {
        setState(() {
          _lastPoints = score - _previousScore;
          _previousScore = score;
        });
        _gameState.updateScore(score);
      },
      onLevelChanged: _gameState.updateLevel,
      onTimeChanged: _gameState.updateTimeLeft,
      onLetterSpawned: (String letter, Offset position, bool isBonus) {
        // Create animated letter with this widget as vsync provider
        late final AnimatedLetter newLetter;
        newLetter = AnimatedLetter(
          letter: letter,
          initialPosition: position,
          vsync: this,
          isBonus: isBonus,
          onExpire: () {
            setState(() {
              _letters.remove(newLetter);
              _gameManager.onLetterExpired(); // Notify manager to spawn new letter
            });
          },
        );
        setState(() {
          _letters.add(newLetter);
        });
      },
      onGameOver: () {
        setState(() {
          _isGameOver = true;
        });
      },
      onRoundComplete: (roundScore, bestWord, bestWordScore, nextLevel) {
        setState(() {
          _roundScore = roundScore;
          _bestWord = bestWord;
          _bestWordScore = bestWordScore;
          _nextLevel = nextLevel;
          _showRoundSummary = true;
        });
      },
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final mediaQuery = MediaQuery.of(context);
      final size = Size(
        mediaQuery.size.width,
        mediaQuery.size.height - mediaQuery.padding.top - mediaQuery.padding.bottom,
      );
      _gameManager.initializeGrid(
        size,
        LayoutConstants.headerHeight,
        LayoutConstants.bottomPanelHeight,
      );
      _gameManager.startGame();
    });
  }

  void _restartGame() {
    setState(() {
      _isGameOver = false;
      _previousScore = 0;
      // Clear existing letters
      for (final letter in _letters) {
        letter.dispose();
      }
      _letters.clear();
      // Reset game state
      _gameState = GameState();
      // Initialize new game
      _initializeGame();
    });
  }

  void _continueToNextRound() {
    setState(() {
      _showRoundSummary = false;
      // Clear existing letters
      for (final letter in _letters) {
        letter.dispose();
      }
      _letters.clear();
      // Clear letter tray
      _gameState.clearCollectedLetters();
    });
    
    // Start next round after a short delay
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        _gameManager.startNextRound();
      }
    });
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: ThemeConstants.dangerColor,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showPointsAnimation(String word, int points, String breakdown) {
    late final OverlayEntry overlay;
    overlay = OverlayEntry(
      builder: (context) => Positioned(
        left: 0,
        right: 0,
        bottom: LayoutConstants.bottomPanelHeight + 20,
        child: Center(
          child: PointsPopAnimation(
            word: word,
            points: points,
            breakdown: breakdown,
            onComplete: () {
              overlay.remove();
              _showConfettiAnimation();
            },
          ),
        ),
      ),
    );
    
    Overlay.of(context).insert(overlay);
  }

  void _showConfettiAnimation() {
    final RenderBox? box = _scoreKey.currentContext?.findRenderObject() as RenderBox?;
    if (box != null) {
      final position = box.localToGlobal(
        Offset(box.size.width / 2, box.size.height / 2)
      );
      setState(() {
        _lastWordPosition = position;
        _showScoreAnimation = true;
      });
      
      Future.delayed(const Duration(milliseconds: 1200), () {
        if (mounted) {
          setState(() {
            _showScoreAnimation = false;
          });
        }
      });
    }
  }

  Future<void> _onSubmitWord() async {
    if (_isSubmitting) return;
    if (_gameState.collectedLetters.value.isEmpty) {
      _showError('No letters collected');
      return;
    }
    if (_gameState.collectedLetters.value.length < GameConstants.minWordLength) {
      _showError('Word must be at least ${GameConstants.minWordLength} letters');
      return;
    }
    
    setState(() {
      _isSubmitting = true;
    });
    
    try {
      final word = _gameState.collectedLetters.value.join().toUpperCase();
      final success = await _gameManager.submitWord();
      if (success) {
        final breakdown = ScoringEngine.getScoreBreakdown(
          word,
          bonusLetters: _gameState.bonusLetters.value,
        );
        _showPointsAnimation(word, _lastPoints, breakdown);
      } else {
        _showError('Invalid word');
      }
    } catch (e) {
      _showError('Error submitting word');
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  void _handleLetterTap(AnimatedLetter letter) {
    if (_gameState.collectedLetters.value.length >= GameConstants.maxCollectedLetters) {
      _showError('Maximum ${GameConstants.maxCollectedLetters} letters allowed');
      return;
    }
    
    // Add letter to tray with bonus status
    _gameState.addCollectedLetter(letter.letter, isBonus: letter.isBonus);
    
    // Start despawn animation
    letter.startDespawnAnimation();
    
    // Remove letter from game area
    setState(() {
      _letters.remove(letter);
      _gameManager.onLetterCollected(); // Notify manager to spawn new letter
    });
  }

  @override
  void dispose() {
    _gameManager.dispose();
    _gameState.dispose();
    for (final letter in _letters) {
      letter.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: Colors.transparent,
        body: Container(
          decoration: const BoxDecoration(
            gradient: ThemeConstants.backgroundGradient,
          ),
          child: const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(ThemeConstants.white),
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Material(
        type: MaterialType.transparency,
        child: Container(
          decoration: const BoxDecoration(
            gradient: ThemeConstants.backgroundGradient,
          ),
          child: SafeArea(
            child: RewardAnimations(
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
              child: Stack(
                children: [
                  // Background waves
                  Positioned.fill(
                    child: ValueListenableBuilder<int>(
                      valueListenable: _gameState.level,
                      builder: (context, level, _) {
                        return WaveBackground(
                          key: ValueKey('wave_background_$level'),
                          roundNumber: level,
                        );
                      },
                    ),
                  ),
                  // Game layout
                  Column(
                    children: [
                      // Header
                      ValueListenableBuilder<int>(
                        valueListenable: _gameState.score,
                        builder: (context, score, _) {
                          return ValueListenableBuilder<int>(
                            valueListenable: _gameState.level,
                            builder: (context, level, _) {
                              return ValueListenableBuilder<int>(
                                valueListenable: _gameState.timeLeft,
                                builder: (context, timeLeft, _) {
                                  return GameHeader(
                                    level: level,
                                    score: score,
                                    timeLeft: timeLeft,
                                    scoreKey: _scoreKey,
                                  );
                                },
                              );
                            },
                          );
                        },
                      ),
                      // Game area with letters
                      Expanded(
                        child: GameArea(
                          letters: _letters,
                          onLetterTapped: _handleLetterTap,
                        ),
                      ),
                      // Bottom panel
                      ValueListenableBuilder<List<String>>(
                        valueListenable: _gameState.collectedLetters,
                        builder: (context, letters, _) {
                          return ValueListenableBuilder<List<bool>>(
                            valueListenable: _gameState.bonusLetters,
                            builder: (context, bonuses, _) {
                              return BottomPanel(
                                letters: letters,
                                bonusLetters: bonuses,
                                onClear: _gameState.clearCollectedLetters,
                                onReorder: _gameState.reorderCollectedLetters,
                                onLetterRemoved: _gameState.removeCollectedLetter,
                                onSubmit: _onSubmitWord,
                              );
                            },
                          );
                        },
                      ),
                    ],
                  ),
                  // Game over overlay
                  if (_isGameOver)
                    ValueListenableBuilder<int>(
                      valueListenable: _gameState.score,
                      builder: (context, score, _) {
                        return ValueListenableBuilder<int>(
                          valueListenable: _gameState.level,
                          builder: (context, level, _) {
                            return GameOverOverlay(
                              finalScore: score,
                              level: level,
                              onRestart: _restartGame,
                            );
                          },
                        );
                      },
                    ),
                  // Round summary overlay
                  if (_showRoundSummary)
                    RoundSummaryOverlay(
                      roundScore: _roundScore,
                      bestWord: _bestWord,
                      bestWordScore: _bestWordScore,
                      nextLevel: _nextLevel,
                      onContinue: _continueToNextRound,
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
