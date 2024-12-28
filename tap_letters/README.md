# Tap Letters Game

A fast-paced word formation game built with Flutter where players collect letters to form valid English words before time runs out.

## Game Features

- Grid-based letter spawning system
- Smooth animations with fade-in and pop effects
- 30-second timer per round
- Score multipliers for longer words
- Speed bonuses for quick word formation
- Comprehensive English dictionary validation
- Drag and drop letter rearrangement
- Double-tap to remove letters
- iOS-style frosted glass UI elements

## Getting Started

1. Clone the repository
2. Ensure Flutter is installed and set up
3. Run `flutter pub get` to install dependencies
4. Run `flutter run` to start the game

## How to Play

1. Tap letters as they appear on screen to collect them
2. Form words using 3-7 letters
3. Submit valid words to score points and reset the timer
4. Get bonus points for:
   - 4-letter words (1.5x multiplier)
   - 5+ letter words (2.0x multiplier)
   - Quick word formation (up to 2x bonus)
5. Game ends if:
   - Timer reaches zero
   - Invalid word is submitted

## Technical Details

- Built with Flutter
- Uses custom animations and transitions
- Implements efficient word validation
- Grid-based layout system
- State management for game progression
- Responsive design for various screen sizes
