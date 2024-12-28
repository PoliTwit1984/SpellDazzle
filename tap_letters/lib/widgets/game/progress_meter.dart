import 'dart:math';
import 'package:flutter/material.dart';
import '../../constants/achievement_constants.dart';

class ProgressMeter extends StatefulWidget {
  final int level;
  final int score;
  final int targetScore;
  final VoidCallback onLevelUp;

  const ProgressMeter({
    super.key,
    required this.level,
    required this.score,
    required this.targetScore,
    required this.onLevelUp,
  });

  @override
  State<ProgressMeter> createState() => _ProgressMeterState();
}

class _ProgressMeterState extends State<ProgressMeter> with SingleTickerProviderStateMixin {
  late AnimationController _progressController;
  late Animation<double> _progressAnimation;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _progressController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _glowAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _progressController,
      curve: Curves.easeInOut,
    ));

    _updateProgress();
  }

  @override
  void didUpdateWidget(ProgressMeter oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.score != oldWidget.score) {
      _updateProgress();
    }
  }

  void _updateProgress() {
    final oldProgress = _progressController.value;
    final newProgress = widget.score / widget.targetScore;
    
    _progressAnimation = Tween<double>(
      begin: oldProgress,
      end: newProgress,
    ).animate(CurvedAnimation(
      parent: _progressController,
      curve: Curves.easeOut,
    ));

    _progressController.forward(from: 0);
    
    if (newProgress >= 1.0) {
      widget.onLevelUp();
    }
  }

  @override
  void dispose() {
    _progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 45,
      height: 45,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Level badge
          Container(
            width: 35,
            height: 35,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AchievementConstants.getLevelColor(widget.level),
                  AchievementConstants.getLevelColor(widget.level).withOpacity(0.7),
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFFFD700).withOpacity(0.3),
                  blurRadius: 4,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${widget.level}',
                    style: const TextStyle(
                      fontFamily: 'FredokaOne',
                      fontSize: 14,
                      height: 1.0,
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
                  Text(
                    AchievementConstants.getLevelRank(widget.level),
                    style: const TextStyle(
                      fontFamily: 'FredokaOne',
                      fontSize: 8,
                      height: 1.0,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Progress ring
          AnimatedBuilder(
            animation: _progressController,
            builder: (context, child) {
              return CustomPaint(
                size: const Size(45, 45),
                painter: _ProgressRingPainter(
                  progress: _progressAnimation.value,
                  glowAmount: _glowAnimation.value,
                  level: widget.level,
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _ProgressRingPainter extends CustomPainter {
  final double progress;
  final double glowAmount;
  final int level;

  _ProgressRingPainter({
    required this.progress,
    required this.glowAmount,
    required this.level,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    const strokeWidth = 4.0;

    // Background track
    final trackPaint = Paint()
      ..color = Colors.white.withOpacity(0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius - strokeWidth / 2, trackPaint);

    // Progress arc with gradient and glow
    final rect = Rect.fromCircle(center: center, radius: radius - strokeWidth / 2);
    final gradient = SweepGradient(
      colors: [
        AchievementConstants.getLevelColor(level).withOpacity(0.8),
        AchievementConstants.getLevelColor(level).withOpacity(0.6),
      ],
      stops: const [0.0, 1.0],
      startAngle: -pi / 2,
      endAngle: 3 * pi / 2,
    );

    final progressPaint = Paint()
      ..shader = gradient.createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    // Glow effect
    if (glowAmount > 0) {
      final glowPaint = Paint()
        ..shader = gradient.createShader(rect)
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth + 4 * glowAmount
        ..strokeCap = StrokeCap.round
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);

      canvas.drawArc(
        rect,
        -pi / 2,
        2 * pi * progress,
        false,
        glowPaint,
      );
    }

    // Progress arc
    canvas.drawArc(
      rect,
      -pi / 2,
      2 * pi * progress,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _ProgressRingPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.glowAmount != glowAmount;
  }
}
