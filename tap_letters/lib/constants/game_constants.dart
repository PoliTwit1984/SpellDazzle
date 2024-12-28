class GameConstants {
  // Letter spawning
  static const int maxSpawnedLetters = 8;
  static const int maxCollectedLetters = 7;
  static const int spawnIntervalMs = 500;
  static const int letterLifetimeSeconds = 3;
  
  // Grid layout
  static const int gridColumns = 4;
  static const int gridRows = 6;
  static const double letterSize = 60.0;
  static const double gridSpacing = 20.0;
  
  // Game rules
  static const int minWordLength = 3;
  static const int maxWordLength = 7;
  static const int roundTimeSeconds = 30;
  static const int lowTimeThreshold = 5;
  
  // Scoring
  static const double fourLetterMultiplier = 1.5;
  static const double fiveLetterMultiplier = 2.0;
  static const double speedBonusMax = 2.0;
  
  // Letter distribution
  static const Map<String, int> letterPool = {
    'E': 12, 'A': 9, 'I': 9, 'O': 8, 'N': 6, 'R': 6, 'T': 6,
    'L': 4, 'S': 4, 'U': 4, 'D': 4, 'G': 3,
    'B': 2, 'C': 2, 'M': 2, 'P': 2, 'F': 2, 'H': 2, 'V': 2, 'W': 2, 'Y': 2,
    'K': 1, 'J': 1, 'X': 1, 'Q': 1, 'Z': 1
  };
}
