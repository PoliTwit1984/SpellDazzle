class GameConstants {
  // Game rules
  static const int minWordLength = 3;
  static const int maxCollectedLetters = 6;
  static const int roundTimeSeconds = 30;
  
  // Letter spawning
  static const int minSpawnedLetters = 8;
  static const int maxSpawnedLetters = 12;
  static const int spawnIntervalMs = 1000;
  static const double letterSize = 60.0;
  
  // Letter movement
  static const double minLetterSpeed = 50.0; // Pixels per second
  static const double maxLetterSpeed = 150.0; // Pixels per second
  static const int minLetterLifetimeSeconds = 3;
  static const int maxLetterLifetimeSeconds = 6;
  static const double wobbleFrequency = 2.0; // Wobbles per second
  static const double wobbleAmplitude = 3.0; // Pixels
  
  // Letter pool with weights (Scrabble-like distribution)
  static const Map<String, int> letterPool = {
    'E': 12, 'A': 9, 'I': 9, 'O': 8, 'N': 6, 'R': 6, 'T': 6, 'L': 4, 'S': 4, 'U': 4,
    'D': 4, 'G': 3, 'B': 2, 'C': 2, 'M': 2, 'P': 2, 'F': 2, 'H': 2, 'V': 2, 'W': 2,
    'Y': 2, 'K': 1, 'J': 1, 'X': 1, 'Q': 1, 'Z': 1,
  };
  
  // Letter point values (Scrabble-like scoring)
  static const Map<String, int> letterValues = {
    'A': 1, 'B': 3, 'C': 3, 'D': 2, 'E': 1, 'F': 4, 'G': 2, 'H': 4, 'I': 1, 'J': 8,
    'K': 5, 'L': 1, 'M': 3, 'N': 1, 'O': 1, 'P': 3, 'Q': 10, 'R': 1, 'S': 1, 'T': 1,
    'U': 1, 'V': 4, 'W': 4, 'X': 8, 'Y': 4, 'Z': 10,
  };
  
  // Word length multipliers
  static const Map<int, double> lengthMultipliers = {
    3: 1.0, // 3 letters = no multiplier
    4: 1.2, // 4 letters = 1.2x points
    5: 1.3, // 5 letters = 1.3x points
    6: 1.5, // 6 letters = 1.5x points
    7: 1.7, // 7+ letters = 1.7x points
  };
}
