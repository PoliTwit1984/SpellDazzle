import 'package:flutter/material.dart';
import 'dart:ui';
import 'dart:math' as math;
import '../../constants/theme_constants.dart';

class RoundSummaryOverlay extends StatefulWidget {
  final int roundScore;
  final String bestWord;
  final int bestWordScore;
  final int nextLevel;
  final VoidCallback onContinue;

  const RoundSummaryOverlay({
    super.key,
    required this.roundScore,
    required this.bestWord,
    required this.bestWordScore,
    required this.nextLevel,
    required this.onContinue,
  });

  @override
  State<RoundSummaryOverlay> createState() => _RoundSummaryOverlayState();
}

class _RoundSummaryOverlayState extends State<RoundSummaryOverlay> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _pulseAnimation;
  late Animation<double> _countdownAnimation;
  int _countdown = 5;
  bool _showScores = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 10000),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    _countdownAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.linear,
    ));

    _controller.addListener(() {
      if (_controller.value >= 0.05) {
        setState(() {
          _showScores = true;
        });
      }
      
      final newCountdown = 10 - (_controller.value * 10).floor();
      if (newCountdown != _countdown) {
        setState(() {
          _countdown = newCountdown;
        });
      }
      
      if (_controller.value == 1.0) {
        widget.onContinue();
      }
    });

    Future.delayed(const Duration(milliseconds: 100), () {
      _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _buildAnimatedScore(String label, String value, TextStyle style, {Offset? startOffset, Duration? delay, bool isRoundScore = false}) {
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

        final scoreScale = isRoundScore 
          ? 1.0 + (math.sin(_controller.value * math.pi * 6) * 0.15)
          : 1.0;

        final glowOpacity = isRoundScore
          ? (0.5 + (math.sin(_controller.value * math.pi * 4) * 0.3)).clamp(0.0, 1.0)
          : 0.0;

        final containerScale = isRoundScore
          ? 1.0 + (math.sin(_controller.value * math.pi * 3) * 0.05)
          : 1.0;

        return Transform.translate(
          offset: offset * 100,
          child: Opacity(
            opacity: progress,
            child: Transform.scale(
              scale: containerScale,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0x33FFFFFF), // Fixed 0.2 opacity white
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0x33FFFFFF), // Fixed 0.2 opacity white
                    width: 1,
                  ),
                  boxShadow: [
                    if (isRoundScore) ...[
                      BoxShadow(
                        color: ThemeConstants.primaryColor.withOpacity(0.3),
                        blurRadius: 12,
                        spreadRadius: 2,
                      ),
                      BoxShadow(
                        color: ThemeConstants.accentColor.withOpacity(glowOpacity),
                        blurRadius: 20,
                        spreadRadius: 4,
                      ),
                    ],
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ShaderMask(
                      shaderCallback: (bounds) {
                        return LinearGradient(
                          colors: [
                            Colors.white,
                            ThemeConstants.primaryColor,
                          ],
                          stops: const [0.0, 0.7],
                        ).createShader(bounds);
                      },
                      child: Text(
                        label,
                        style: style.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                          shadows: [
                            Shadow(
                              color: Colors.black,
                              blurRadius: 12,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Transform.scale(
                      scale: scoreScale,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: isRoundScore ? BoxDecoration(
                          color: const Color(0x1AFFFFFF), // Fixed 0.1 opacity white
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: [
                            BoxShadow(
                              color: ThemeConstants.accentColor.withOpacity(glowOpacity * 0.5),
                              blurRadius: 8,
                              spreadRadius: 2,
                            ),
                          ],
                        ) : null,
                        child: ShaderMask(
                          shaderCallback: (bounds) {
                            return LinearGradient(
                              colors: [
                                Colors.white,
                                isRoundScore ? ThemeConstants.accentColor : ThemeConstants.primaryColor,
                              ],
                              stops: const [0.0, 0.7],
                            ).createShader(bounds);
                          },
                          child: Text(
                            value,
                            style: style.copyWith(
                              color: Colors.white,
                              fontWeight: isRoundScore ? FontWeight.w800 : FontWeight.w700,
                              letterSpacing: isRoundScore ? 1.2 : 1.0,
                              shadows: [
                                Shadow(
                                  color: Colors.black,
                                  blurRadius: 12,
                                  offset: const Offset(0, 2),
                                ),
                                Shadow(
                                  color: isRoundScore ? ThemeConstants.accentColor : ThemeConstants.primaryColor,
                                  blurRadius: 16,
                                  offset: const Offset(0, 0),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
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

  Widget _buildPulsingText(String text, TextStyle style) {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: 1.0 + (math.sin(_controller.value * math.pi * 3) * 0.15),
          child: ShaderMask(
            shaderCallback: (bounds) {
              return LinearGradient(
                colors: [
                  Colors.white,
                  ThemeConstants.primaryColor,
                ],
                stops: const [0.0, 0.7],
              ).createShader(bounds);
            },
            child: Text(
              text,
              style: style.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                shadows: [
                  Shadow(
                    color: Colors.black,
                    blurRadius: 12,
                    offset: const Offset(0, 2),
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

  Widget _buildCountdown() {
    return AnimatedBuilder(
      animation: _countdownAnimation,
      builder: (context, child) {
        final timeLeft = _countdown;
        final isUrgent = timeLeft <= 3;
        final isWarning = timeLeft <= 7;
        
        // Scale and intensity increase as time decreases
        final progress = timeLeft / 10.0; // 0.0 to 1.0
        final inverseProgress = 1.0 - progress;
        
        // Base values increase as time decreases
        final baseScale = 1.0 + (inverseProgress * 0.5); // 1.0 to 1.5
        final pulseIntensity = 0.1 + (inverseProgress * 0.3); // 0.1 to 0.4
        final pulseFrequency = 6.0 + (inverseProgress * 18.0); // 6.0 to 24.0
        
        // Multiple waves for complex pulsing
        final fastPulse = math.sin(_controller.value * math.pi * pulseFrequency);
        final mediumPulse = math.sin(_controller.value * math.pi * (pulseFrequency * 0.7));
        final slowPulse = math.sin(_controller.value * math.pi * (pulseFrequency * 0.4));
        final pulseScale = baseScale + ((fastPulse * 0.5 + mediumPulse * 0.3 + slowPulse * 0.2) * pulseIntensity);
        
        // Progressive shake effect
        final shakeIntensity = inverseProgress * 12.0; // 0.0 to 12.0
        final shakeX = isUrgent || isWarning 
          ? math.sin(_controller.value * math.pi * pulseFrequency * 2) * shakeIntensity
          : 0.0;
        final shakeY = isUrgent || isWarning
          ? math.cos(_controller.value * math.pi * pulseFrequency * 2) * shakeIntensity
          : 0.0;
        
        // Dynamic glow effect
        final glowOpacity = (0.3 + (inverseProgress * 0.5) + (fastPulse * 0.2)).clamp(0.0, 1.0);
        
        // Smooth color transition
        final Color color;
        if (timeLeft <= 3) {
          color = ThemeConstants.dangerColor;
        } else if (timeLeft <= 7) {
          final warningProgress = (timeLeft - 3) / 4.0;
          color = Color.lerp(ThemeConstants.dangerColor, Colors.orange, warningProgress) ?? Colors.orange;
        } else {
          final normalProgress = (timeLeft - 7) / 3.0;
          color = Color.lerp(Colors.orange, Colors.white, normalProgress) ?? Colors.white;
        }
        return Stack(
          alignment: Alignment.center,
          children: [
            Transform.scale(
              scale: pulseScale,
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: color.withOpacity((isUrgent ? 0.9 : (isWarning ? 0.8 : 0.7)).clamp(0.0, 1.0)),
                    width: isUrgent ? 5 : (isWarning ? 4 : 3),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: color.withOpacity(glowOpacity),
                      blurRadius: isUrgent ? 30 : (isWarning ? 20 : 15),
                      spreadRadius: isUrgent ? 10 : (isWarning ? 7 : 5),
                    ),
                    if (isUrgent || isWarning)
                      BoxShadow(
                        color: ThemeConstants.dangerColor.withOpacity(glowOpacity * 0.5),
                        blurRadius: isUrgent ? 25 : 15,
                        spreadRadius: isUrgent ? 12 : 8,
                      ),
                  ],
                ),
              ),
            ),
            CircularProgressIndicator(
              value: _countdownAnimation.value,
              strokeWidth: isUrgent ? 6 : (isWarning ? 5 : 4),
              valueColor: AlwaysStoppedAnimation<Color>(
                color.withOpacity((0.8 + (fastPulse * 0.2)).clamp(0.0, 1.0)),
              ),
            ),
            Transform.translate(
              offset: Offset(shakeX, shakeY),
              child: Transform.scale(
                scale: isUrgent ? 1.3 : (isWarning ? 1.2 : 1.0),
                child: _buildPulsingText(
                  _countdown.toString(),
                  ThemeConstants.headerTextStyle.copyWith(
                    fontSize: 36 + (inverseProgress * 24), // 36 to 60
                    color: color,
                    letterSpacing: 1.0 + (inverseProgress * 3.0), // 1.0 to 4.0
                    fontWeight: isUrgent ? FontWeight.w900 : (isWarning ? FontWeight.w800 : FontWeight.w700),
                    shadows: [
                      Shadow(
                        color: color.withOpacity(0.8),
                        blurRadius: 10 + (inverseProgress * 20),
                        offset: const Offset(0, 2),
                      ),
                      if (isWarning || isUrgent)
                        Shadow(
                          color: ThemeConstants.dangerColor.withOpacity(glowOpacity * 0.5),
                          blurRadius: 20,
                          offset: const Offset(0, 0),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            const Color(0x66000000), // Fixed 0.4 opacity black
            ThemeConstants.letterColors[0].withOpacity(0.2),
            ThemeConstants.letterColors[2].withOpacity(0.1),
          ],
          stops: const [0.0, 0.6, 1.0],
        ),
      ),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 30.0, sigmaY: 30.0),
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
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          const Color(0x33FFFFFF), // Fixed 0.2 opacity white
                          const Color(0x0DFFFFFF), // Fixed 0.05 opacity white
                          const Color(0x05FFFFFF), // Fixed 0.02 opacity white
                        ],
                        stops: const [0.0, 0.6, 1.0],
                      ),
                      borderRadius: BorderRadius.circular(32.0),
                      border: Border.all(
                        color: const Color(0x33FFFFFF), // Fixed 0.2 opacity white
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: ThemeConstants.letterColors[0].withOpacity(0.3),
                          blurRadius: 40,
                          spreadRadius: -5,
                        ),
                        BoxShadow(
                          color: ThemeConstants.letterColors[2].withOpacity(0.2),
                          blurRadius: 30,
                          spreadRadius: 5,
                        ),
                        BoxShadow(
                          color: const Color(0x80000000), // Fixed 0.5 opacity black
                          blurRadius: 25,
                          spreadRadius: -10,
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildPulsingText(
                          'Round Complete!',
                          ThemeConstants.headerTextStyle,
                        ),
                        const SizedBox(height: 24),
                        if (_showScores) ...[
                          _buildAnimatedScore(
                            'Round Score:', 
                            '${widget.roundScore}',
                            ThemeConstants.scoreTextStyle.copyWith(
                              fontSize: 24,
                            ),
                            startOffset: const Offset(-1, 0),
                            delay: const Duration(milliseconds: 100),
                            isRoundScore: true,
                          ),
                          const SizedBox(height: 16),
                          _buildAnimatedScore(
                            'Best Word:', 
                            widget.bestWord,
                            ThemeConstants.scoreTextStyle.copyWith(
                              fontSize: 20,
                            ),
                            startOffset: const Offset(1, 0),
                            delay: const Duration(milliseconds: 200),
                          ),
                          _buildAnimatedScore(
                            'Word Score:', 
                            '${widget.bestWordScore}',
                            ThemeConstants.scoreTextStyle.copyWith(
                              fontSize: 18,
                            ),
                            startOffset: const Offset(-1, 0),
                            delay: const Duration(milliseconds: 300),
                          ),
                          const SizedBox(height: 32),
                          _buildAnimatedScore(
                            'Starting Level', 
                            '${widget.nextLevel}',
                            ThemeConstants.scoreTextStyle.copyWith(
                              fontSize: 20,
                            ),
                            startOffset: const Offset(1, 0),
                            delay: const Duration(milliseconds: 400),
                          ),
                        ],
                        const SizedBox(height: 24),
                        _buildCountdown(),
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
