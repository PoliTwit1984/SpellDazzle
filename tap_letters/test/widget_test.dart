import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tap_letters/main.dart';

void main() {
  testWidgets('Game initialization test', (WidgetTester tester) async {
    await tester.pumpWidget(const TapLettersApp());

    // Verify initial game state
    expect(find.text('Score: 0'), findsOneWidget);
    expect(find.text('30 s'), findsOneWidget);
    expect(find.text('Tap letters in order to spell a word'), findsOneWidget);
    expect(find.byType(ElevatedButton), findsOneWidget);
  });
}
