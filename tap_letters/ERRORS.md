# Known Issues and Attempted Solutions

## Letter Tray Overlap Issue

### Problem Description
Letters in the game are appearing underneath the letter tray at the bottom of the screen, making them inaccessible and breaking the game's playability. This happens even though collision detection and boundaries are in place.

### Root Cause Analysis
The issue stems from Flutter's widget layering and how the game is handling coordinate spaces. While we have collision detection in place, the visual rendering of letters is not properly respecting the z-index layering of the UI elements.

### Attempted Solutions

1. **Stack Layer Ordering**
   - Tried reordering Stack children to put letters above UI elements
   - Failed because it caused letters to appear over the tray instead of bouncing off it
   - Code location: `lib/screens/game_screen.dart`

2. **ClipRect with Bounded Height**
   - Added ClipRect widget to constrain letter movement area
   - Used SizedBox with fixed height to create boundaries
   - Still failed due to Flutter's coordinate space handling
   - Code location: `lib/screens/game_screen.dart`

3. **Custom Collision Boundaries**
   - Modified SpawnedLetter model to use adjusted screen dimensions
   - Added header and bottom panel height constants
   - Attempted to create virtual boundaries
   - Partially worked but letters still visually overlap
   - Code location: `lib/models/spawned_letter.dart`

4. **Invisible Barrier**
   - Added transparent Container as collision barrier
   - Positioned it above the letter tray
   - Failed to prevent visual overlap
   - Code location: `lib/screens/game_screen.dart`

5. **Layout Structure Changes**
   - Restructured widget tree to use Column and Expanded
   - Attempted to create separate game area
   - Still experiencing z-index issues
   - Code location: `lib/screens/game_screen.dart`

### Current Status
The issue persists despite multiple approaches. The core problem appears to be related to how Flutter handles absolute positioning within Stack widgets and how it manages the visual layer hierarchy.

### Next Steps
Potential solutions to explore:
1. Implement a custom render object for the game area
2. Use a different approach for letter positioning (relative instead of absolute)
3. Consider using a game engine like Flame for better physics and rendering control
