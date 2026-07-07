import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:edible_app/content/catalog.dart';

void main() {
  testWidgets('tapping scan menu navigates to scan screen', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: PlantCatalogScreen()));

    await tester.tap(find.text('Scan'));
    await tester.pumpAndSettle();

    expect(find.text('MENGANALISIS...'), findsOneWidget);
  });
}