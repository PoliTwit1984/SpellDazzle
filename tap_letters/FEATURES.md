# Tap Letters Game Features

## Core Gameplay

### Letter Collection
- Letters randomly spawn on screen at a moderate rate (500ms intervals)
- Up to 8 letters can be on screen simultaneously
- Letters disappear after 3 seconds if not collected
- Maximum of 7 letters can be collected at once
- Letters spawn in a grid-based layout for organized appearance

### Word Formation
- Players can form words using 3-7 letters
- Letters can be rearranged by dragging and dropping
- Double-tap a letter to throw it back into play
- Letters thrown back appear in the bottom half of the screen
- Clear button to remove all collected letters

### Word Validation
- Words are checked against two dictionaries:
  1. A comprehensive English dictionary (words_alpha.txt)
  2. A custom dictionary of common words
- Supports words from 3 to 7 letters in length
- Invalid words end the game

### Scoring System
- Base points equal to word length
- Bonus multipliers:
  - 1.5x for 4-letter words
  - 2.0x for 5+ letter words
- Speed bonus up to 2x for quick word formation
- Points are displayed after each valid word with bonus breakdowns

## Game Flow

### Timer System
- 30-second timer per level
- Timer resets after each valid word
- Timer turns red when 5 seconds remain
- Game ends when timer reaches zero

### Level Progression
- Each valid word advances to the next level
- Level counter displayed in app bar
- Difficulty remains consistent across levels
- High score tracking between sessions

### User Interface
- Clean, minimal design with blue color scheme
- Top bar displays:
  - Current level
  - Score
  - Timer with color feedback
- Bottom panel includes:
  - Letter collection tray
  - Word submission button
  - Clear letters button
- Help button for instructions
- Game over screen with:
  - Final score
  - Level reached
  - Invalid word (if applicable)
  - Play again option

### Letter Distribution
- Letter frequency based on English language usage
- More common letters (E, A, R, I, O, T) appear more frequently
- Balanced distribution to ensure playable words are possible

## Accessibility Features
- Large, readable text
- High contrast colors
- Clear visual feedback
- Drag and drop support
- Double-tap gestures
- Floating notifications for feedback

## Technical Features
- State persistence (high scores)
- Efficient word validation
- Smooth animations
- Responsive layout
- Error handling
- Debug logging for word validation
