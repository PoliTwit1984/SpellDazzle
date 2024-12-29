import 'dart:math';
import 'package:flutter/material.dart';
import '../../constants/layout_constants.dart';
import '../../constants/theme_constants.dart';
import '../../models/spawned_letter.dart';

class LetterTile extends StatefulWidget {
  final SpawnedLetter letter;
  final VoidCallback onTap;

  const LetterTile({
    super.key,
    required this.letter,
    required this.onTap,
  });

  @override
  State<LetterTile> createState() => _LetterTileState();
}

class _LetterTileState extends State<LetterTile> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _rotationAnimation = Tween<double>(
      begin: -0.5,
      end: 0.5,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticInOut,
    ));

    _controller.repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.rotate(
          angle: _rotationAnimation.value,
          child: GestureDetector(
            onTap: widget.onTap,
            child: Container(
              width: LayoutConstants.letterTileSize,
              height: LayoutConstants.letterTileSize,
              padding: EdgeInsets.all(LayoutConstants.letterTilePadding),
              decoration: ThemeConstants.letterTileDecoration,
              child: Center(
                child: Text(
                  widget.letter.letter,
                  style: ThemeConstants.letterTextStyle,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
