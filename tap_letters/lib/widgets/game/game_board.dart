import 'package:flutter/material.dart';
import '../../models/spawned_letter.dart';
import 'parallax_background.dart';
import 'letter_tile.dart';

class GameBoard extends StatelessWidget {
  final List<SpawnedLetter> spawnedLetters;
  final Function(SpawnedLetter) onLetterTap;
  final double playableHeight;
  final double topOffset;

  const GameBoard({
    super.key,
    required this.spawnedLetters,
    required this.onLetterTap,
    required this.playableHeight,
    required this.topOffset,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ParallaxBackground(
          playableHeight: playableHeight,
          topOffset: topOffset,
        ),
        // Spawned letters
        for (final letter in spawnedLetters)
          LetterTile(
            letter: letter,
            onTap: () => onLetterTap(letter),
          ),
      ],
    );
  }
}
