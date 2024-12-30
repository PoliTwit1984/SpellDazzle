import 'dart:math';
import 'dart:async';
import 'package:flutter/material.dart';
import '../constants/game_constants.dart';
import '../constants/theme_constants.dart';

class AnimatedLetter {
  final String letter;
  final TickerProvider vsync;
  final VoidCallback onExpire;
  final Random random = Random();
  
  // Visual style
  final Color baseColor;
  final double cornerRadius;
  final double shadowIntensity;
  final double sizeVariation;
  final bool isBonus;
  final Color glowColor;
  
  // Position update timer
  Timer? _positionTimer;
  late final ValueNotifier<Offset> position;
  late final ValueNotifier<double> rotation;
  
  // Scale and opacity animations
  late final AnimationController scaleController;
  late final Animation<double> scale;
  late final Animation<double> opacity;
  
  // Sparkle animation
  late final AnimationController sparkleController;
  late final Animation<double> sparkleScale;
  late final Animation<double> sparkleOpacity;
  
  // Lifetime timer
  Timer? _lifetimeTimer;
  
  // Movement
  late double _speedX;
  late double _speedY;
  Size? _bounds;
  
  // Rotation animation
  double _rotationTime = 0;
  
  AnimatedLetter({
    required this.letter,
    required Offset initialPosition,
    required this.vsync,
    required this.onExpire,
    this.isBonus = false,
  }) : baseColor = ThemeConstants.letterColors[Random().nextInt(ThemeConstants.letterColors.length)],
       glowColor = const Color(0xFFFF0000),
       cornerRadius = ThemeConstants.minCornerRadius + 
                     (Random().nextDouble() * (ThemeConstants.maxCornerRadius - ThemeConstants.minCornerRadius)),
       shadowIntensity = ThemeConstants.minShadowIntensity + 
                        (Random().nextDouble() * (ThemeConstants.maxShadowIntensity - ThemeConstants.minShadowIntensity)),
       sizeVariation = ThemeConstants.minLetterScale + 
                      (Random().nextDouble() * (ThemeConstants.maxLetterScale - ThemeConstants.minLetterScale)) {
    
    // Initialize position update timer (60 FPS)
    _positionTimer = Timer.periodic(const Duration(milliseconds: 16), (_) {
      _updatePosition();
    });
    
    // Initialize scale controller for despawn animation
    scaleController = AnimationController(
      vsync: vsync,
      duration: const Duration(milliseconds: 300),
    );
    
    // Initialize sparkle controller for spawn animation
    sparkleController = AnimationController(
      vsync: vsync,
      duration: const Duration(milliseconds: 500),
    );
    
    // Set up scale and opacity animations
    scale = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: scaleController,
      curve: Curves.easeInOut,
    ));
    
    opacity = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: scaleController,
      curve: Curves.easeInOut,
    ));
    
    // Set up sparkle animations
    sparkleScale = Tween<double>(
      begin: 0.0,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: sparkleController,
      curve: Curves.easeOut,
    ));
    
    sparkleOpacity = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.0, end: 1.0),
        weight: 30,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 0.0),
        weight: 70,
      ),
    ]).animate(sparkleController);
    
    // Set up position and rotation
    position = ValueNotifier(initialPosition);
    rotation = ValueNotifier(0.0);
    
    // Initialize random movement
    _initializeMovement();
    
    // Start animations
    sparkleController.forward();
    
    // Set up lifetime timer (random between min and max lifetime)
    final lifetime = Duration(
      milliseconds: GameConstants.minLetterLifetimeSeconds * 1000 +
                   random.nextInt((GameConstants.maxLetterLifetimeSeconds - GameConstants.minLetterLifetimeSeconds) * 1000)
    );
    _lifetimeTimer = Timer(lifetime, () {
      startDespawnAnimation();
      Timer(const Duration(milliseconds: 300), onExpire);
    });
  }
  
  void _initializeMovement() {
    // Get random speed in pixels/frame (60 FPS)
    final pixelsPerSecond = GameConstants.minLetterSpeed + 
                         random.nextDouble() * (GameConstants.maxLetterSpeed - GameConstants.minLetterSpeed);
    final speed = pixelsPerSecond / 60; // Convert to pixels per frame
    
    // Random angle between -30 and 30 degrees from horizontal
    final angle = (random.nextDouble() * pi/3) - pi/6;
    
    // Start from either left or right edge
    final startFromLeft = random.nextBool();
    final direction = startFromLeft ? 1 : -1;
    _speedX = speed * cos(angle) * direction;
    _speedY = speed * sin(angle);
    
    // Adjust initial position to start at edge
    if (_bounds != null) {
      const margin = GameConstants.letterSize / 2;
      if (startFromLeft) {
        position.value = Offset(margin, position.value.dy);
      } else {
        position.value = Offset(_bounds!.width - margin, position.value.dy);
      }
    }
  }

  void _updatePosition() {
    if (_bounds == null) return;
    
    // Get current position
    var currentPos = position.value;
    
    // Update base position based on speed
    var newX = currentPos.dx + _speedX;
    var newY = currentPos.dy + _speedY;
    
    // Bounce off walls with margin, preserving angle
    const margin = GameConstants.letterSize / 2;
    if (newX <= margin || newX >= _bounds!.width - margin) {
      _speedX *= -1; // Reverse horizontal direction
      newX = newX <= margin ? margin : _bounds!.width - margin;
    }
    
    if (newY <= margin || newY >= _bounds!.height - margin) {
      _speedY *= -1; // Reverse vertical direction
      newY = newY <= margin ? margin : _bounds!.height - margin;
    }
    
    // Update rotation for wobble effect
    _rotationTime += 1/60; // 60 FPS
    rotation.value = sin(_rotationTime * GameConstants.wobbleFrequency * 2 * pi) * 0.1; // ±0.1 radians (±5.7 degrees)
    
    // Update position
    position.value = Offset(newX, newY);
  }
  
  void updateBounds(Size bounds, List<AnimatedLetter> others) {
    _bounds = bounds;
    
    // Avoid other letters
    for (final other in others) {
      if (other != this) {
        final dx = position.value.dx - other.position.value.dx;
        final dy = position.value.dy - other.position.value.dy;
        final distance = sqrt(dx * dx + dy * dy);
        
        if (distance < GameConstants.letterSize * 1.2) {
          // Bounce off other letter
          final angle = atan2(dy, dx);
          final pixelsPerSecond = GameConstants.minLetterSpeed + 
                               random.nextDouble() * (GameConstants.maxLetterSpeed - GameConstants.minLetterSpeed);
          final speed = pixelsPerSecond / 60; // Convert to pixels per frame
          
          _speedX = cos(angle) * speed;
          _speedY = sin(angle) * speed;
          
          // Move away from collision
          position.value = Offset(
            other.position.value.dx + cos(angle) * GameConstants.letterSize * 1.2,
            other.position.value.dy + sin(angle) * GameConstants.letterSize * 1.2,
          );
          break;
        }
      }
    }
  }
  
  void startDespawnAnimation() {
    scaleController.forward();
  }
  
  void dispose() {
    _positionTimer?.cancel();
    scaleController.dispose();
    sparkleController.dispose();
    position.dispose();
    rotation.dispose();
    _lifetimeTimer?.cancel();
  }
}
