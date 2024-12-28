import 'package:flutter/material.dart';

class SpawnedLetter {
  final String letter;
  final Offset position;
  final DateTime spawnTime;

  SpawnedLetter({
    required this.letter,
    required this.position,
    DateTime? spawnTime,
  }) : spawnTime = spawnTime ?? DateTime.now();

  SpawnedLetter copyWith({
    String? letter,
    Offset? position,
    DateTime? spawnTime,
  }) {
    return SpawnedLetter(
      letter: letter ?? this.letter,
      position: position ?? this.position,
      spawnTime: spawnTime ?? this.spawnTime,
    );
  }
}
