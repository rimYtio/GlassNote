import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'domain layer stays independent from Flutter and infrastructure packages',
    () {
      final imports = _dartImportsUnder('lib/domain');

      expect(imports, isNot(contains('package:flutter/')));
      expect(imports, isNot(contains('package:drift/')));
      expect(imports, isNot(contains('package:path_provider/')));
      expect(imports, isNot(contains('package:http/')));
    },
  );

  test('application layer does not depend on Flutter widget concerns', () {
    final contents = _dartContentsUnder('lib/application');

    expect(contents, isNot(contains('Widget')));
    expect(contents, isNot(contains('BuildContext')));
    expect(contents, isNot(contains('AnimationController')));
  });

  test(
    'presentation layer does not import concrete database implementation',
    () {
      final imports = _dartImportsUnder('lib/features');

      expect(imports, isNot(contains('infrastructure/database')));
      expect(imports, isNot(contains('package:drift/')));
    },
  );
}

String _dartImportsUnder(String path) {
  return _dartFilesUnder(path)
      .expand(
        (file) => file.readAsLinesSync().where(
          (line) => line.trimLeft().startsWith('import '),
        ),
      )
      .join('\n');
}

String _dartContentsUnder(String path) {
  return _dartFilesUnder(
    path,
  ).map((file) => file.readAsStringSync()).join('\n');
}

List<File> _dartFilesUnder(String path) {
  final directory = Directory(path);
  if (!directory.existsSync()) {
    return const [];
  }

  return directory
      .listSync(recursive: true)
      .whereType<File>()
      .where((file) => file.path.endsWith('.dart'))
      .toList();
}
