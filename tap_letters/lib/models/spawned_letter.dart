import 'dart:math';
import 'package:flutter/material.dart';
import '../constants/game_constants.dart';

class SpawnedLetter {
  final String letter;
  Offset position;
  final DateTime spawnTime;
  final double lifetimeSeconds;
  Offset velocity;
  
  // Movement constants
  static const double bounceEnergy = 0.95; // Higher energy retention for smoother movement
  static const double letterSize = 60.0;
  static const double collisionRadius = 55.0;
  static const double directionChangeChance = 0.01; // 1% chance to change direction each frame
  
  // Keep track of last used lifetime to stagger spawns
  static double _lastLifetime = GameConstants.minLetterLifetimeSeconds.toDouble();
  
  SpawnedLetter({
    required this.letter,
    required this.position,
    DateTime? spawnTime,
    Offset? velocity,
    double? lifetimeSeconds,
  }) : 
    spawnTime = spawnTime ?? DateTime.now(),
    velocity = velocity ?? _generateRandomVelocity(),
    lifetimeSeconds = lifetimeSeconds ?? _getNextLifetime();

  static Offset _generateRandomVelocity() {
    final random = Random();
    // Generate random angle between 0 and 2π (full circle)
    final angle = random.nextDouble() * 2 * pi;
    // Generate random speed between min and max
    final speedRange = GameConstants.maxLetterSpeed - GameConstants.minLetterSpeed;
    final speed = GameConstants.minLetterSpeed + random.nextDouble() * speedRange;
    // Convert to x,y velocity
    return Offset(cos(angle) * speed, sin(angle) * speed);
  }

  static double _getNextLifetime() {
    // Increment lifetime by 0.2 seconds
    _lastLifetime += 0.2;
    // Reset if we've reached max
    if (_lastLifetime > GameConstants.maxLetterLifetimeSeconds) {
      _lastLifetime = GameConstants.minLetterLifetimeSeconds.toDouble();
    }
    return _lastLifetime;
  }

  bool get isExpired {
    final now = DateTime.now();
    return now.difference(spawnTime).inMilliseconds >= (lifetimeSeconds * 1000);
  }

  void move(Size bounds, List<SpawnedLetter> others) {
    // Randomly change direction occasionally
    if (Random().nextDouble() < directionChangeChance) {
      final angle = Random().nextDouble() * 2 * pi;
      final currentSpeed = sqrt(velocity.dx * velocity.dx + velocity.dy * velocity.dy);
      velocity = Offset(
        cos(angle) * currentSpeed,
        sin(angle) * currentSpeed
      );
    }
    
    // Calculate boundaries and next position
    final maxX = bounds.width - letterSize;
    final maxY = bounds.height - letterSize;
    var nextPosition = position + velocity;
    
    // Handle boundary collisions
    if (nextPosition.dx <= 0 || nextPosition.dx >= maxX) {
      velocity = Offset(-velocity.dx * bounceEnergy, velocity.dy);
      nextPosition = Offset(
        nextPosition.dx <= 0 ? 0 : maxX,
        nextPosition.dy
      );
    }
    
    if (nextPosition.dy <= 0 || nextPosition.dy >= maxY) {
      velocity = Offset(velocity.dx, -velocity.dy * bounceEnergy);
      nextPosition = Offset(
        nextPosition.dx,
        nextPosition.dy <= 0 ? 0 : maxY
      );
    }
    
    // Handle collisions with other letters
    for (final other in others) {
      if (other == this) continue;
      
      final dx = nextPosition.dx - other.position.dx;
      final dy = nextPosition.dy - other.position.dy;
      final distance = sqrt(dx * dx + dy * dy);
      
      if (distance < collisionRadius) {
        // Calculate collision normal
        final nx = dx / distance;
        final ny = dy / distance;
        
        // Calculate relative velocity
        final relativeVelocity = velocity - other.velocity;
        final normalVelocity = relativeVelocity.dx * nx + relativeVelocity.dy * ny;
        
        // Only resolve collision if objects are moving toward each other
        if (normalVelocity < 0) {
          // Calculate impulse
          final restitution = bounceEnergy;
          final impulse = -(1 + restitution) * normalVelocity / 2;
          
          // Apply impulse
          velocity = Offset(
            velocity.dx + impulse * nx,
            velocity.dy + impulse * ny
          );
          
          // Move away from collision
          final separation = collisionRadius - distance;
          nextPosition = Offset(
            nextPosition.dx + nx * separation * 0.5,
            nextPosition.dy + ny * separation * 0.5
          );
        }
      }
    }
    
    // Ensure position stays within bounds
    position = Offset(
      nextPosition.dx.clamp(0, maxX),
      nextPosition.dy.clamp(0, maxY)
    );
  }

  SpawnedLetter copyWith({
    String? letter,
    Offset? position,
    DateTime? spawnTime,
    Offset? velocity,
    double? lifetimeSeconds,
  }) {
    return SpawnedLetter(
      letter: letter ?? this.letter,
      position: position ?? this.position,
      spawnTime: spawnTime ?? this.spawnTime,
      velocity: velocity ?? this.velocity,
      lifetimeSeconds: lifetimeSeconds ?? this.lifetimeSeconds,
    );
  }

  // Reset stagger counter when game restarts
  static void resetLifetimeStagger() {
    _lastLifetime = GameConstants.minLetterLifetimeSeconds.toDouble();
  }
}
