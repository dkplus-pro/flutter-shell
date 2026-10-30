import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:native_bridge/native_bridge.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('bridge method and ticker work on device', (tester) async {
    final bridge = NativeBridge()..initialize();
    final info = await bridge.getSystemInfo();
    expect(info.platform, 'android');
    expect(info.osVersion, contains('API '));
    final ticks = await bridge
        .ticks()
        .take(2)
        .toList()
        .timeout(const Duration(seconds: 6));
    expect(ticks.length, 2);
    expect(ticks.first, 0);
  });
}
