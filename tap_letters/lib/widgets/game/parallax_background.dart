import 'dart:math';
import 'package:flutter/material.dart';

class ParallaxBackground extends StatefulWidget {
  final double playableHeight;
  final double topOffset;

  const ParallaxBackground({
    super.key,
    required this.playableHeight,
    required this.topOffset,
  });

  @override
  State<ParallaxBackground> createState() => _ParallaxBackgroundState();
}

class _ParallaxBackgroundState extends State<ParallaxBackground> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<_FloatingShape> _shapes = [];
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  List<_FloatingShape> _createShapes() {
    if (_shapes.isEmpty) {
      final screenWidth = MediaQuery.of(context).size.width;
      for (int i = 0; i < 15; i++) {
        _shapes.add(_FloatingShape(
          position: Offset(
            _random.nextDouble() * screenWidth,
            widget.topOffset + _random.nextDouble() * widget.playableHeight,
          ),
          size: _random.nextDouble() * 40 + 20, // 20-60
          speed: _random.nextDouble() * 0.4 + 0.1, // 0.1-0.5
          type: _random.nextBool() ? ShapeType.circle : ShapeType.square,
        ));
      }
    }
    return _shapes;
  }

  @override
  Widget build(BuildContext context) {
    final shapes = _createShapes();
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Stack(
          children: [
            // Base gradient background
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFFFF9A9E), // Soft pink
                    Color(0xFFFAD0C4), // Peach
                    Color(0xFFFAD0C4), // Peach
                    Color(0xFFFFD1FF), // Light purple
                  ],
                  stops: [0.0, 0.3, 0.7, 1.0],
                ),
              ),
            ),
            // Floating shapes
            ...shapes.map((shape) {
              final progress = _controller.value * shape.speed;
              final dx = sin(progress * 2 * pi) * 30;
              final dy = cos(progress * 2 * pi) * 20;

              return Positioned(
                left: shape.position.dx + dx,
                top: shape.position.dy + dy,
                child: Container(
                  width: shape.size,
                  height: shape.size,
                  decoration: BoxDecoration(
                    shape: shape.type == ShapeType.circle 
                      ? BoxShape.circle 
                      : BoxShape.rectangle,
                    borderRadius: shape.type == ShapeType.square 
                      ? BorderRadius.circular(8) 
                      : null,
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.white.withOpacity(0.2),
                        Colors.white.withOpacity(0.1),
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.white.withOpacity(0.1),
                        blurRadius: 8,
                        spreadRadius: -2,
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
            // Grid lines
            CustomPaint(
              size: Size.infinite,
              painter: GridPainter(
                playableHeight: widget.playableHeight,
                topOffset: widget.topOffset,
                progress: _controller.value,
              ),
            ),
          ],
        );
      },
    );
  }
}

class GridPainter extends CustomPainter {
  final double playableHeight;
  final double topOffset;
  final double progress;

  GridPainter({
    required this.playableHeight,
    required this.topOffset,
    required this.progress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.1)
      ..strokeWidth = 1;

    // Vertical lines with parallax
    for (int i = 1; i < 4; i++) {
      final baseX = size.width * (i / 4);
      final x = baseX + sin(progress * 2 * pi) * 5; // Subtle horizontal movement
      canvas.drawLine(
        Offset(x, topOffset),
        Offset(x, topOffset + playableHeight),
        paint,
      );
    }

    // Horizontal lines with parallax
    for (int i = 1; i < 6; i++) {
      final baseY = topOffset + (playableHeight * (i / 6));
      final y = baseY + cos(progress * 2 * pi) * 3; // Subtle vertical movement
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant GridPainter oldDelegate) => true;
}

enum ShapeType { circle, square }

class _FloatingShape {
  final Offset position;
  final double size;
  final double speed;
  final ShapeType type;

  _FloatingShape({
    required this.position,
    required this.size,
    required this.speed,
    required this.type,
  });
}
