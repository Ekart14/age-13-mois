// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:age_13_mois/main.dart';

void main() {
  test('planetary ages are displayed as years, months and days without Earth', () {
    final result = calculerAgeSurPlanetes(
      DateTime(2001, 1, 1),
      DateTime(2023, 12, 31),
    );

    expect(result.any((planete) => planete['nom'] == 'Terre'), isFalse);

    final mars = result.firstWhere((planete) => planete['nom'] == 'Mars');
    expect(mars['age'], contains('ans'));
    expect(mars['age'], contains('mois'));
    expect(mars['age'], contains('jours'));
  });

  testWidgets('about button opens the dedicated about page', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('À propos'), findsOneWidget);
    await tester.tap(find.text('À propos'));
    await tester.pumpAndSettle();

    expect(find.text('Calendrier de 13 mois'), findsOneWidget);
    expect(find.text('Une année plus régulière'), findsOneWidget);
  });
}
