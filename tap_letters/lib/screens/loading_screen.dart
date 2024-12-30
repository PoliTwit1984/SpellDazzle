import 'package:flutter/material.dart';
import '../services/dictionary_service.dart';
import '../services/game_service.dart';
import '../constants/theme_constants.dart';
import 'game_screen.dart';

class LoadingScreen extends StatefulWidget {
  const LoadingScreen({super.key});

  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {
  final GameService _gameService = GameService();
  final DictionaryService _dictionaryService = DictionaryService();

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    await _gameService.initialize();
    await _dictionaryService.initialize();
    
    if (mounted) {
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => const GameScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: animation,
              child: child,
            );
          },
          transitionDuration: const Duration(milliseconds: 500),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Material(
        type: MaterialType.transparency,
        child: Container(
          decoration: const BoxDecoration(
            gradient: ThemeConstants.backgroundGradient,
          ),
          child: const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(ThemeConstants.white),
            ),
          ),
        ),
      ),
    );
  }
}
