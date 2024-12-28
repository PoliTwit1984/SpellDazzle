import 'dart:math';
import 'package:flutter/material.dart';
import 'star_particle.dart';

class RewardAnimations extends StatefulWidget {
  final Widget child;
  final GlobalKey scoreKey;
  final bool showConfetti;
  final Offset? scoreStartPosition;
  final VoidCallback onAnimationComplete;
  final int points;
  final double multiplier;

  const RewardAnimations({
    super.key,
    required this.child,
    required this.scoreKey,
    required this.showConfetti,
    this.scoreStartPosition,
    required this.onAnimationComplete,
    required this.points,
    required this.multiplier,
  });

  @override
  State<RewardAnimations> createState() => _RewardAnimationsState();
}

class _RewardAnimationsState extends State<RewardAnimations> with SingleTickerProviderStateMixin {
  late AnimationController _floatingScoreController;
  final List<Key> _particles = [];
  final Random _random = Random();
  late Animation<double> _floatingScoreOpacity;
  late Animation<Offset> _floatingScorePosition;
  
  Offset? _targetScorePosition;

  @override
  void initState() {
    super.initState();
    _floatingScoreController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _floatingScoreOpacity = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _floatingScoreController,
      curve: const Interval(0.7, 1.0), // Stay visible longer before fading
    ));

    _floatingScoreController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        widget.onAnimationComplete();
      }
    });
  }

  @override
  void didUpdateWidget(RewardAnimations oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.showConfetti && !oldWidget.showConfetti) {
      _playRewardAnimation();
    }
  }

  void _playRewardAnimation() {
    // Get the position of the score display
    final RenderBox? scoreBox = widget.scoreKey.currentContext?.findRenderObject() as RenderBox?;
    if (scoreBox != null) {
      _targetScorePosition = scoreBox.localToGlobal(
        Offset(scoreBox.size.width / 2, scoreBox.size.height / 2),
      );
    }

    if (widget.scoreStartPosition != null && _targetScorePosition != null) {
      // Create position animation from start to target
      _floatingScorePosition = Tween<Offset>(
        begin: widget.scoreStartPosition!,
        end: _targetScorePosition!,
      ).animate(CurvedAnimation(
        parent: _floatingScoreController,
        curve: Curves.easeOut,
      ));

      _floatingScoreController.forward(from: 0);
    }

    // Create star particles
    setState(() {
      for (int i = 0; i < 12; i++) {
        _particles.add(UniqueKey());
      }
    });
  }

  void _removeParticle(Key key) {
    setState(() {
      _particles.remove(key);
    });
  }

  @override
  void dispose() {
    _floatingScoreController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        if (widget.scoreStartPosition != null)
          ..._particles.map((key) {
            // Calculate random offset around the word position
            final offsetX = _random.nextDouble() * 200 - 100; // -100 to 100
            final offsetY = _random.nextDouble() * 40 - 20; // -20 to 20
            return StarParticle(
              key: key,
              position: Offset(
                widget.scoreStartPosition!.dx + offsetX,
                widget.scoreStartPosition!.dy + offsetY,
              ),
              onComplete: () => _removeParticle(key),
            );
          }).toList(),
        if (widget.scoreStartPosition != null && _targetScorePosition != null)
          AnimatedBuilder(
            animation: _floatingScoreController,
            builder: (context, child) {
              return Positioned(
                left: _floatingScorePosition.value.dx,
                top: _floatingScorePosition.value.dy,
                child: Opacity(
                  opacity: _floatingScoreOpacity.value,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Color(0xFF00C6FF),
                          Color(0xFF0072FF),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF0072FF).withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '+${widget.points}',
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
                        if (widget.multiplier > 1.0) ...[
                          const SizedBox(width: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '×${widget.multiplier.toStringAsFixed(1)}',
                              style: const TextStyle(
                                fontSize: 18,
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
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
      ],
    );
  }
}
