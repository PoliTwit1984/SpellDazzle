import 'package:flutter/material.dart';
import '../../constants/layout_constants.dart';
import '../../constants/theme_constants.dart';

class RewardAnimations extends StatefulWidget {
  final GlobalKey? scoreKey;
  final bool showConfetti;
  final Offset? scoreStartPosition;
  final int points;
  final double multiplier;
  final VoidCallback? onAnimationComplete;
  final Widget child;

  const RewardAnimations({
    super.key,
    this.scoreKey,
    this.showConfetti = false,
    this.scoreStartPosition,
    this.points = 0,
    this.multiplier = 1.0,
    this.onAnimationComplete,
    required this.child,
  });

  @override
  State<RewardAnimations> createState() => _RewardAnimationsState();
}

class _RewardAnimationsState extends State<RewardAnimations> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;
  late Animation<double> _moveAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.5,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutBack,
    ));

    _opacityAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));

    _moveAnimation = Tween<double>(
      begin: 0.0,
      end: 100.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        widget.onAnimationComplete?.call();
      }
    });
  }

  @override
  void didUpdateWidget(RewardAnimations oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.showConfetti && !oldWidget.showConfetti) {
      _controller.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Main content
        widget.child,
        
        // Score popup animation
        if (widget.showConfetti && widget.scoreStartPosition != null)
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Positioned(
                left: widget.scoreStartPosition!.dx - LayoutConstants.scorePopupSize / 2,
                top: widget.scoreStartPosition!.dy - 
                     LayoutConstants.scorePopupSize / 2 - 
                     _moveAnimation.value,
                child: Opacity(
                  opacity: _opacityAnimation.value,
                  child: Transform.scale(
                    scale: _scaleAnimation.value,
                    child: Container(
                      width: LayoutConstants.scorePopupSize,
                      height: LayoutConstants.scorePopupSize,
                      decoration: BoxDecoration(
                        color: ThemeConstants.accentColor,
                        borderRadius: BorderRadius.circular(
                          LayoutConstants.scorePopupSize / 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          '+${widget.points}',
                          style: ThemeConstants.scoreTextStyle.copyWith(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
      ],
    );
  }
}
