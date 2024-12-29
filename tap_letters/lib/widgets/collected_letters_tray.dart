import 'package:flutter/material.dart';
import '../constants/theme_constants.dart';

class CollectedLettersTray extends StatelessWidget {
  final List<String> letters;
  final VoidCallback onClear;
  final Function(int oldIndex, int newIndex) onReorder;
  final Function(String, int) onLetterRemoved;
  final VoidCallback onSubmit;

  const CollectedLettersTray({
    super.key,
    required this.letters,
    required this.onClear,
    required this.onReorder,
    required this.onLetterRemoved,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (letters.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 12,
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    const Color(0xFF00C6FF).withOpacity(0.3),
                    const Color(0xFF0072FF).withOpacity(0.3),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Colors.white.withOpacity(0.2),
                  width: 0.5,
                ),
              ),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    letters.length,
                    (i) => GestureDetector(
                      key: ValueKey(i),
                      onDoubleTap: () => onLetterRemoved(letters[i], i),
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              ThemeConstants.primaryColor,
                              Color.lerp(ThemeConstants.primaryColor, Colors.white, 0.2) ?? ThemeConstants.primaryColor,
                            ],
                          ),
                          borderRadius: BorderRadius.circular(8 + (i % 3) * 4.0), // Vary between 8-16
                          border: Border.all(
                            color: Colors.white.withOpacity(0.2),
                            width: 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: ThemeConstants.primaryColor.withOpacity(0.4),
                              blurRadius: 12,
                              spreadRadius: 2,
                              offset: const Offset(0, 2),
                            ),
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Transform.scale(
                          scale: 0.95 + (i % 2) * 0.1, // Alternate between 0.95 and 1.05
                          child: Text(
                            letters[i],
                            style: ThemeConstants.letterTextStyle.copyWith(
                              fontSize: 24,
                              fontWeight: FontWeight.w800,
                              shadows: [
                                Shadow(
                                  color: Colors.black.withOpacity(0.3),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                                Shadow(
                                  color: ThemeConstants.primaryColor.withOpacity(0.5),
                                  blurRadius: 8,
                                  offset: const Offset(0, 0),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (letters.isNotEmpty) ...[
                IconButton(
                  icon: const Icon(Icons.clear_all, color: Colors.white70),
                  onPressed: onClear,
                  tooltip: 'Clear all letters',
                ),
                const SizedBox(width: 16),
                IconButton(
                  icon: const Icon(Icons.check_circle, color: Colors.white70),
                  onPressed: onSubmit,
                  tooltip: 'Submit word',
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
