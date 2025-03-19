import 'package:ats_system/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('App launch test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Since we're using a splash screen, we can test for that instead
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
