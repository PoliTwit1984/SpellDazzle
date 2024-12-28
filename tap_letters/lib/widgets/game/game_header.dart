import 'package:flutter/material.dart';
import 'progress_meter.dart';
import 'achievement_popup.dart';

class GameHeader extends StatefulWidget {
  final int level;
  final int score;
  final int secondsRemaining;
  final VoidCallback onHelpPressed;
  final GlobalKey scoreKey;

  const GameHeader({
    super.key,
    required this.level,
    required this.score,
    required this.secondsRemaining,
    required this.onHelpPressed,
    required this.scoreKey,
  });

  @override
  State<GameHeader> createState() => _GameHeaderState();
}

class _GameHeaderState extends State<GameHeader> with SingleTickerProviderStateMixin {
  late AnimationController _scoreAnimationController;
  late Animation<double> _scoreScaleAnimation;
  bool _showAchievement = false;
  int _lastLevel = 1;

  static const int _scorePerLevel = 100;

  @override
  void initState() {
    super.initState();
    _scoreAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _scoreScaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(begin: 1.0, end: 1.3),
        weight: 50,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 1.3, end: 1.0),
        weight: 50,
      ),
    ]).animate(CurvedAnimation(
      parent: _scoreAnimationController,
      curve: Curves.easeOut,
    ));

    _lastLevel = widget.level;
  }

  @override
  void didUpdateWidget(GameHeader oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.score != oldWidget.score) {
      _scoreAnimationController.forward(from: 0);
    }
    if (widget.level > _lastLevel) {
      _showLevelUpAchievement();
      _lastLevel = widget.level;
    }
  }

  void _showLevelUpAchievement() {
    setState(() => _showAchievement = true);
  }

  void _hideAchievement() {
    setState(() => _showAchievement = false);
  }

  @override
  void dispose() {
    _scoreAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        AppBar(
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF6A3093), // Deep purple
                  Color(0xFFA044FF), // Bright purple
                ],
              ),
            ),
          ),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ProgressMeter(
                level: widget.level,
                score: widget.score % _scorePerLevel,
                targetScore: _scorePerLevel,
                onLevelUp: () {}, // Handled by game logic
              ),
              const SizedBox(width: 20),
              ScaleTransition(
                scale: _scoreScaleAnimation,
                child: Container(
                  key: widget.scoreKey,
                  child: Text(
                    'Score: ${widget.score}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'FredokaOne',
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 20),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: widget.secondsRemaining <= 5 
                      ? [const Color(0xFFFF416C), const Color(0xFFFF4B2B)] // Red gradient
                      : [const Color(0xFF00C6FF), const Color(0xFF0072FF)], // Blue gradient
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Text(
                  '${widget.secondsRemaining} s',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'FredokaOne',
                    shadows: [
                      Shadow(
                        color: Colors.black26,
                        offset: Offset(0, 1),
                        blurRadius: 2,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          centerTitle: true,
          actions: [
            IconButton(
              icon: const Icon(Icons.help_outline, color: Colors.white),
              onPressed: widget.onHelpPressed,
            ),
          ],
        ),
        if (_showAchievement)
          Positioned(
            top: kToolbarHeight + 20,
            left: 0,
            right: 0,
            child: Center(
              child: AchievementPopup(
                title: 'Level Up!',
                description: 'You reached Level ${widget.level}',
                icon: Icons.star,
                onDismiss: _hideAchievement,
              ),
            ),
          ),
      ],
    );
  }
}
