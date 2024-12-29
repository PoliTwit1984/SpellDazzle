# SpellDazzle - Word Formation Game

A modern, arcade-style word game built with Flutter where players collect falling letters to form words.

## Overview

SpellDazzle challenges players to create words from floating letters in a visually engaging environment. The game features smooth animations, progressive difficulty, and a scoring system that rewards longer and more complex words.

## Technical Architecture

### Core Components

- **GameManager**: Central controller handling game state, letter spawning (including bonus letters), and round transitions
- **GameState**: Observable state management using ValueNotifier for scores, letters, and bonus states
- **AnimatedLetter**: Custom widget for letter movement and animations with bonus visual effects
- **DictionaryService**: Word validation using a pre-loaded dictionary
- **ScoringEngine**: Point calculation based on word length, letter values, and bonus multipliers
- **BackgroundEngine**: Dynamic wave generation with parallax effects and depth-based glow

### Key Features

1. **Letter System**
   - Dynamic letter spawning with weighted distribution
   - Smooth floating animations with collision detection
   - Responsive touch controls for letter collection
   - Special bonus letters with visual effects (10% spawn rate)

2. **Game Mechanics**
   - Round-based gameplay with increasing difficulty
   - Minimum 3-letter word requirement
   - Scrabble-style letter point values
   - Word length multipliers for scoring
   - Bonus letters worth 3x points with glowing effects
   - Visual feedback for bonus letter collection

3. **UI/UX**
   - Dynamic wave background with parallax movement
   - Multi-layered glow effects with depth-based intensity
   - Frosted glass overlays with animated gradients
   - Smooth transitions and reward animations
   - Responsive layout supporting various screen sizes
   - Distinctive red glow for bonus letters

## Setup & Development

1. **Prerequisites**
   ```bash
   flutter --version  # Ensure Flutter is installed
   ```

2. **Installation**
   ```bash
   git clone <repository-url>
   cd tap_letters
   flutter pub get
   ```

3. **Running**
   ```bash
   flutter run
   ```

### Project Structure

```
lib/
├── constants/        # Game configuration and theme constants
├── models/          # Data models and state management
├── screens/         # Main game screens
├── services/        # Core services (dictionary, scoring, background)
├── widgets/         # UI components
│   ├── animations/  # Custom animation widgets
│   ├── game/       # Core game UI elements
│   └── overlays/   # Overlay screens with frosted effects
└── managers/        # Game logic and state management
```

## Performance Considerations

- Letter animations use custom painters for optimal performance
- Dictionary loaded asynchronously at startup
- Efficient collision detection using spatial partitioning
- Memory management through proper widget disposal
- Smart opacity handling with pre-calculated values
- Optimized wave rendering with depth-based effects
- Efficient bonus letter glow effects

## Testing

```bash
flutter test         # Run unit tests
flutter test --coverage  # Generate coverage report
```

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Submit a pull request

## License

This project is licensed under the MIT License - see the LICENSE file for details.
