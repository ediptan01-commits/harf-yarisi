import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:harf_yarisi/main.dart';

void main() {
  testWidgets('Harf Yarışı açılır ve tur başlatılır', (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(const MaterialApp(home: GamePage()));
    expect(find.text('Harf Yarışı'), findsOneWidget);
    expect(find.text('OYUNA BAŞLA'), findsOneWidget);
    await tester.tap(find.text('OYUNA BAŞLA'));
    await tester.pump();
    expect(find.text('STOP!'), findsNothing);
    expect(find.text('■ STOP!'), findsOneWidget);
    expect(find.text('60'), findsOneWidget);
    await tester.tap(find.text('■ STOP!'));
    await tester.pump();
  });
}
