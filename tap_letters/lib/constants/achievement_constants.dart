import 'package:flutter/material.dart';

class AchievementConstants {
  static const int scorePerLevel = 100;
  
  static const Map<int, AchievementData> levelAchievements = {
    2: AchievementData(
      title: 'Word Novice',
      description: 'You\'re getting the hang of it!',
      icon: Icons.emoji_events,
    ),
    5: AchievementData(
      title: 'Word Explorer',
      description: 'You\'re making great progress!',
      icon: Icons.psychology,
    ),
    10: AchievementData(
      title: 'Word Master',
      description: 'You\'re becoming a true wordsmith!',
      icon: Icons.workspace_premium,
    ),
  };

  static const Map<int, AchievementData> scoreAchievements = {
    500: AchievementData(
      title: 'High Scorer',
      description: '500 points! Keep it up!',
      icon: Icons.stars,
    ),
    1000: AchievementData(
      title: 'Point Champion',
      description: 'Wow! 1000 points!',
      icon: Icons.military_tech,
    ),
    2000: AchievementData(
      title: 'Legend',
      description: 'You\'re unstoppable!',
      icon: Icons.local_fire_department,
    ),
  };

  static const Map<int, AchievementData> wordLengthAchievements = {
    5: AchievementData(
      title: 'Word Builder',
      description: 'Created a 5-letter word!',
      icon: Icons.extension,
    ),
    7: AchievementData(
      title: 'Vocabulary Expert',
      description: 'Created a 7-letter word!',
      icon: Icons.auto_awesome,
    ),
    9: AchievementData(
      title: 'Lexicon Master',
      description: 'Created a 9-letter word!',
      icon: Icons.diamond,
    ),
  };

  static const Map<String, Color> levelColors = {
    'bronze': Color(0xFFCD7F32),
    'silver': Color(0xFFC0C0C0),
    'gold': Color(0xFFFFD700),
    'platinum': Color(0xFFE5E4E2),
    'diamond': Color(0xFFB9F2FF),
  };

  static Color getLevelColor(int level) {
    if (level < 5) return levelColors['bronze']!;
    if (level < 10) return levelColors['silver']!;
    if (level < 15) return levelColors['gold']!;
    if (level < 20) return levelColors['platinum']!;
    return levelColors['diamond']!;
  }

  static String getLevelRank(int level) {
    if (level < 5) return 'Bronze';
    if (level < 10) return 'Silver';
    if (level < 15) return 'Gold';
    if (level < 20) return 'Platinum';
    return 'Diamond';
  }
}

class AchievementData {
  final String title;
  final String description;
  final IconData icon;

  const AchievementData({
    required this.title,
    required this.description,
    required this.icon,
  });
}
