import 'package:flutter/material.dart';
import '../../services/background_engine.dart';
import 'dart:ui' as ui;

class WaveBackground extends StatefulWidget {
  final int roundNumber;
  
  const WaveBackground({
    super.key,
    required this.roundNumber,
  });

  @override
  State<WaveBackground> createState() => _WaveBackgroundState();
}

class _WaveBackgroundState extends State<WaveBackground>
    with TickerProviderStateMixin {
  List<AnimationController>? _controllers;
  List<WaveConfig>? _waveConfigs;
  late AnimationController _glowController;
  late Animation<double> _glowAnimation;

  void _setupWaves() {
    // Clean up existing controllers
    if (_controllers != null) {
      for (final controller in _controllers!) {
        controller.stop();
        controller.dispose();
      }
      _controllers = null;
    }

    // Generate new configurations
    _waveConfigs = BackgroundEngine.generateWaveConfigs(widget.roundNumber);
    
    // Create new controllers with varying speeds for parallax effect
    _controllers = List.generate(_waveConfigs!.length, (index) {
      final baseSpeed = _waveConfigs![index].speed.round();
      // Slower waves in back, faster in front
      final adjustedSpeed = baseSpeed + (index * 2);
      
      return AnimationController(
        vsync: this,
        duration: Duration(seconds: adjustedSpeed),
      )..repeat(reverse: _waveConfigs![index].direction == WaveDirection.rightToLeft);
    });
  }

  @override
  void initState() {
    super.initState();
    
    // Setup glow animation
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    );
    
    _glowAnimation = TweenSequence([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.3, end: 0.6)
            .chain(CurveTween(curve: Curves.easeInOut)),
        weight: 50,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.6, end: 0.3)
            .chain(CurveTween(curve: Curves.easeInOut)),
        weight: 50,
      ),
    ]).animate(_glowController);
    
    _glowController.repeat();
    _setupWaves();
  }

  @override
  void didUpdateWidget(WaveBackground oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.roundNumber != oldWidget.roundNumber) {
      _setupWaves();
    }
  }

  @override
  void dispose() {
    _glowController.dispose();
    if (_controllers != null) {
      for (final controller in _controllers!) {
        controller.stop();
        controller.dispose();
      }
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_controllers == null || _waveConfigs == null) {
      return const SizedBox.shrink();
    }

    return Stack(
      children: [
        // Animated gradient background
        AnimatedBuilder(
          animation: _glowAnimation,
          builder: (context, child) {
            return Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    _waveConfigs![0].color.withOpacity((_glowAnimation.value * 0.2).clamp(0.0, 1.0)),
                    _waveConfigs![1].color.withOpacity((_glowAnimation.value * 0.3).clamp(0.0, 1.0)),
                    _waveConfigs![2].color.withOpacity((_glowAnimation.value * 0.4).clamp(0.0, 1.0)),
                    _waveConfigs![3].color.withOpacity((_glowAnimation.value * 0.5).clamp(0.0, 1.0)),
                  ],
                  stops: const [0.0, 0.4, 0.6, 0.8, 1.0],
                ),
              ),
            );
          },
        ),
        // Waves with parallax effect
        ...List.generate(_waveConfigs!.length, (index) {
          final config = _waveConfigs![index];
          return AnimatedBuilder(
            animation: _controllers![index],
            builder: (context, child) {
              return CustomPaint(
                size: Size.infinite,
                painter: WavePainter(
                  progress: _controllers![index].value,
                  config: config,
                  glowOpacity: _glowAnimation.value,
                  isTopWave: index == _waveConfigs!.length - 1,
                ),
              );
            },
          );
        }),
      ],
    );
  }
}

class WavePainter extends CustomPainter {
  final double progress;
  final WaveConfig config;
  final double glowOpacity;
  final bool isTopWave;

  const WavePainter({
    required this.progress,
    required this.config,
    required this.glowOpacity,
    required this.isTopWave,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = config.color
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    // Apply depth-based effects
    final depthFactor = config.depth / 3; // 0.0 to 1.0
    if (config.depth > 0) {
      final blurAmount = 2.0 + (depthFactor * 4.0); // 2-6
      paint.maskFilter = MaskFilter.blur(BlurStyle.normal, blurAmount);
      paint.imageFilter = ui.ImageFilter.blur(
        sigmaX: blurAmount,
        sigmaY: blurAmount,
      );
    }

    final path = Path();
    
    final width = size.width;
    final height = size.height;
    final waveHeight = height * config.amplitude;
    final wavelength = width * config.wavelength;
    
    final startY = height * config.yPosition;
    final maxOffset = width * 0.4;
    final xOffset = config.direction == WaveDirection.rightToLeft
        ? (1 - progress) * maxOffset
        : progress * maxOffset;
    
    path.moveTo(0, height);
    path.lineTo(0, startY);

    // Create wave pattern with smoother curves
    var x = 0.0;
    while (x < width + wavelength) {
      path.cubicTo(
        x + wavelength / 4 + xOffset,
        startY + waveHeight,
        x + wavelength / 2 + xOffset - wavelength / 8,
        startY,
        x + wavelength / 2 + xOffset,
        startY,
      );
      path.cubicTo(
        x + wavelength / 2 + xOffset + wavelength / 8,
        startY,
        x + wavelength * 3 / 4 + xOffset,
        startY - waveHeight,
        x + wavelength + xOffset,
        startY,
      );
      x += wavelength;
    }
    
    path.lineTo(width, height);
    path.close();

    // Draw glow effect with depth-based intensity
    if (config.depth > 0) {
      final glowIntensity = (0.2 + (depthFactor * 0.3)).clamp(0.0, 1.0); // 0.2-0.5
      final glowPaint = Paint()
        ..color = config.color.withOpacity((glowOpacity * glowIntensity).clamp(0.0, 1.0))
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2 + (depthFactor * 4) // 2-6
        ..maskFilter = MaskFilter.blur(
          BlurStyle.normal,
          4 + (depthFactor * 8), // 4-12
        );
      canvas.drawPath(path, glowPaint);
      
      // Additional inner glow for front waves
      if (config.depth > 1) {
        final innerGlowPaint = Paint()
          ..color = config.color.withOpacity((glowOpacity * glowIntensity * 0.7).clamp(0.0, 1.0))
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1 + (depthFactor * 2) // 1-3
          ..maskFilter = MaskFilter.blur(
            BlurStyle.normal,
            2 + (depthFactor * 4), // 2-6
          );
        canvas.drawPath(path, innerGlowPaint);
      }
    }

    // Draw main wave
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(WavePainter oldDelegate) =>
      progress != oldDelegate.progress ||
      config != oldDelegate.config ||
      glowOpacity != oldDelegate.glowOpacity;
}
