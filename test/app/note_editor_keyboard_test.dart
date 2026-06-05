import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('note body editor is wired with explicit focus and tap handling', () {
    final source = File(
      'lib/features/notes/presentation/note_rich_editor_page.dart',
    ).readAsStringSync();

    expect(source, contains('final _bodyFocusNode = FocusNode();'));
    expect(
      source,
      contains('final _bodyScrollController = ScrollController();'),
    );
    expect(source, contains('focusNode: _bodyFocusNode'));
    expect(source, contains('scrollController: _bodyScrollController'));
    expect(source, contains('onTapDown: (_) => _bodyFocusNode.requestFocus()'));
    expect(source, contains('resizeToAvoidBottomInset: false'));
  });
}
