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

  testWidgets('bottom navigation is translucent glass and keeps tab taps', (
    tester,
  ) async {
    var tappedIndex = -1;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          bottomNavigationBar: GlassBottomNavigation(
            currentIndex: 0,
            onTap: (index) => tappedIndex = index,
          ),
        ),
      ),
    );

    final surface = tester.widget<DecoratedBox>(
      find.byKey(const ValueKey('glass-bottom-navigation-surface')),
    );
    final decoration = surface.decoration as BoxDecoration;

    expect(decoration.color?.a, lessThan(0.6));

    await tester.tap(find.text('时间线'));
    expect(tappedIndex, 2);
  });

  testWidgets('bottom navigation order starts with capture microphone tab', (
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

    expect(find.byIcon(Icons.mic), findsOneWidget);

    final captureLeft = tester.getTopLeft(find.text('捕获')).dx;
    final notesLeft = tester.getTopLeft(find.text('笔记')).dx;
    final timelineLeft = tester.getTopLeft(find.text('时间线')).dx;
    final settingsLeft = tester.getTopLeft(find.text('设置')).dx;

    expect(captureLeft, lessThan(notesLeft));
    expect(notesLeft, lessThan(timelineLeft));
    expect(timelineLeft, lessThan(settingsLeft));
  });

  testWidgets('bottom navigation tab switch uses nonlinear animation', (
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

    final selectedPill = tester.widget<AnimatedContainer>(
      find.byKey(const ValueKey('nav-pill-0')),
    );
    expect(selectedPill.curve, Curves.easeOutBack);
  });
}
