import 'dart:math';
import 'package:flutter/material.dart';
import '../../constants/layout_constants.dart';
import '../../constants/theme_constants.dart';
import '../../models/spawned_letter.dart';

class LetterTile extends StatelessWidget {
  final SpawnedLetter letter;
  final VoidCallback onTap;

  const LetterTile({
    super.key,
    required this.letter,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: LayoutConstants.letterTileSize,
        height: LayoutConstants.letterTileSize,
        padding: EdgeInsets.all(LayoutConstants.letterTilePadding),
        decoration: ThemeConstants.letterTileDecoration,
        child: Center(
          child: Text(
            letter.letter,
            style: ThemeConstants.letterTextStyle,
          ),
        ),
      ),
    );
  }
}
