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
    final style = letter.style;
    
    return GestureDetector(
      onTap: onTap,
      child: Transform.rotate(
        angle: style.rotation,
        child: Container(
          width: style.size,
          height: style.size,
          padding: EdgeInsets.all(LayoutConstants.letterTilePadding),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                style.color,
                Color.lerp(style.color, Colors.white, 0.2) ?? style.color,
              ],
            ),
            borderRadius: BorderRadius.circular(style.cornerRadius),
            border: Border.all(
              color: Colors.white.withOpacity(0.2),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: style.color.withOpacity(style.shadowIntensity * 0.5),
                blurRadius: 8 + (style.shadowIntensity * 8),
                spreadRadius: 2,
                offset: Offset(0, 2 + (style.shadowIntensity * 2)),
              ),
              BoxShadow(
                color: Colors.black.withOpacity(style.shadowIntensity * 0.3),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Center(
            child: Text(
              letter.letter,
              style: ThemeConstants.letterTextStyle.copyWith(
                fontSize: (style.size / SpawnedLetter.letterSize) * 28, // Scale font with tile
                fontWeight: FontWeight.w800,
                shadows: [
                  Shadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                  Shadow(
                    color: style.color.withOpacity(0.5),
                    blurRadius: 8,
                    offset: const Offset(0, 0),
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
