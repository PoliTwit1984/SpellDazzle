import 'dart:math';
import 'package:flutter/material.dart';
import '../../constants/layout_constants.dart';
import '../../constants/theme_constants.dart';
import '../../constants/game_constants.dart';
import '../../models/animated_letter.dart';

class RotatingLetterTile extends StatefulWidget {
  final AnimatedLetter letter;
  final VoidCallback onTap;

  const RotatingLetterTile({
    super.key,
    required this.letter,
    required this.onTap,
  });

  @override
  State<RotatingLetterTile> createState() => _RotatingLetterTileState();
}

class _RotatingLetterTileState extends State<RotatingLetterTile> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    
    // Random rotation range between ±0.1 radians (±5.7 degrees)
    final random = Random();
    final rotationRange = 0.05 + random.nextDouble() * 0.05; // 0.05-0.1 radians
    final rotationOffset = -rotationRange + random.nextDouble() * (rotationRange * 2);
    
    // Random duration between 1-2 seconds
    final duration = 1000 + random.nextInt(1000);
    
    _controller = AnimationController(
      duration: Duration(milliseconds: duration),
      vsync: this,
    );

    _rotationAnimation = Tween<double>(
      begin: rotationOffset - rotationRange,
      end: rotationOffset + rotationRange,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
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
              width: LayoutConstants.letterTileSize * widget.letter.sizeVariation,
              height: LayoutConstants.letterTileSize * widget.letter.sizeVariation,
              padding: EdgeInsets.all(LayoutConstants.letterTilePadding),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    widget.letter.baseColor,
                    Color.lerp(widget.letter.baseColor, Colors.white, 0.2) ?? widget.letter.baseColor,
                  ],
                ),
                borderRadius: BorderRadius.circular(widget.letter.cornerRadius),
                border: Border.all(
                  color: Colors.white.withOpacity(0.2),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: widget.letter.baseColor.withOpacity(widget.letter.shadowIntensity * 0.5),
                    blurRadius: 8 + (widget.letter.shadowIntensity * 8),
                    spreadRadius: 2,
                    offset: Offset(0, 2 + (widget.letter.shadowIntensity * 2)),
                  ),
                  BoxShadow(
                    color: Colors.black.withOpacity(widget.letter.shadowIntensity * 0.3),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  widget.letter.letter,
                  style: ThemeConstants.letterTextStyle.copyWith(
                    fontSize: (widget.letter.sizeVariation * LayoutConstants.letterTileSize / GameConstants.letterSize) * 28,
                    fontWeight: FontWeight.w800,
                    shadows: [
                      Shadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                      Shadow(
                        color: widget.letter.baseColor.withOpacity(0.5),
                        blurRadius: 8,
                        offset: const Offset(0, 0),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
