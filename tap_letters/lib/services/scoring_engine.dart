import '../constants/game_constants.dart';

class ScoringEngine {
  static int calculateWordScore(String word, {List<bool>? bonusLetters}) {
    if (word.isEmpty) return 0;
    
    // Calculate base letter score
    int letterScore = 0;
    final letters = word.toUpperCase().split('');
    for (var i = 0; i < letters.length; i++) {
      final letter = letters[i];
      final baseValue = GameConstants.letterValues[letter] ?? 1;
      // Apply 3x multiplier for bonus letters
      final isBonus = bonusLetters != null && i < bonusLetters.length && bonusLetters[i];
      letterScore += isBonus ? baseValue * 3 : baseValue;
    }
    
    // Apply length multiplier
    final multiplier = GameConstants.lengthMultipliers[word.length] ?? 1.7; // Default to 1.7 for 7+ letters
    
    // Calculate final score
    final finalScore = (letterScore * multiplier).round();
    
    return finalScore;
  }

  static String getScoreBreakdown(String word, {List<bool>? bonusLetters}) {
    if (word.isEmpty) return '';
    
    final letters = word.toUpperCase().split('');
    final letterScores = letters.asMap().entries.map((entry) {
      final letter = entry.value;
      final baseValue = GameConstants.letterValues[letter] ?? 1;
      final isBonus = bonusLetters != null && entry.key < bonusLetters.length && bonusLetters[entry.key];
      return isBonus ? baseValue * 3 : baseValue;
    }).toList();
    final baseScore = letterScores.reduce((a, b) => a + b);
    final multiplier = GameConstants.lengthMultipliers[word.length] ?? 1.7;
    final finalScore = (baseScore * multiplier).round();
    
    // Build breakdown string
    final letterBreakdown = letters.asMap().entries.map((entry) {
      final letter = entry.value;
      final score = letterScores[entry.key];
      final isBonus = bonusLetters != null && entry.key < bonusLetters.length && bonusLetters[entry.key];
      return '$letter(${isBonus ? "${GameConstants.letterValues[letter] ?? 1}×3" : score})';
    }).join(' + ');
    
    return '''
    Letters: $letterBreakdown = $baseScore
    Length Multiplier: ${multiplier}x
    Final Score: $finalScore
    ''';
  }
}
