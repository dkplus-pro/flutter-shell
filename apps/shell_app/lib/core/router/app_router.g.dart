// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_router.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// App router. keepAlive: the router must survive navigation (a page-scoped
/// router would reset navigation state on every rebuild).
///
/// The three main tabs live in a [StatefulShellRoute.indexedStack]; the demo
/// opens directly on the concierge chat (PRD 4). The bridge demo stays a
/// top-level route so it fills the whole screen.

@ProviderFor(appRouter)
final appRouterProvider = AppRouterProvider._();

/// App router. keepAlive: the router must survive navigation (a page-scoped
/// router would reset navigation state on every rebuild).
///
/// The three main tabs live in a [StatefulShellRoute.indexedStack]; the demo
/// opens directly on the concierge chat (PRD 4). The bridge demo stays a
/// top-level route so it fills the whole screen.

final class AppRouterProvider
    extends $FunctionalProvider<GoRouter, GoRouter, GoRouter>
    with $Provider<GoRouter> {
  /// App router. keepAlive: the router must survive navigation (a page-scoped
  /// router would reset navigation state on every rebuild).
  ///
  /// The three main tabs live in a [StatefulShellRoute.indexedStack]; the demo
  /// opens directly on the concierge chat (PRD 4). The bridge demo stays a
  /// top-level route so it fills the whole screen.
  AppRouterProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'appRouterProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$appRouterHash();

  @$internal
  @override
  $ProviderElement<GoRouter> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  GoRouter create(Ref ref) {
    return appRouter(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GoRouter value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GoRouter>(value),
    );
  }
}

String _$appRouterHash() => r'734054122d63c8b4ce86a655c8ec1ecde3efe781';
