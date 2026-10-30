import 'package:app_core/app_core.dart';
import 'package:fluttershell/core/config/config_providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'network_providers.g.dart';

/// Placeholder API client; no business calls in v0. keepAlive: the client
/// owns a Dio instance whose lifetime matches the app.
@Riverpod(keepAlive: true)
ApiClient apiClient(Ref ref) {
  final env = ref.watch(appEnvProvider);
  return DioApiClient(baseUrl: env.apiBaseUrl);
}
