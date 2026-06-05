import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:glass_note/features/notes/presentation/widgets/rich_toolbar_toggle.dart';

void main() {
  test(
    'rich toolbar uses toggle state instead of direct format application',
    () {
      final source = File(
        'lib/features/notes/presentation/note_rich_editor_page.dart',
      ).readAsStringSync();

      expect(source, isNot(contains('formatSelection(Attribute.bold)')));
      expect(source, isNot(contains('formatSelection(Attribute.italic)')));
      expect(source, contains('ListenableBuilder'));
      expect(source, contains('selected:'));
    },
  );

  test('collapsed cursor toggles bold on and off for future input', () {
    final controller = QuillController.basic();

    toggleRichToolbarSelection(controller, Attribute.bold);
    expect(
      controller.getSelectionStyle().attributes,
      contains(Attribute.bold.key),
    );

    toggleRichToolbarSelection(controller, Attribute.bold);
    expect(
      controller.getSelectionStyle().attributes,
      isNot(contains(Attribute.bold.key)),
    );
  });

  test('collapsed cursor can stop italic before later inserted text', () {
    final controller = QuillController.basic();

    toggleRichToolbarSelection(controller, Attribute.italic);
    controller.replaceText(0, 0, 'italic', null);
    controller.updateSelection(
      const TextSelection.collapsed(offset: 6),
      ChangeSource.local,
    );

    toggleRichToolbarSelection(controller, Attribute.italic);
    controller.replaceText(6, 0, ' plain', null);

    final ops = controller.document.toDelta().toJson();
    expect(ops[0], {
      'insert': 'italic',
      'attributes': {'italic': true},
    });
    expect(ops[1], {'insert': ' plain\n'});
  });

  test('selected text formatting only changes the selected range', () {
    final controller = QuillController(
      document: Document.fromJson([
        {'insert': 'hello world\n'},
      ]),
      selection: const TextSelection(baseOffset: 0, extentOffset: 5),
    );

    toggleRichToolbarSelection(controller, Attribute.bold);

    final ops = controller.document.toDelta().toJson();
    expect(ops[0], {
      'insert': 'hello',
      'attributes': {'bold': true},
    });
    expect(ops[1], {'insert': ' world\n'});
  });

  test('block formats toggle off only when the current value matches', () {
    final activeHeader = {Attribute.header.key: Attribute.h1};
    final activeList = {Attribute.list.key: Attribute.unchecked};

    expect(
      richToolbarAttributeForToggle(Attribute.h1, activeHeader).value,
      isNull,
    );
    expect(
      richToolbarAttributeForToggle(Attribute.ul, activeHeader),
      Attribute.ul,
    );
    expect(
      richToolbarAttributeForToggle(Attribute.unchecked, activeList).value,
      isNull,
    );
  });
}
