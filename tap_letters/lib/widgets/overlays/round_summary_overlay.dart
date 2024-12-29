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
      duration: const Duration(milliseconds: 5000),
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
      
      final newCountdown = 5 - (_controller.value * 5).floor();
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
          ? 1.0 + (math.sin(_controller.value * math.pi * 4) * 0.1)
          : 1.0;

        return Transform.translate(
          offset: offset * 100,
          child: Opacity(
            opacity: progress,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(isRoundScore ? 0.15 : 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.white.withOpacity(0.2),
                  width: 1,
                ),
                boxShadow: isRoundScore ? [
                  BoxShadow(
                    color: ThemeConstants.primaryColor.withOpacity(0.2),
                    blurRadius: 8,
                    spreadRadius: 2,
                  ),
                ] : [],
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
                        stops: [0.0, 0.7],
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
                    child: ShaderMask(
                      shaderCallback: (bounds) {
                        return LinearGradient(
                          colors: [
                            Colors.white,
                            isRoundScore ? ThemeConstants.accentColor : ThemeConstants.primaryColor,
                          ],
                          stops: [0.0, 0.7],
                        ).createShader(bounds);
                      },
                      child: Text(
                        value,
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
                              color: isRoundScore ? ThemeConstants.accentColor : ThemeConstants.primaryColor,
                              blurRadius: 16,
                              offset: const Offset(0, 0),
                            ),
                          ],
                        ),
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
              return LinearGradient(
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
        final pulseScale = 1.0 + (math.sin(_controller.value * math.pi * 6) * 0.1);
        return Stack(
          alignment: Alignment.center,
          children: [
            Transform.scale(
              scale: (1.0 + (1.0 - _countdownAnimation.value) * 0.5) * pulseScale,
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: ThemeConstants.primaryColor.withOpacity(0.7),
                    width: 3,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: ThemeConstants.primaryColor.withOpacity(0.3),
                      blurRadius: 15,
                      spreadRadius: 5,
                    ),
                  ],
                ),
              ),
            ),
            CircularProgressIndicator(
              value: _countdownAnimation.value,
              strokeWidth: 4,
              valueColor: AlwaysStoppedAnimation<Color>(
                ThemeConstants.primaryColor.withOpacity(0.8 + (math.sin(_controller.value * math.pi * 6) * 0.2)),
              ),
            ),
            _buildPulsingText(
              _countdown.toString(),
              ThemeConstants.headerTextStyle.copyWith(
                fontSize: 36,
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
