import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:harf_yarisi/main.dart';
void main() {
  testWidgets('Harf Yarışı oyun ekranı', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: GamePage()));
    expect(find.text('Harf Yarışı'), findsOneWidget);
    expect(find.text('OYUNA BAŞLA'), findsOneWidget);
    expect(find.byType(TextField), findsNWidgets(6));
  });
}
