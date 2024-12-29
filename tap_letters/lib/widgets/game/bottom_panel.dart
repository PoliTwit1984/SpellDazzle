import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import '../../constants/layout_constants.dart';
import '../../constants/theme_constants.dart';
import '../../constants/game_constants.dart';

class BottomPanel extends StatefulWidget {
  final List<String> letters;
  final VoidCallback onClear;
  final Function(int, int) onReorder;
  final Function(int) onLetterRemoved;
  final VoidCallback onSubmit;

  const BottomPanel({
    super.key,
    required this.letters,
    required this.onClear,
    required this.onReorder,
    required this.onLetterRemoved,
    required this.onSubmit,
  });

  @override
  State<BottomPanel> createState() => _BottomPanelState();
}

class _BottomPanelState extends State<BottomPanel> {
  bool _showClearConfirm = false;
  Timer? _clearConfirmTimer;

  @override
  void dispose() {
    _clearConfirmTimer?.cancel();
    super.dispose();
  }

  void _handleClearTap() {
    if (_showClearConfirm) {
      widget.onClear();
      setState(() {
        _showClearConfirm = false;
      });
      _clearConfirmTimer?.cancel();
    } else {
      setState(() {
        _showClearConfirm = true;
      });
      _clearConfirmTimer = Timer(const Duration(seconds: 2), () {
        if (mounted) {
          setState(() {
            _showClearConfirm = false;
          });
        }
      });
    }
  }

  double _getLetterSpacing() {
    return widget.letters.length >= 7 ? 4.0 : 6.0;
  }

  @override
  Widget build(BuildContext context) {
    final letterSpacing = _getLetterSpacing();

    return Container(
      height: LayoutConstants.bottomPanelHeight,
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 16),
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          // Letter tray
          Container(
            height: LayoutConstants.letterTrayHeight,
            margin: const EdgeInsets.only(bottom: 64),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: ReorderableListView(
                    scrollDirection: Axis.horizontal,
                    padding: EdgeInsets.symmetric(horizontal: letterSpacing * 2),
                    onReorder: widget.onReorder,
                    proxyDecorator: (child, index, animation) {
                      return Material(
                        color: Colors.transparent,
                        child: child,
                      );
                    },
                    children: [
                      for (int i = 0; i < widget.letters.length; i++)
                        Padding(
                          key: ValueKey(i),
                          padding: EdgeInsets.symmetric(
                            horizontal: letterSpacing,
                            vertical: (LayoutConstants.letterTrayHeight - LayoutConstants.trayLetterSize) / 2,
                          ),
                          child: GestureDetector(
                            onTap: () => widget.onLetterRemoved(i),
                            child: Container(
                              width: LayoutConstants.trayLetterSize,
                              height: LayoutConstants.trayLetterSize,
                              padding: EdgeInsets.all(LayoutConstants.trayLetterPadding),
                              decoration: BoxDecoration(
                                color: ThemeConstants.primaryColor,
                                borderRadius: BorderRadius.circular(8),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.15),
                                    blurRadius: 3,
                                    offset: const Offset(0, 1),
                                  ),
                                ],
                              ),
                              child: Center(
                                child: Text(
                                  widget.letters[i],
                                  style: TextStyle(
                                    fontSize: LayoutConstants.trayLetterTextSize,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          // Action buttons
          Positioned(
            bottom: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Clear button
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(28),
                  ),
                  child: IconButton(
                    padding: EdgeInsets.zero,
                    onPressed: _handleClearTap,
                    iconSize: 32,
                    icon: Icon(
                      _showClearConfirm ? Icons.delete_forever : Icons.delete_outline,
                      color: _showClearConfirm 
                          ? ThemeConstants.dangerColor
                          : ThemeConstants.primaryColor,
                    ),
                    tooltip: 'Clear letters',
                  ),
                ),
                const SizedBox(width: 48),
                // Submit button
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(28),
                  ),
                  child: IconButton(
                    padding: EdgeInsets.zero,
                    onPressed: widget.letters.isEmpty ? null : widget.onSubmit,
                    iconSize: 36,
                    icon: Icon(
                      Icons.chevron_right,
                      color: widget.letters.isEmpty
                          ? Colors.grey
                          : Colors.green,
                    ),
                    tooltip: 'Submit word',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
