import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:glass_note/ui_system/widgets/glass_bottom_navigation.dart';

void main() {
  testWidgets('selected destination wraps icon and label in one glass pill', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          bottomNavigationBar: GlassBottomNavigation(
            currentIndex: 0,
            onTap: (_) {},
          ),
        ),
      ),
    );

    final selected = tester.getSize(find.byKey(const ValueKey('nav-pill-0')));
    final unselected = tester.getSize(find.byKey(const ValueKey('nav-pill-1')));

    expect(selected.width, greaterThan(76));
    expect(selected.height, greaterThan(54));
    expect(selected.width, greaterThan(unselected.width));
  });
}
