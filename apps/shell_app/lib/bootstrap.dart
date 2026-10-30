import 'package:app_core/app_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:fluttershell/app.dart';
import 'package:fluttershell/core/config/config_providers.dart';
import 'package:fluttershell/core/error/error_handlers.dart';
import 'package:fluttershell/core/logging/log_providers.dart';

/// Composition root. Builds environment, logger and global error handling
/// before running the app; no bridge calls happen before the first frame.
void bootstrap() {
  WidgetsFlutterBinding.ensureInitialized();

  final env = AppEnv.fromDartDefine();
  final logger = AppLogger.create(isProd: env.isProd);
  installGlobalErrorHandlers(logger, isProd: env.isProd);

  runApp(
    ProviderScope(
      overrides: [
        appEnvProvider.overrideWithValue(env),
        appLoggerProvider.overrideWithValue(logger),
      ],
      child: const ShellApp(),
    ),
  );
}
