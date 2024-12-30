# SpellDazzle Features Documentation

## Core Game Mechanics

### Letter System
- **Spawning Algorithm**
  - Letters spawn with weighted distribution based on English language frequency
  - Maintains 4-8 letters on screen at any time
  - Automatic respawning when letters are collected
  - Smart positioning to prevent overlaps
  - 10% chance for any letter to be a bonus letter

- **Letter Movement & Animation**
  - **Core Movement**
    - Smooth floating animation with subtle acceleration
    - Collision detection between letters
    - Boundary detection to keep letters in play area
    - Despawn animation when collected
  - **Enhanced Animations**
    - Randomized rotation for each letter (0.05-0.1 radians)
    - Variable animation speeds (1-2 seconds per cycle)
    - Smooth easeInOut transitions
    - Independent animation controllers per letter
  - **Bonus Letter Effects**
    - Red glowing outline for bonus letters
    - Persistent glow effect in collection tray
    - Enhanced visual feedback on collection

### Word Formation
- **Collection Mechanics**
  - Tap letters to collect them
  - Letters appear in collection tray at bottom
  - Maximum 7 letters can be collected
  - Letters can be reordered in tray
  - Individual letters can be removed by tapping
  - Bonus status preserved during reordering

- **Word Validation**
  - Minimum 3-letter requirement
  - Dictionary validation using pre-loaded word list
  - Invalid words end the game
  - Instant feedback on word submission

### Scoring System
- **Letter Points**
  - Common letters (E, A, I, O, N, R, T): 1 point
  - Less common letters (D, G, B, C, M, P): 2-3 points
  - Rare letters (K, J, X, Q, Z): 4-10 points
  - Bonus letters: 3x point multiplier

- **Word Multipliers**
  - 3 letters: 1.0x (base score)
  - 4 letters: 1.2x multiplier
  - 5 letters: 1.3x multiplier
  - 6 letters: 1.5x multiplier
  - 7+ letters: 1.7x multiplier
  - Bonus multipliers stack with word length multipliers

## Visual Elements

### Background Design
- **Wave System**
  - Four dynamic waves with varying properties
  - Parallax movement effect (slower back waves, faster front waves)
  - Depth-based glow intensity
  - Multi-layered animations
  - Smooth color transitions
  
- **Wave Properties**
  - Back waves: Gentle movement, subtle opacity (15%)
  - Middle waves: Moderate animation (25%)
  - Front waves: Dynamic movement, higher opacity (35%)
  - Customized wavelengths and amplitudes per layer
  
- **Glow Effects**
  - Depth-based blur (2-6px)
  - Dynamic glow opacity
  - Inner glow for front waves
  - Animated gradient background
  - Special red glow for bonus letters
  - Safe blur radius calculations with non-negative values

### UI Components
- **Letter Tiles**
  - Clean, modern design
  - Responsive touch targets
  - Shadow effects for depth
  - Clear typography
  - Subtle rotation animations
  - Randomized movement patterns
  - Distinctive red glow for bonus letters
  - Optimized shadow rendering with guaranteed non-negative blur values

- **Collection Tray**
  - Frosted glass effect
  - Dynamic size adjustment based on letter count
  - Smooth reordering animation
  - Clear visual feedback
  - Preserved bonus letter effects
  - Safe shadow calculations for consistent appearance

- **Score Display**
  - Frosted glass overlay
  - Points pop animation with breakdown
  - Bonus multiplier indicators
  - Smooth transitions
  - Clear bonus letter indicators
  - Optimized shadow and glow effects

### Animations
- **Letter Animations**
  - Smooth floating movement
  - Soft collision responses
  - Fade-out collection effect
  - Scale animations for interactions
  - Independent rotation system
  - Customizable animation parameters
  - Special effects for bonus letters
  - Performance-optimized shadow calculations

- **Score Animations**
  - Point accumulation effects
  - Multiplier displays
  - Achievement popups
  - Round transition effects
  - Bonus point calculations
  - Detailed score breakdown
  - Safe visual effect handling

## Game Progression

### Round System
- **Round Structure**
  - 30-second rounds
  - Must submit at least one valid word
  - Score summary between rounds
  - Progressive difficulty increase
  - Bonus letter frequency remains constant

- **Round Summary**
  - Total round score
  - Best word highlight
  - Word score breakdown
  - Next level preview
  - Animated countdown
  - Bonus letter contribution display

### Difficulty Scaling
- **Per-Round Adjustments**
  - Increased letter movement speed
  - More complex letter distribution
  - Higher score requirements
  - Shorter time between spawns
  - Consistent bonus letter chance

## Technical Features

### Performance Optimizations
- **Animation Engine**
  - Custom painter implementations
  - Efficient collision detection
  - Optimized render cycles
  - Memory-conscious design
  - Smart animation disposal
  - Independent animation controllers
  - Frame-rate optimized transforms
  - Efficient glow effect rendering
  - Safe shadow calculations with non-negative values

### Visual Optimizations
- **Opacity Management**
  - Pre-calculated opacity values
  - Safe color interpolation
  - Clamped glow effects
  - Efficient gradient rendering
  - Smart blur effects
  - Optimized bonus letter effects
  - Guaranteed non-negative shadow blur values

### State Management
- **Game State**
  - Reactive state updates
  - Efficient UI rebuilds
  - Clean architecture pattern
  - Modular component design
  - Bonus letter state tracking

### Error Handling
- **Graceful Recovery**
  - Dictionary load fallbacks
  - Animation frame drops
  - Touch event conflicts
  - Memory pressure handling
  - State synchronization
  - Safe visual effect calculations

## Future Enhancements
- Online leaderboards
- Achievement system
- Power-up mechanics
- Theme customization
- Sound effects and music
- Social sharing features
- Daily challenges
- Practice mode
- Additional bonus mechanics
