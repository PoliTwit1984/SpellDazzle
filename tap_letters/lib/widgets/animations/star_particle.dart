import 'dart:math';
import 'package:flutter/material.dart';

class StarParticle extends StatefulWidget {
  final Offset position;
  final VoidCallback onComplete;

  const StarParticle({
    super.key,
    required this.position,
    required this.onComplete,
  });

  @override
  State<StarParticle> createState() => _StarParticleState();
}

class _StarParticleState extends State<StarParticle> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scale;
  late Animation<double> _opacity;
  late Animation<Offset> _position;
  
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    // Random direction for particle movement
    final angle = _random.nextDouble() * 2 * pi;
    final distance = _random.nextDouble() * 30 + 20; // Random distance between 20-50
    
    final endX = cos(angle) * distance;
    final endY = sin(angle) * distance;

    _position = Tween<Offset>(
      begin: Offset.zero,
      end: Offset(endX, endY),
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));

    _scale = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(begin: 0.0, end: 1.0),
        weight: 30,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 1.0, end: 0.0),
        weight: 70,
      ),
    ]).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));

    _opacity = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.5, 1.0),
    ));

    _controller.forward().then((_) => widget.onComplete());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: widget.position.dx,
      top: widget.position.dy,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.translate(
            offset: _position.value,
            child: Transform.scale(
              scale: _scale.value,
              child: Opacity(
                opacity: _opacity.value,
                child: const Icon(
                  Icons.star,
                  color: Color(0xFFFFD700),
                  size: 12,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
