import 'package:app_core/app_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttershell/app.dart';
import 'package:fluttershell/core/bridge/bridge_providers.dart';
import 'package:fluttershell/core/config/config_providers.dart';
import 'package:fluttershell/core/error/error_handlers.dart';
import 'package:fluttershell/core/logging/log_providers.dart';
import 'package:native_bridge/native_bridge.dart';

/// Composition root. Builds environment, logger and bridge before running
/// the app; the bridge is only constructed here, no channel calls happen
/// before the first frame.
void bootstrap() {
  WidgetsFlutterBinding.ensureInitialized();

  final env = AppEnv.fromDartDefine();
  final logger = AppLogger.create(isProd: env.isProd);
  final bridge = NativeBridge()..initialize();
  installGlobalErrorHandlers(logger, isProd: env.isProd);

  runApp(
    ProviderScope(
      overrides: [
        appEnvProvider.overrideWithValue(env),
        appLoggerProvider.overrideWithValue(logger),
        nativeBridgeProvider.overrideWithValue(bridge),
      ],
      child: const ShellApp(),
    ),
  );
}
