import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:harf_yarisi/main.dart';
import 'package:harf_yarisi/word_check.dart';

void main() {
  test('Kategori kontrolü yanlış hayvan cevabını reddeder', () async {
    await WordCheck.loadBundled();
    expect(WordCheck.dictionaryLoaded, isTrue);
    expect(WordCheck.bundledCount, greaterThan(11000));
    expect(WordCheck.check('Hayvan', 'S', 'Saat'), isFalse);
    expect(WordCheck.check('Hayvan', 'S', 'Serçe'), isTrue);
    expect(WordCheck.check('Şehir', 'İ', 'İzmir'), isTrue);
    expect(WordCheck.check('Ülke', 'K', 'Kedi'), isFalse);
    expect(WordCheck.check('İsim', 'Ç', 'Çağla'), isTrue);
    expect(WordCheck.check('İsim', 'B', 'Betül'), isTrue);
    expect(WordCheck.check('Şehir', 'B', 'Bursa'), isTrue);
    expect(WordCheck.check('Bitki', 'B', 'Brokoli'), isTrue);
    expect(WordCheck.check('Eşya', 'B', 'Battaniye'), isTrue);
    expect(WordCheck.check('Ülke', 'B', 'Bolivya'), isTrue);
    expect(WordCheck.check('Hayvan', 'B', 'Blık'), isFalse);
    expect(WordCheck.check('Hayvan', 'B', 'Balık'), isTrue);
    expect(WordCheck.check('Hayvan', 'B', 'Battaniye'), isFalse);
    expect(WordCheck.check('İsim', 'B', 'Betül'), isTrue);
    expect(WordCheck.check('Bitki', 'B', 'Brokoli'), isTrue);
    expect(WordCheck.check('Eşya', 'B', 'Battaniye'), isTrue);
    expect(WordCheck.check('Ülke', 'B', 'Bolivya'), isTrue);
  });
  testWidgets('Harf Yarışı açılır ve tur başlatılır', (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(const MaterialApp(home: GamePage()));
    expect(find.text('Harf Yarışı'), findsOneWidget);
    await tester.tap(find.text('OYUNA BAŞLA'));
    await tester.pump();
    expect(find.text('■ STOP!'), findsOneWidget);
    await tester.tap(find.text('■ STOP!'));
    await tester.pump();
  });
}
