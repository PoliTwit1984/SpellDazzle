import 'package:flutter/material.dart';

class ThemeConstants {
  // Colors
  static const Color primaryColor = Color(0xFF2196F3); // Material Blue
  static const Color accentColor = Color(0xFF4CAF50); // Material Green
  static const Color backgroundColor = Color(0xFFF5F5F5);
  static const Color textColor = Color(0xFF212121);
  static const Color secondaryTextColor = Color(0xFF757575);
  static const Color dangerColor = Colors.red;
  static const Color white = Colors.white;
  
  // Gradients
  static const LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFF0D47A1), // Dark Blue
      Color(0xFF052B6B), // Very Dark Blue
    ],
  );
  
  // Text Styles
  static const TextStyle headerTextStyle = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: white,
  );
  
  static const TextStyle letterTextStyle = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    color: white,
  );
  
  static const TextStyle scoreTextStyle = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w500,
    color: white,
  );
  
  static const TextStyle buttonTextStyle = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
    color: white,
  );
  
  // Decorations
  static BoxDecoration letterTileDecoration = BoxDecoration(
    color: primaryColor,
    borderRadius: BorderRadius.circular(12),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.2),
        blurRadius: 4,
        offset: const Offset(0, 2),
      ),
    ],
  );
  
  static BoxDecoration collectedLetterTileDecoration = BoxDecoration(
    color: accentColor,
    borderRadius: BorderRadius.circular(8),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.1),
        blurRadius: 2,
        offset: const Offset(0, 1),
      ),
    ],
  );
  
  static BoxDecoration panelDecoration = BoxDecoration(
    color: Colors.white.withOpacity(0.1),
    borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.1),
        blurRadius: 4,
        offset: const Offset(0, -2),
      ),
    ],
  );
  
  static BoxDecoration letterTrayDecoration = BoxDecoration(
    color: Colors.white.withOpacity(0.15),
    borderRadius: BorderRadius.circular(12),
    border: Border.all(
      color: Colors.white.withOpacity(0.3),
      width: 1,
    ),
  );
  
  // Button Styles
  static ButtonStyle clearButtonStyle = ElevatedButton.styleFrom(
    backgroundColor: dangerColor,
    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8),
    ),
  );
  
  static ButtonStyle submitButtonStyle = ElevatedButton.styleFrom(
    backgroundColor: accentColor,
    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8),
    ),
  );
  
  // Timer Colors
  static Color getTimerColor(int timeLeft) {
    if (timeLeft <= 5) {
      return dangerColor;
    } else if (timeLeft <= 10) {
      return Colors.orange;
    }
    return white;
  }
}
