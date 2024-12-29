import 'package:flutter/material.dart';
import '../../constants/theme_constants.dart';
import '../../constants/layout_constants.dart';

class GameHeader extends StatelessWidget {
  final int level;
  final int score;
  final int timeLeft;
  final GlobalKey? scoreKey;

  const GameHeader({
    super.key,
    required this.level,
    required this.score,
    required this.timeLeft,
    this.scoreKey,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: LayoutConstants.headerHeight,
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Level
          Text(
            'Level $level',
            style: ThemeConstants.headerTextStyle,
          ),
          // Score
          Container(
            key: scoreKey,
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 8.0,
            ),
            decoration: BoxDecoration(
              color: ThemeConstants.accentColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(16.0),
            ),
            child: Text(
              'Score: $score',
              style: ThemeConstants.headerTextStyle,
            ),
          ),
          // Timer
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 8.0,
            ),
            decoration: BoxDecoration(
              color: timeLeft <= 5 
                  ? ThemeConstants.dangerColor.withOpacity(0.2)
                  : ThemeConstants.primaryColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(16.0),
            ),
            child: Text(
              '$timeLeft',
              style: ThemeConstants.headerTextStyle.copyWith(
                color: ThemeConstants.getTimerColor(timeLeft),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
