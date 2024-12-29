import 'package:flutter/material.dart';
import '../../services/background_engine.dart';

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
    
    // Create new controllers
    _controllers = List.generate(_waveConfigs!.length, (index) {
      return AnimationController(
        vsync: this,
        duration: Duration(seconds: _waveConfigs![index].speed.round()),
      )..repeat(reverse: _waveConfigs![index].direction == WaveDirection.rightToLeft);
    });
  }

  @override
  void initState() {
    super.initState();
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
      children: List.generate(_waveConfigs!.length, (index) {
        final config = _waveConfigs![index];
        return AnimatedBuilder(
          animation: _controllers![index],
          builder: (context, child) {
            return CustomPaint(
              size: Size.infinite,
              painter: WavePainter(
                progress: _controllers![index].value,
                config: config,
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
  final WaveConfig config;

  const WavePainter({
    required this.progress,
    required this.config,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = config.color
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

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

    // Create wave pattern
    var x = 0.0;
    while (x < width + wavelength) {
      path.quadraticBezierTo(
        x + wavelength / 4 + xOffset,
        startY + waveHeight,
        x + wavelength / 2 + xOffset,
        startY,
      );
      path.quadraticBezierTo(
        x + wavelength * 3 / 4 + xOffset,
        startY - waveHeight,
        x + wavelength + xOffset,
        startY,
      );
      x += wavelength;
    }
    
    path.lineTo(width, height);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(WavePainter oldDelegate) =>
      progress != oldDelegate.progress ||
      config != oldDelegate.config;
}
