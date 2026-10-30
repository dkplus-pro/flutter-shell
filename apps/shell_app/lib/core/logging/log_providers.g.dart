// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'log_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// App-level logger. Overridden once in `bootstrap.dart`; keepAlive because
/// the logger lives as long as the process and its root sink is installed
/// exactly once by [AppLogger.create].

@ProviderFor(appLogger)
final appLoggerProvider = AppLoggerProvider._();

/// App-level logger. Overridden once in `bootstrap.dart`; keepAlive because
/// the logger lives as long as the process and its root sink is installed
/// exactly once by [AppLogger.create].

final class AppLoggerProvider
    extends $FunctionalProvider<AppLogger, AppLogger, AppLogger>
    with $Provider<AppLogger> {
  /// App-level logger. Overridden once in `bootstrap.dart`; keepAlive because
  /// the logger lives as long as the process and its root sink is installed
  /// exactly once by [AppLogger.create].
  AppLoggerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'appLoggerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$appLoggerHash();

  @$internal
  @override
  $ProviderElement<AppLogger> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  AppLogger create(Ref ref) {
    return appLogger(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AppLogger value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AppLogger>(value),
    );
  }
}

String _$appLoggerHash() => r'eff503f4004c59b85480192b87a168ae31220608';
