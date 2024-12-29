import 'package:flutter/material.dart';
import 'dart:math';

class BackgroundEngine {
  static final List<Color> complementaryColors = [
    const Color(0xFFFFB6C1), // Light pink
    const Color(0xFFFFDAB9), // Peach
    const Color(0xFFE0FFFF), // Light cyan
    const Color(0xFFB0E0E6), // Powder blue
    const Color(0xFFE6E6FA), // Lavender
    const Color(0xFFF0E68C), // Khaki
    const Color(0xFF98FB98), // Mint green
    const Color(0xFFDDA0DD), // Plum
  ];

  static List<WaveConfig> generateWaveConfigs(int roundNumber) {
    final random = Random(roundNumber); // Use round number as seed for consistency
    final List<WaveConfig> configs = [];
    
    // Get three unique colors
    final availableColors = List<Color>.from(complementaryColors);
    availableColors.shuffle(random);
    final selectedColors = availableColors.take(3).toList();
    
    // Create three waves with different positions and shapes
    for (int i = 0; i < 3; i++) {
      configs.add(WaveConfig(
        color: selectedColors[i].withOpacity(0.12 + random.nextDouble() * 0.08),
        yPosition: 0.35 + (i * 0.15) + random.nextDouble() * 0.05,
        amplitude: 0.03 + random.nextDouble() * 0.02,
        wavelength: 0.35 + random.nextDouble() * 0.15,
        speed: 10.0 + random.nextDouble() * 5.0,
        direction: i % 2 == 0 ? WaveDirection.leftToRight : WaveDirection.rightToLeft,
      ));
    }
    
    return configs;
  }
}

enum WaveDirection {
  leftToRight,
  rightToLeft,
}

class WaveConfig {
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WaveConfig &&
          runtimeType == other.runtimeType &&
          color == other.color &&
          yPosition == other.yPosition &&
          amplitude == other.amplitude &&
          wavelength == other.wavelength &&
          speed == other.speed &&
          direction == other.direction;

  @override
  int get hashCode =>
      color.hashCode ^
      yPosition.hashCode ^
      amplitude.hashCode ^
      wavelength.hashCode ^
      speed.hashCode ^
      direction.hashCode;
  final Color color;
  final double yPosition;
  final double amplitude;
  final double wavelength;
  final double speed;
  final WaveDirection direction;

  WaveConfig({
    required this.color,
    required this.yPosition,
    required this.amplitude,
    required this.wavelength,
    required this.speed,
    required this.direction,
  });
}
