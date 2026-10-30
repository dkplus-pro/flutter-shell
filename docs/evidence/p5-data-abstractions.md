# P5 · 网络与存储抽象证据（2026-10-31）

## 实现

- `app_core`：
  - `ApiClient` 接口（`getJson(Uri, {headers}) → Map<String, Object?>`）+ `DioApiClient`（connect/receive 10s 超时；非 2xx / 非 Map / `DioException` / 其他异常统一 `NetworkFailure`）。
  - `KeyValueStore` 接口（read/write/delete）+ `SharedPreferencesKeyValueStore`（key 自动加 `app.` 前缀；异常统一 `StorageFailure`）。
  - `app_core.dart` barrel 恢复全部导出。
- app 接线：`core/network/network_providers.dart`（`apiClientProvider`，baseUrl 来自 `appEnvProvider`）、`core/storage/storage_providers.dart`（`keyValueStoreProvider`）。v0 无业务调用。
- 未添加 INTERNET 权限（连接错误测试只用本地不可达端口）。

## 测试（packages/app_core，9/9 通过）

```
app_env_test: parse dev/prod ✓、staging→ArgumentError ✓、placeholder baseUrl ✓
dio_api_client_test: 200 JSON 解码 ✓、200 非 Map → NetworkFailure ✓、500 → NetworkFailure(cause=DioException) ✓、连接拒绝 → NetworkFailure ✓
key_value_store_test: 写读删 + app. 前缀断言 ✓、缺失 key → null ✓

$ fvm flutter test  (packages/app_core)
00:00 +9: All tests passed!
```

## 静态检查

```
fvm flutter analyze --fatal-infos  # 四包全部 No issues found!
# shell_app 重新 build_runner 生成 network/storage provider 后 5/5 widget 测试通过
```

## Gate 结论

- app_core 单测 9/9 ✅（错误映射、读写删除、env 解析）
- analyze 零 issue ✅
