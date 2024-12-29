import 'dart:math';
import 'package:flutter/material.dart';
import '../constants/game_constants.dart';

class AnimatedLetter {
  final String letter;
  final TickerProvider vsync;
  final Random random = Random();
  
  // Position animation
  late final AnimationController positionController;
  late final ValueNotifier<Offset> position;
  
  // Scale animation
  late final AnimationController scaleController;
  late final Animation<double> scale;
  late final Animation<double> opacity;
  
  // Movement
  late double _speedX;
  late double _speedY;
  Size? _bounds;
  
  AnimatedLetter({
    required this.letter,
    required Offset initialPosition,
    required this.vsync,
  }) {
    // Initialize position controller for continuous movement
    positionController = AnimationController(
      vsync: vsync,
      duration: const Duration(milliseconds: 16), // 60 FPS
    );
    
    // Initialize scale controller for despawn animation
    scaleController = AnimationController(
      vsync: vsync,
      duration: const Duration(milliseconds: 300),
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
    
    // Set up position
    position = ValueNotifier(initialPosition);
    
    // Initialize random movement
    _initializeMovement();
    
    // Start animation
    positionController.addListener(_updatePosition);
    positionController.repeat();
  }
  
  void _initializeMovement() {
    // Random speed between min and max
    final speed = GameConstants.minLetterSpeed + 
                 random.nextDouble() * (GameConstants.maxLetterSpeed - GameConstants.minLetterSpeed);
    
    // Random angle for movement direction
    final angle = random.nextDouble() * 2 * pi;
    _speedX = speed * cos(angle);
    _speedY = speed * sin(angle);
  }
  
  void _updatePosition() {
    if (_bounds == null) return;
    
    // Get current position
    var currentPos = position.value;
    
    // Update position based on speed
    var newX = currentPos.dx + _speedX;
    var newY = currentPos.dy + _speedY;
    
    // Bounce off walls with margin
    final margin = GameConstants.letterSize / 2;
    if (newX <= margin || newX >= _bounds!.width - margin) {
      _speedX *= -1;
      newX = newX <= margin ? margin : _bounds!.width - margin;
    }
    
    if (newY <= margin || newY >= _bounds!.height - margin) {
      _speedY *= -1;
      newY = newY <= margin ? margin : _bounds!.height - margin;
    }
    
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
          final speed = GameConstants.minLetterSpeed + 
                       random.nextDouble() * (GameConstants.maxLetterSpeed - GameConstants.minLetterSpeed);
          
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
    positionController.dispose();
    scaleController.dispose();
    position.dispose();
  }
}
