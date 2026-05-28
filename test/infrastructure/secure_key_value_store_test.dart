import 'package:flutter_test/flutter_test.dart';
import 'package:glass_note/infrastructure/security/in_memory_secure_key_value_store.dart';

void main() {
  test('secure key value store writes reads and deletes secrets', () async {
    final store = InMemorySecureKeyValueStore();

    await store.writeSecret(key: 'deepseek_api_key', value: 'secret-value');
    expect(await store.readSecret('deepseek_api_key'), 'secret-value');

    await store.deleteSecret('deepseek_api_key');
    expect(await store.readSecret('deepseek_api_key'), isNull);
  });
}
