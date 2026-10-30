import 'package:app_core/app_core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  test('write, read and delete round-trip with app. prefix', () async {
    final store = SharedPreferencesKeyValueStore();

    await store.write('token', 'v1');
    expect(await store.read('token'), 'v1');

    // Keys are stored with the app. prefix in the underlying prefs.
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getKeys(), contains('app.token'));

    await store.delete('token');
    expect(await store.read('token'), isNull);
  });

  test('read of missing key returns null', () async {
    final store = SharedPreferencesKeyValueStore();
    expect(await store.read('missing'), isNull);
  });
}
