import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../../constants/theme_constants.dart';
import '../../constants/layout_constants.dart';

class GameHeader extends StatelessWidget {
  final int level;
  final int score;
  final int timeLeft;
  final GlobalKey? scoreKey;

  const GameHeader({
    super.key,
    required this.level,
    required this.score,
    required this.timeLeft,
    this.scoreKey,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: LayoutConstants.headerHeight,
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Level
          Text(
            'Level $level',
            style: ThemeConstants.headerTextStyle,
          ),
          // Score
          AnimatedScore(
            score: score,
            scoreKey: scoreKey,
          ),
          // Timer
          AnimatedGameTimer(timeLeft: timeLeft),
        ],
      ),
    );
  }
}

class AnimatedScore extends StatefulWidget {
  final int score;
  final GlobalKey? scoreKey;

  const AnimatedScore({
    super.key,
    required this.score,
    this.scoreKey,
  });

  @override
  State<AnimatedScore> createState() => _AnimatedScoreState();
}

class _AnimatedScoreState extends State<AnimatedScore> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late int _lastScore;
  int _scoreDelta = 0;

  @override
  void initState() {
    super.initState();
    _lastScore = widget.score;
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
  }

  @override
  void didUpdateWidget(AnimatedScore oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.score != _lastScore) {
      _scoreDelta = widget.score - _lastScore;
      _lastScore = widget.score;
      _controller.forward(from: 0);
    }
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
        // Animation intensity based on score increase
        final intensity = math.min(_scoreDelta / 10, 1.0); // Cap at 10 points
        
        // Multiple waves for complex pulsing
        final fastPulse = math.sin(_controller.value * math.pi * 8);
        final mediumPulse = math.sin(_controller.value * math.pi * 5);
        final slowPulse = math.sin(_controller.value * math.pi * 3);
        
        // Combined scale effect
        final pulseScale = 1.0 + ((fastPulse * 0.3 + mediumPulse * 0.2 + slowPulse * 0.1) * intensity * (1.0 - _controller.value));
        
        // Shake effect based on score increase
        final shakeIntensity = 5.0 * intensity * (1.0 - _controller.value);
        final shakeX = math.sin(_controller.value * math.pi * 12) * shakeIntensity;
        final shakeY = math.cos(_controller.value * math.pi * 8) * shakeIntensity * 0.5;
        
        // Glow effect that fades out
        final glowOpacity = (0.8 * intensity * (1.0 - _controller.value)) + 0.2;
        
        // Base colors
        final baseColor = ThemeConstants.accentColor;
        final white = Colors.white;
        
        // Calculate glow color with null safety
        final glowOpacityValue = (glowOpacity * 0.5).clamp(0.0, 1.0);
        final borderOpacityValue = 0.3.clamp(0.0, 1.0);
        final backgroundOpacityValue = 0.2.clamp(0.0, 1.0);
        
        // Calculate interpolated color
        final lerpValue = (fastPulse * 0.5 + 0.5).clamp(0.0, 1.0);
        final glowColor = Color.lerp(baseColor, white, lerpValue) ?? baseColor;

        return Transform.translate(
          offset: Offset(shakeX, shakeY),
          child: Transform.scale(
            scale: pulseScale,
            child: Container(
              key: widget.scoreKey,
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 8.0,
              ),
              decoration: BoxDecoration(
                color: baseColor.withOpacity(backgroundOpacityValue),
                borderRadius: BorderRadius.circular(16.0),
                border: Border.all(
                  color: glowColor.withOpacity(borderOpacityValue),
                  width: 1 + (intensity * 1),
                ),
                boxShadow: [
                  BoxShadow(
                    color: glowColor.withOpacity(glowOpacityValue),
                    blurRadius: 10 + (intensity * 10),
                    spreadRadius: 2 + (intensity * 3),
                  ),
                ],
              ),
              child: ShaderMask(
                shaderCallback: (bounds) {
                  return LinearGradient(
                    colors: [
                      Colors.white,
                      glowColor,
                    ],
                    stops: [
                      0.0,
                      math.max(0.0, 1.0 - intensity),
                    ],
                  ).createShader(bounds);
                },
                child: Text(
                  'Score: ${widget.score}',
                  style: ThemeConstants.headerTextStyle.copyWith(
                    color: Colors.white,
                    fontSize: 20 + (intensity * 4),
                    fontWeight: intensity > 0.5 ? FontWeight.w900 : FontWeight.w700,
                    letterSpacing: 1.0 + (intensity * 1.0),
                    shadows: [
                      Shadow(
                        color: glowColor.withOpacity(glowOpacity * 0.7),
                        blurRadius: 8 + (intensity * 8),
                        offset: const Offset(0, 2),
                      ),
                      if (intensity > 0.3)
                        Shadow(
                          color: Colors.white.withOpacity(glowOpacity * 0.5),
                          blurRadius: 12,
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

class AnimatedGameTimer extends StatefulWidget {
  final int timeLeft;

  const AnimatedGameTimer({
    super.key,
    required this.timeLeft,
  });

  @override
  State<AnimatedGameTimer> createState() => _AnimatedGameTimerState();
}

class _AnimatedGameTimerState extends State<AnimatedGameTimer> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final timeLeft = widget.timeLeft;
    final isUrgent = timeLeft <= 5;
    final isWarning = timeLeft <= 10;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        // Scale and intensity increase as time decreases
        final progress = timeLeft / 30.0; // Assuming 30 second rounds
        final inverseProgress = 1.0 - progress;
        
        // Base values increase as time decreases
        final baseScale = 1.0 + (inverseProgress * 0.3); // 1.0 to 1.3
        final pulseIntensity = 0.05 + (inverseProgress * 0.2); // 0.05 to 0.25
        final pulseFrequency = 2.0 + (inverseProgress * 8.0); // 2.0 to 10.0
        
        // Multiple waves for complex pulsing
        final fastPulse = math.sin(_controller.value * math.pi * pulseFrequency);
        final slowPulse = math.sin(_controller.value * math.pi * (pulseFrequency * 0.5));
        final pulseScale = baseScale + ((fastPulse * 0.7 + slowPulse * 0.3) * pulseIntensity);
        
        // Progressive shake effect
        final shakeIntensity = isUrgent ? 3.0 : (isWarning ? 1.5 : 0.0);
        final shakeX = (isUrgent || isWarning)
          ? math.sin(_controller.value * math.pi * pulseFrequency * 2) * shakeIntensity
          : 0.0;
        
        // Dynamic glow effect
        final glowOpacity = 0.2 + (inverseProgress * 0.3) + (fastPulse * 0.1);
        
        // Smooth color transition
        final Color color;
        if (timeLeft <= 5) {
          color = ThemeConstants.dangerColor;
        } else if (timeLeft <= 10) {
          final warningProgress = (timeLeft - 5) / 5.0;
          color = Color.lerp(ThemeConstants.dangerColor, Colors.orange, warningProgress) ?? Colors.orange;
        } else {
          final normalProgress = (timeLeft - 10) / 20.0;
          color = Color.lerp(Colors.orange, Colors.white, normalProgress) ?? Colors.white;
        }

        return Transform.translate(
          offset: Offset(shakeX, 0),
          child: Transform.scale(
            scale: pulseScale,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 8.0,
              ),
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(16.0),
                border: Border.all(
                  color: color.withOpacity(0.3),
                  width: isUrgent ? 2 : 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: color.withOpacity(glowOpacity),
                    blurRadius: isUrgent ? 15 : (isWarning ? 10 : 5),
                    spreadRadius: isUrgent ? 2 : 1,
                  ),
                ],
              ),
              child: Text(
                '$timeLeft',
                style: ThemeConstants.headerTextStyle.copyWith(
                  color: color,
                  fontSize: isUrgent ? 28 : (isWarning ? 24 : 20),
                  fontWeight: isUrgent ? FontWeight.w900 : (isWarning ? FontWeight.w800 : FontWeight.w700),
                  letterSpacing: isUrgent ? 2.0 : (isWarning ? 1.5 : 1.0),
                  shadows: [
                    Shadow(
                      color: color.withOpacity(0.5),
                      blurRadius: isUrgent ? 10 : (isWarning ? 8 : 6),
                      offset: const Offset(0, 2),
                    ),
                    if (isUrgent || isWarning)
                      Shadow(
                        color: ThemeConstants.dangerColor.withOpacity(glowOpacity),
                        blurRadius: 8,
                        offset: const Offset(0, 0),
                      ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
