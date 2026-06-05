import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:glass_note/ui_system/widgets/glass_scaffold.dart';

void main() {
  testWidgets('fixed glass background orb does not move for keyboard insets', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: GlassScaffold(
          title: '键盘测试',
          resizeToAvoidBottomInset: false,
          body: TextField(key: ValueKey('keyboard-target')),
        ),
      ),
    );

    final orb = find.byKey(const ValueKey('glass-background-blue-orb'));
    expect(orb, findsOneWidget);
    final initialTop = tester.getTopLeft(orb).dy;

    await tester.tap(find.byKey(const ValueKey('keyboard-target')));
    tester.view.viewInsets = const FakeViewPadding(bottom: 360);
    addTearDown(tester.view.resetViewInsets);
    await tester.pump();

    expect(tester.getTopLeft(orb).dy, initialTop);
  });
}
