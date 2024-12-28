import 'package:flutter/material.dart';
import 'dart:ui';
import '../collected_letters_tray.dart';

class BottomPanel extends StatelessWidget {
  final List<String> letters;
  final VoidCallback onClear;
  final Function(int oldIndex, int newIndex) onReorder;
  final Function(String, int) onLetterRemoved;
  final VoidCallback onSubmit;

  const BottomPanel({
    super.key,
    required this.letters,
    required this.onClear,
    required this.onReorder,
    required this.onLetterRemoved,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            border: Border(
              top: BorderSide(
                color: Colors.white.withOpacity(0.2),
                width: 0.5,
              ),
            ),
          ),
          child: CollectedLettersTray(
            letters: letters,
            onClear: onClear,
            onReorder: onReorder,
            onLetterRemoved: onLetterRemoved,
            onSubmit: onSubmit,
          ),
        ),
      ),
    );
  }
}
