import '../constants/game_constants.dart';

class ScoringEngine {
  static int calculateWordScore(String word) {
    if (word.isEmpty) return 0;
    
    // Calculate base letter score
    int letterScore = 0;
    for (var letter in word.toUpperCase().split('')) {
      letterScore += GameConstants.letterValues[letter] ?? 1;
    }
    
    // Apply length multiplier
    final multiplier = GameConstants.lengthMultipliers[word.length] ?? 1.7; // Default to 1.7 for 7+ letters
    
    // Calculate final score
    final finalScore = (letterScore * multiplier).round();
    
    return finalScore;
  }

  static String getScoreBreakdown(String word) {
    if (word.isEmpty) return '';
    
    final letters = word.toUpperCase().split('');
    final letterScores = letters.map((letter) => GameConstants.letterValues[letter] ?? 1).toList();
    final baseScore = letterScores.reduce((a, b) => a + b);
    final multiplier = GameConstants.lengthMultipliers[word.length] ?? 1.7;
    final finalScore = (baseScore * multiplier).round();
    
    // Build breakdown string
    final letterBreakdown = letters.asMap().entries.map((entry) {
      final letter = entry.value;
      final score = letterScores[entry.key];
      return '$letter($score)';
    }).join(' + ');
    
    return '''
    Letters: $letterBreakdown = $baseScore
    Length Multiplier: ${multiplier}x
    Final Score: $finalScore
    ''';
  }
}
