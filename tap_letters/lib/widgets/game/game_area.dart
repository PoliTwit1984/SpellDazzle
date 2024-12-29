import 'package:flutter/material.dart';
import '../../models/animated_letter.dart';
import '../../constants/layout_constants.dart';
import '../../constants/theme_constants.dart';
import '../../constants/game_constants.dart';

class GameArea extends StatefulWidget {
  final List<AnimatedLetter> letters;
  final Function(AnimatedLetter) onLetterTapped;

  const GameArea({
    super.key,
    required this.letters,
    required this.onLetterTapped,
  });

  @override
  State<GameArea> createState() => _GameAreaState();
}

class _GameAreaState extends State<GameArea> {
  Size? _gameAreaSize;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        _gameAreaSize = Size(
          constraints.maxWidth,
          constraints.maxHeight,
        );
        
        return ClipRect(
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // Background hit area for testing clicks
              Positioned.fill(
                child: GestureDetector(
                  onTapDown: (_) {}, // Absorb background taps
                  child: Container(color: Colors.transparent),
                ),
              ),
              // Letters
              ...widget.letters.map((letter) {
                // Update bounds for each letter
                if (_gameAreaSize != null) {
                  letter.updateBounds(_gameAreaSize!, widget.letters);
                }
                
                return ValueListenableBuilder<Offset>(
                  valueListenable: letter.position,
                  builder: (context, position, _) {
                    return AnimatedBuilder(
                      animation: Listenable.merge([
                        letter.scaleController,
                      ]),
                      builder: (context, _) {
                        return Positioned(
                          left: position.dx - GameConstants.letterSize / 2,
                          top: position.dy - GameConstants.letterSize / 2,
                          child: Transform.scale(
                            scale: letter.scale.value,
                            child: Opacity(
                              opacity: letter.opacity.value,
                              child: GestureDetector(
                                onTap: () => widget.onLetterTapped(letter),
                                child: Container(
                                  width: GameConstants.letterSize,
                                  height: GameConstants.letterSize,
                                  decoration: BoxDecoration(
                                    color: ThemeConstants.primaryColor,
                                    borderRadius: BorderRadius.circular(12),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.2),
                                        blurRadius: 4,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Center(
                                    child: Text(
                                      letter.letter,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                );
              }).toList(),
            ],
          ),
        );
      },
    );
  }
}
