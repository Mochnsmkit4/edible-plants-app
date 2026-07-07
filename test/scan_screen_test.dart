import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:edible_app/content/scan.dart';

void main() {
  testWidgets('scan screen shows camera and upload actions', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: PlantScanScreen()));

    expect(find.text('Kamera'), findsOneWidget);
    expect(find.text('Unggah'), findsOneWidget);
  });
}