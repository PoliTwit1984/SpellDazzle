import 'package:flutter/material.dart';
import 'dart:math';

class BackgroundEngine {
  static final List<Color> complementaryColors = [
    const Color(0xFF87CEEB), // Sky blue
    const Color(0xFF98FB98), // Mint green
    const Color(0xFFFFB6C1), // Light pink
    const Color(0xFFE6E6FA), // Lavender
    const Color(0xFFB0E0E6), // Powder blue
    const Color(0xFFFFDAB9), // Peach
    const Color(0xFF87CEFA), // Light sky blue
    const Color(0xFFDDA0DD), // Plum
  ];

  static List<WaveConfig> generateWaveConfigs(int roundNumber) {
    final random = Random(roundNumber); // Use round number as seed for consistency
    final List<WaveConfig> configs = [];
    
    // Get four unique colors for more depth
    final availableColors = List<Color>.from(complementaryColors);
    availableColors.shuffle(random);
    final selectedColors = availableColors.take(4).toList();
    
    // Create waves with increasing complexity and speed from back to front
    for (int i = 0; i < 4; i++) {
      final isBackWave = i < 2;
      final isFrontWave = i == 3;
      
      // Base opacity increases for waves closer to front
      final baseOpacity = isBackWave ? 0.15 : (isFrontWave ? 0.35 : 0.25);
      final opacityVariation = random.nextDouble() * 0.1;
      
      // Wave shape gets more dramatic towards the front
      final baseAmplitude = isBackWave ? 0.02 : (isFrontWave ? 0.05 : 0.035);
      final amplitudeVariation = random.nextDouble() * 0.015;
      
      // Wavelength varies more for middle waves
      final baseWavelength = isBackWave ? 0.4 : (isFrontWave ? 0.3 : 0.35);
      final wavelengthVariation = random.nextDouble() * 0.15;
      
      // Speed increases significantly for front waves
      final baseSpeed = isBackWave ? 8.0 : (isFrontWave ? 18.0 : 12.0);
      final speedVariation = random.nextDouble() * 4.0;
      
      // Y position creates depth with slight overlap
      final baseYPosition = 0.3 + (i * 0.12);
      final yVariation = random.nextDouble() * 0.05;

      configs.add(WaveConfig(
        color: selectedColors[i].withOpacity(baseOpacity + opacityVariation),
        yPosition: baseYPosition + yVariation,
        amplitude: baseAmplitude + amplitudeVariation,
        wavelength: baseWavelength + wavelengthVariation,
        speed: baseSpeed + speedVariation,
        direction: i % 2 == 0 ? WaveDirection.leftToRight : WaveDirection.rightToLeft,
        depth: i, // Used for parallax and glow effects
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
  final Color color;
  final double yPosition;
  final double amplitude;
  final double wavelength;
  final double speed;
  final WaveDirection direction;
  final int depth; // 0 = back, 3 = front

  WaveConfig({
    required this.color,
    required this.yPosition,
    required this.amplitude,
    required this.wavelength,
    required this.speed,
    required this.direction,
    required this.depth,
  });

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
          direction == other.direction &&
          depth == other.depth;

  @override
  int get hashCode =>
      color.hashCode ^
      yPosition.hashCode ^
      amplitude.hashCode ^
      wavelength.hashCode ^
      speed.hashCode ^
      direction.hashCode ^
      depth.hashCode;
}
