import 'dart:math';
import 'package:flutter/material.dart';

class SpawnedLetter {
  final String letter;
  Offset position;
  final DateTime spawnTime;
  Offset velocity;
  
  // Movement constants
  static const double minSpeed = 0.3;
  static const double maxSpeed = 0.8;
  static const double bounceVelocityLoss = 0.95; // Reduce velocity by 5% on bounce

  SpawnedLetter({
    required this.letter,
    required this.position,
    DateTime? spawnTime,
    Offset? velocity,
  }) : 
    spawnTime = spawnTime ?? DateTime.now(),
    velocity = velocity ?? _generateRandomVelocity();

  static Offset _generateRandomVelocity() {
    final random = Random();
    // Generate random angle between 0 and 2π
    final angle = random.nextDouble() * 2 * pi;
    // Generate random speed between min and max speed
    final speed = minSpeed + random.nextDouble() * (maxSpeed - minSpeed);
    // Convert polar coordinates to cartesian
    return Offset(
      cos(angle) * speed,
      sin(angle) * speed,
    );
  }

  void move(Size bounds, List<SpawnedLetter> others) {
    final nextPosition = position + velocity;
    bool hasCollision = false;
    
    // Check collisions with other letters
    for (final other in others) {
      if (other == this) continue;
      
      // Calculate distance between centers
      final dx = nextPosition.dx - other.position.dx;
      final dy = nextPosition.dy - other.position.dy;
      final distance = sqrt(dx * dx + dy * dy);
      
      // If letters would overlap (use slightly smaller collision radius for smoother interaction)
      if (distance < 55.0) {
        hasCollision = true;
        // Calculate collision normal
        final nx = dx / distance;
        final ny = dy / distance;
        
        // Reflect velocity off collision normal
        final dotProduct = velocity.dx * nx + velocity.dy * ny;
        velocity = Offset(
          velocity.dx - 2 * dotProduct * nx,
          velocity.dy - 2 * dotProduct * ny
        ) * bounceVelocityLoss;
        
        // Move away from collision with a small separation
        final separation = 55.0 - distance;
        position = Offset(
          position.dx + nx * separation * 0.5,
          position.dy + ny * separation * 0.5
        );
        break;
      }
    }
    
    // If no collision, update position
    if (!hasCollision) {
      position = nextPosition;
    }
    
    // Bounce off screen edges
    const letterSize = 60.0;
    const topPadding = 140.0;
    const bottomPadding = 240.0;
    
    if (position.dx <= 0 || position.dx >= bounds.width - letterSize) {
      velocity = Offset(-velocity.dx * bounceVelocityLoss, velocity.dy);
      position = Offset(
        position.dx <= 0 ? 0 : bounds.width - letterSize,
        position.dy
      );
    }
    
    if (position.dy <= topPadding || position.dy >= bounds.height - bottomPadding) {
      velocity = Offset(velocity.dx, -velocity.dy * bounceVelocityLoss);
      position = Offset(
        position.dx,
        position.dy <= topPadding ? topPadding : bounds.height - bottomPadding
      );
    }
  }

  SpawnedLetter copyWith({
    String? letter,
    Offset? position,
    DateTime? spawnTime,
    Offset? velocity,
  }) {
    return SpawnedLetter(
      letter: letter ?? this.letter,
      position: position ?? this.position,
      spawnTime: spawnTime ?? this.spawnTime,
      velocity: velocity ?? this.velocity,
    );
  }
}
