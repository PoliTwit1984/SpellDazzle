import 'package:flutter/material.dart';
import '../models/spawned_letter.dart';
import '../constants/game_constants.dart';

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

class _LetterTileState extends State<LetterTile> with TickerProviderStateMixin {
  late final AnimationController _appearController;
  late final AnimationController _bobController;
  late final Animation<double> _scaleAnimation;
  late final Animation<double> _fadeAnimation;
  late final Animation<double> _bobAnimation;

  @override
  void initState() {
    super.initState();
    
    // Setup appear animation (pop and fade in)
    _appearController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(begin: 0.0, end: 1.2),
        weight: 50,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 1.2, end: 1.0),
        weight: 50,
      ),
    ]).animate(CurvedAnimation(
      parent: _appearController,
      curve: Curves.easeOut,
    ));
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _appearController,
      curve: Curves.easeIn,
    ));
    
    // Setup bobbing animation
    _bobController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    
    _bobAnimation = Tween<double>(
      begin: -3.0,
      end: 3.0,
    ).animate(CurvedAnimation(
      parent: _bobController,
      curve: Curves.easeInOut,
    ));
    
    // Start animations
    _appearController.forward();
    _bobController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _appearController.dispose();
    _bobController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: widget.letter.position.dx,
      top: widget.letter.position.dy,
      child: AnimatedBuilder(
        animation: Listenable.merge([_appearController, _bobController]),
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(0, _bobAnimation.value),
            child: Transform.scale(
              scale: _scaleAnimation.value,
              child: Opacity(
                opacity: _fadeAnimation.value,
                child: GestureDetector(
                  onTap: widget.onTap,
                  child: TweenAnimationBuilder<double>(
                    tween: Tween(begin: 1.0, end: 0.0),
                    duration: Duration(seconds: GameConstants.maxLetterLifetimeSeconds),
                    builder: (context, value, child) {
                      return Stack(
                        alignment: Alignment.center,
                        children: [
                          CircularProgressIndicator(
                            value: value,
                            backgroundColor: Colors.transparent,
                            color: Colors.blue.withOpacity(0.3),
                            strokeWidth: 4,
                          ),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xFF00C6FF), // Bright cyan
                        Color(0xFF0072FF), // Bright blue
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF0072FF).withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                      BoxShadow(
                        color: Colors.white.withOpacity(0.2),
                        blurRadius: 4,
                        spreadRadius: -2,
                        offset: const Offset(0, -2),
                      ),
                    ],
                  ),
                  child: Text(
                    widget.letter.letter,
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
                        ],
                      );
                    },
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
