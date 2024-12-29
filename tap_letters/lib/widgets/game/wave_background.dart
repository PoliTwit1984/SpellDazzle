import 'package:flutter/material.dart';

class WaveBackground extends StatefulWidget {
  const WaveBackground({super.key});

  @override
  State<WaveBackground> createState() => _WaveBackgroundState();
}

class _WaveBackgroundState extends State<WaveBackground>
    with TickerProviderStateMixin {
  late final List<AnimationController> _controllers;
  
  // Frost-colored waves with higher opacity for visibility
  final List<Color> _colors = [
    const Color(0xFFE1F5FE).withOpacity(0.25), // Frost color with higher opacity
    const Color(0xFFB3E5FC).withOpacity(0.20), // Lighter frost color with higher opacity
  ];

  // Wave positions (relative to screen height)
  final List<double> _positions = [0.30, 0.70]; // Slightly adjusted for better distribution

  @override
  void initState() {
    super.initState();
    
    // Smooth horizontal movement
    _controllers = List.generate(2, (index) {
      return AnimationController(
        vsync: this,
        duration: Duration(seconds: 8 + index * 2), // 8s and 10s for more noticeable movement
      )..repeat(reverse: index == 1); // Second wave oscillates
    });
  }

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: List.generate(2, (index) {
        return AnimatedBuilder(
          animation: _controllers[index],
          builder: (context, child) {
            return CustomPaint(
              size: Size.infinite,
              painter: WavePainter(
                progress: _controllers[index].value,
                color: _colors[index],
                yPosition: _positions[index],
                isReversed: index == 1,
              ),
            );
          },
        );
      }),
    );
  }
}

class WavePainter extends CustomPainter {
  final double progress;
  final Color color;
  final double yPosition;
  final bool isReversed;

  WavePainter({
    required this.progress,
    required this.color,
    required this.yPosition,
    required this.isReversed,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    final path = Path();
    
    // Wave parameters
    final width = size.width;
    final height = size.height;
    final waveHeight = height * 0.06; // Slightly increased height for better visibility
    
    // Calculate control points for the curve
    final startY = height * yPosition;
    final endY = startY;
    
    // Calculate horizontal offset based on animation progress
    final maxOffset = width * 0.4; // 40% of screen width for more noticeable movement
    final xOffset = isReversed
        ? (1 - progress) * maxOffset
        : progress * maxOffset;
    
    // Create a simple curved path
    path.moveTo(0, height);
    path.lineTo(0, startY);
    
    // First curve
    path.quadraticBezierTo(
      width * 0.2 + xOffset,
      startY + waveHeight,
      width * 0.5 + xOffset,
      startY,
    );
    
    // Second curve
    path.quadraticBezierTo(
      width * 0.8 + xOffset,
      startY - waveHeight,
      width,
      endY,
    );
    
    // Complete the path
    path.lineTo(width, height);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(WavePainter oldDelegate) =>
      progress != oldDelegate.progress;
}
