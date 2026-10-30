// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'config_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Application environment. Overridden once in `bootstrap.dart`; the default
/// throws so a missing override is caught immediately instead of silently
/// running with the wrong environment.

@ProviderFor(appEnv)
final appEnvProvider = AppEnvProvider._();

/// Application environment. Overridden once in `bootstrap.dart`; the default
/// throws so a missing override is caught immediately instead of silently
/// running with the wrong environment.

final class AppEnvProvider extends $FunctionalProvider<AppEnv, AppEnv, AppEnv>
    with $Provider<AppEnv> {
  /// Application environment. Overridden once in `bootstrap.dart`; the default
  /// throws so a missing override is caught immediately instead of silently
  /// running with the wrong environment.
  AppEnvProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'appEnvProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$appEnvHash();

  @$internal
  @override
  $ProviderElement<AppEnv> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  AppEnv create(Ref ref) {
    return appEnv(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AppEnv value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AppEnv>(value),
    );
  }
}

String _$appEnvHash() => r'06d6d1fea54f13339887caca844721cd8e221b05';
