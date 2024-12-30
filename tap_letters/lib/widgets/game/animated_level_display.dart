import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../../constants/theme_constants.dart';

class AnimatedLevelDisplay extends StatefulWidget {
  final int level;

  const AnimatedLevelDisplay({
    super.key,
    required this.level,
  });

  @override
  State<AnimatedLevelDisplay> createState() => _AnimatedLevelDisplayState();
}

class _AnimatedLevelDisplayState extends State<AnimatedLevelDisplay> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<Animation<double>> _scaleAnimations;
  late List<Animation<double>> _rotationAnimations;
  final random = math.Random();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    // Create animations for each character
    final text = 'Level ${widget.level}';
    final letterCount = text.length;
    
    // Calculate delays to fit within 0.0-1.0
    final delayPerLetter = 0.5 / letterCount;
    
    _scaleAnimations = List.generate(text.length, (index) {
      final delay = index * delayPerLetter;
      return TweenSequence([
        TweenSequenceItem(
          tween: Tween<double>(begin: 0.0, end: 1.2)
              .chain(CurveTween(curve: Curves.elasticOut)),
          weight: 70,
        ),
        TweenSequenceItem(
          tween: Tween<double>(begin: 1.2, end: 1.0)
              .chain(CurveTween(curve: Curves.easeOut)),
          weight: 30,
        ),
      ]).animate(CurvedAnimation(
        parent: _controller,
        curve: Interval(delay, math.min(1.0, delay + 0.3)),
      ));
    });

    // Create wobble animations with random offsets
    _rotationAnimations = List.generate(text.length, (index) {
      final frequency = 0.8 + random.nextDouble() * 0.4; // 0.8-1.2 Hz
      final phase = random.nextDouble() * 2 * math.pi; // Random start phase
      final amplitude = 0.05 + random.nextDouble() * 0.03; // ±0.05-0.08 radians (±2.9-4.6 degrees)
      
      return Tween<double>(begin: -amplitude, end: amplitude).animate(
        CurvedAnimation(
          parent: _controller,
          curve: SineCurve(frequency: frequency, phase: phase),
        ),
      );
    });

    // Initial pop-in animation followed by gentle continuous animation
    _controller.forward().then((_) {
      _controller.duration = const Duration(milliseconds: 4000);
      _controller.repeat(reverse: true);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Color _getBaseColor(String letter, int index) {
    if (letter == ' ') return Colors.transparent;
    
    // Use different colors for Level vs Number
    if (index < 5) { // "Level" part
      const vowels = {'a', 'e', 'i', 'o', 'u', 'A', 'E', 'I', 'O', 'U'};
      if (vowels.contains(letter)) {
        return ThemeConstants.letterColors[2]; // Orange for vowels
      }
      return ThemeConstants.letterColors[0]; // Blue for consonants
    } else { // Number part
      return ThemeConstants.letterColors[4]; // Cyan for numbers
    }
  }

  List<Color> _getGradientColors(Color baseColor, int index) {
    final hsl = HSLColor.fromColor(baseColor);
    
    // More dramatic gradients for numbers
    final isNumber = index >= 5;
    
    // Vary saturation and lightness
    final saturation = (hsl.saturation * (0.8 + random.nextDouble() * 0.4)).clamp(0.0, 1.0);
    final lightness = (hsl.lightness * (1.2 + random.nextDouble() * 0.3)).clamp(0.0, 1.0);
    final middleColor = hsl.withSaturation(saturation).withLightness(lightness).toColor();
    
    // Add shimmer effect
    final shimmerColor = Color.lerp(baseColor, Colors.white, isNumber ? 0.4 : 0.2) ?? baseColor;
    
    return [
      baseColor,
      middleColor,
      shimmerColor,
    ];
  }

  @override
  Widget build(BuildContext context) {
    final text = 'Level ${widget.level}';
    
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(text.length, (index) {
        final baseColor = _getBaseColor(text[index], index);
        final gradientColors = _getGradientColors(baseColor, index);
        final isNumber = index >= 5;
        
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: isNumber ? 1.0 : 0.5),
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Transform.rotate(
                angle: _rotationAnimations[index].value,
                child: Transform.scale(
                  scale: _scaleAnimations[index].value,
                  child: ShaderMask(
                    shaderCallback: (bounds) {
                      return LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: gradientColors,
                        stops: const [0.0, 0.5, 0.8],
                      ).createShader(bounds);
                    },
                    child: Text(
                      text[index],
                      style: ThemeConstants.headerTextStyle.copyWith(
                        fontSize: isNumber ? 24 : 20,
                        fontWeight: FontWeight.w800,
                        shadows: [
                          Shadow(
                            color: baseColor.withOpacity(0.6),
                            blurRadius: 12,
                            offset: const Offset(0, 2),
                          ),
                          const Shadow(
                            color: Color(0x4D000000), // 0.3 opacity black
                            blurRadius: 4,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        );
      }),
    );
  }
}

class SineCurve extends Curve {
  final double frequency;
  final double phase;

  const SineCurve({
    this.frequency = 1.0,
    this.phase = 0.0,
  });

  @override
  double transformInternal(double t) {
    return math.sin(2 * math.pi * frequency * t + phase);
  }
}
