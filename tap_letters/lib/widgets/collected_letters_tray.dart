import 'package:flutter/material.dart';

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
                          gradient: const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Color(0xFF00C6FF),
                              Color(0xFF0072FF),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF0072FF).withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Text(
                          letters[i],
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            shadows: [
                              Shadow(
                                color: Colors.black26,
                                offset: Offset(0, 1),
                                blurRadius: 2,
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
