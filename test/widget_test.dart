import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vocal_lytics/main.dart';

void main() {
  testWidgets('Octave changes preserve the selected note and update frequency', (tester) async {
    tester.view.physicalSize = const Size(390, 1100);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(const MyApp());
    expect(find.byKey(const ValueKey('octave-3')), findsNothing);
    await tester.ensureVisible(find.text('연습하러 가기'));
    await tester.tap(find.text('연습하러 가기'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('octave-3')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('1옥타브 (C1–B1)').last);
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('note-24')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('A1 (라)').last);
    await tester.pumpAndSettle();
    expect(find.text('55.0 Hz · 허용 범위 ±50센트'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('octave-1')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('2옥타브 (C2–B2)').last);
    await tester.pumpAndSettle();
    expect(find.text('110.0 Hz · 허용 범위 ±50센트'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('octave-2')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('3옥타브 (C3–B3)').last);
    await tester.pumpAndSettle();
    expect(find.text('220.0 Hz · 허용 범위 ±50센트'), findsOneWidget);
    expect(tester.widget<FilledButton>(find.byType(FilledButton)).onPressed, isNull);
    expect(tester.takeException(), isNull);
  });
}
