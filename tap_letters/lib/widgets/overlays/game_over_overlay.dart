import 'package:flutter/material.dart';
import 'dart:ui';
import 'dart:math' as math;
import '../../constants/theme_constants.dart';

class GameOverOverlay extends StatefulWidget {
  final int finalScore;
  final int level;
  final VoidCallback onRestart;

  const GameOverOverlay({
    super.key,
    required this.finalScore,
    required this.level,
    required this.onRestart,
  });

  @override
  State<GameOverOverlay> createState() => _GameOverOverlayState();
}

class _GameOverOverlayState extends State<GameOverOverlay> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _pulseAnimation;
  bool _showScores = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    _controller.addListener(() {
      if (_controller.value >= 0.05) {
        setState(() {
          _showScores = true;
        });
      }
    });

    _controller.repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _buildAnimatedScore(String label, String value, TextStyle style, {Offset? startOffset, Duration? delay}) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final delaySeconds = (delay ?? Duration.zero).inMilliseconds / 500;
        final adjustedValue = math.max(0.0, (_controller.value - delaySeconds) * 4.0);
        final progress = math.min(1.0, adjustedValue);
        
        final offset = Offset.lerp(
          startOffset ?? const Offset(-1, 0),
          Offset.zero,
          Curves.elasticOut.transform(progress),
        ) ?? Offset.zero;

        final glowOpacity = 0.5 + (math.sin(_controller.value * math.pi * 4) * 0.3);

        return Transform.translate(
          offset: offset * 100,
          child: Opacity(
            opacity: progress,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.white.withOpacity(0.2),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: ThemeConstants.primaryColor.withOpacity(0.3),
                    blurRadius: 12,
                    spreadRadius: 2,
                  ),
                  BoxShadow(
                    color: ThemeConstants.accentColor.withOpacity(glowOpacity * 0.3),
                    blurRadius: 20,
                    spreadRadius: 4,
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ShaderMask(
                    shaderCallback: (bounds) {
                      return const LinearGradient(
                        colors: [
                          Colors.white,
                          ThemeConstants.primaryColor,
                        ],
                        stops: [0.0, 0.7],
                      ).createShader(bounds);
                    },
                    child: Text(
                      label,
                      style: style.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                        shadows: [
                          const Shadow(
                            color: Colors.black,
                            blurRadius: 12,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ShaderMask(
                    shaderCallback: (bounds) {
                      return const LinearGradient(
                        colors: [
                          Colors.white,
                          ThemeConstants.accentColor,
                        ],
                        stops: [0.0, 0.7],
                      ).createShader(bounds);
                    },
                    child: Text(
                      value,
                      style: style.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.2,
                        shadows: [
                          const Shadow(
                            color: Colors.black,
                            blurRadius: 12,
                            offset: Offset(0, 2),
                          ),
                          const Shadow(
                            color: ThemeConstants.accentColor,
                            blurRadius: 16,
                            offset: Offset(0, 0),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildPulsingText(String text, TextStyle style) {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: 1.0 + (math.sin(_controller.value * math.pi * 3) * 0.15),
          child: ShaderMask(
            shaderCallback: (bounds) {
              return const LinearGradient(
                colors: [
                  Colors.white,
                  ThemeConstants.primaryColor,
                ],
                stops: [0.0, 0.7],
              ).createShader(bounds);
            },
            child: Text(
              text,
              style: style.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                shadows: [
                  const Shadow(
                    color: Colors.black,
                    blurRadius: 12,
                    offset: Offset(0, 2),
                  ),
                  Shadow(
                    color: ThemeConstants.primaryColor,
                    blurRadius: 16 + (math.sin(_controller.value * math.pi * 3) * 6),
                    offset: const Offset(0, 0),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildPlayButton() {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final scale = 1.0 + (math.sin(_controller.value * math.pi * 2) * 0.05);
        final glowOpacity = 0.5 + (math.sin(_controller.value * math.pi * 3) * 0.3);
        
        return Transform.scale(
          scale: scale,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: ThemeConstants.accentColor.withOpacity(glowOpacity * 0.3),
                  blurRadius: 20,
                  spreadRadius: 4,
                ),
              ],
            ),
            child: ElevatedButton(
              onPressed: widget.onRestart,
              style: ElevatedButton.styleFrom(
                backgroundColor: ThemeConstants.accentColor,
                padding: const EdgeInsets.symmetric(
                  horizontal: 40,
                  vertical: 20,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: ShaderMask(
                shaderCallback: (bounds) {
                  return LinearGradient(
                    colors: [
                      Colors.white,
                      Colors.white.withOpacity(0.8),
                    ],
                    stops: [
                      _controller.value,
                      _controller.value + 0.5,
                    ],
                  ).createShader(bounds);
                },
                child: const Text(
                  'Play Again',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    shadows: [
                      Shadow(
                        color: Colors.black26,
                        blurRadius: 8,
                        offset: Offset(0, 2),
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

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: ThemeConstants.backgroundGradient.scale(0.8),
        color: Colors.black.withOpacity(0.4),
      ),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
        child: Center(
          child: TweenAnimationBuilder(
            duration: const Duration(milliseconds: 300),
            tween: Tween<double>(begin: 0.0, end: 1.0),
            builder: (context, double value, child) {
              return Transform.scale(
                scale: 0.8 + (0.2 * value),
                child: Opacity(
                  opacity: value,
                  child: Container(
                    margin: const EdgeInsets.all(32.0),
                    padding: const EdgeInsets.all(24.0),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(16.0),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.3),
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.4),
                          blurRadius: 20,
                          spreadRadius: 10,
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildPulsingText(
                          'Game Over',
                          ThemeConstants.headerTextStyle.copyWith(
                            fontSize: 36,
                          ),
                        ),
                        const SizedBox(height: 32),
                        if (_showScores) ...[
                          _buildAnimatedScore(
                            'Final Score:', 
                            '${widget.finalScore}',
                            ThemeConstants.scoreTextStyle.copyWith(
                              fontSize: 28,
                            ),
                            startOffset: const Offset(-1, 0),
                            delay: const Duration(milliseconds: 100),
                          ),
                          const SizedBox(height: 16),
                          _buildAnimatedScore(
                            'Level Reached:', 
                            '${widget.level}',
                            ThemeConstants.scoreTextStyle.copyWith(
                              fontSize: 24,
                            ),
                            startOffset: const Offset(1, 0),
                            delay: const Duration(milliseconds: 300),
                          ),
                          const SizedBox(height: 40),
                          _buildPlayButton(),
                        ],
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
