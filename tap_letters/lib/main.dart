import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/loading_screen.dart';
import 'constants/theme_constants.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SharedPreferences.getInstance();
  runApp(const TapLettersApp());
}

class TapLettersApp extends StatelessWidget {
  const TapLettersApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tap Letters',
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.transparent,
        canvasColor: Colors.transparent,
        dialogBackgroundColor: Colors.transparent,
        colorScheme: ColorScheme.dark(
          primary: ThemeConstants.primaryColor,
          background: Colors.transparent,
          surface: Colors.transparent,
          shadow: Colors.transparent,
        ),
        useMaterial3: true,
        pageTransitionsTheme: const PageTransitionsTheme(
          builders: {
            TargetPlatform.iOS: FadeUpwardsPageTransitionsBuilder(),
            TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
          },
        ),
      ),
      home: const LoadingScreen(),
    );
  }
}
