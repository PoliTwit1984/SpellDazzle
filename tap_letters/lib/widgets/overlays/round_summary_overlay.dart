import 'package:flutter/material.dart';
import '../../constants/theme_constants.dart';

class RoundSummaryOverlay extends StatelessWidget {
  final int roundScore;
  final String bestWord;
  final int bestWordScore;
  final int nextLevel;
  final VoidCallback onContinue;

  const RoundSummaryOverlay({
    super.key,
    required this.roundScore,
    required this.bestWord,
    required this.bestWordScore,
    required this.nextLevel,
    required this.onContinue,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black54,
      child: Center(
        child: Container(
          margin: const EdgeInsets.all(32.0),
          padding: const EdgeInsets.all(24.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16.0),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 10,
                spreadRadius: 5,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Round Complete!',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: ThemeConstants.primaryColor,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Round Score: $roundScore',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Best Word: $bestWord',
                style: const TextStyle(
                  fontSize: 20,
                  color: Colors.black87,
                ),
              ),
              Text(
                'Word Score: $bestWordScore',
                style: const TextStyle(
                  fontSize: 18,
                  color: Colors.black54,
                ),
              ),
              const SizedBox(height: 32),
              Text(
                'Starting Level $nextLevel',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                  color: ThemeConstants.accentColor,
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: onContinue,
                style: ElevatedButton.styleFrom(
                  backgroundColor: ThemeConstants.primaryColor,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Continue',
                  style: TextStyle(
                    fontSize: 20,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
