// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'hotel_chat_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Mock guest binding (D8): fixed demo room for the whole session. Not
/// persisted; guest display name is ARB copy resolved at presentation time.

@ProviderFor(hotelGuestProfile)
final hotelGuestProfileProvider = HotelGuestProfileProvider._();

/// Mock guest binding (D8): fixed demo room for the whole session. Not
/// persisted; guest display name is ARB copy resolved at presentation time.

final class HotelGuestProfileProvider
    extends $FunctionalProvider<GuestProfile, GuestProfile, GuestProfile>
    with $Provider<GuestProfile> {
  /// Mock guest binding (D8): fixed demo room for the whole session. Not
  /// persisted; guest display name is ARB copy resolved at presentation time.
  HotelGuestProfileProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'hotelGuestProfileProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$hotelGuestProfileHash();

  @$internal
  @override
  $ProviderElement<GuestProfile> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  GuestProfile create(Ref ref) {
    return hotelGuestProfile(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GuestProfile value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GuestProfile>(value),
    );
  }
}

String _$hotelGuestProfileHash() => r'138bee8894b976261e0c3251312bd6bbeb67793f';

/// Chat session controller.
///
/// keepAlive: the transcript, the concierge reply queue and the order status
/// timers must survive tab switches and full-page pushes (bridge demo);
/// persistence is written from here so state also survives restarts.

@ProviderFor(HotelChatController)
final hotelChatControllerProvider = HotelChatControllerProvider._();

/// Chat session controller.
///
/// keepAlive: the transcript, the concierge reply queue and the order status
/// timers must survive tab switches and full-page pushes (bridge demo);
/// persistence is written from here so state also survives restarts.
final class HotelChatControllerProvider
    extends $NotifierProvider<HotelChatController, HotelChatState> {
  /// Chat session controller.
  ///
  /// keepAlive: the transcript, the concierge reply queue and the order status
  /// timers must survive tab switches and full-page pushes (bridge demo);
  /// persistence is written from here so state also survives restarts.
  HotelChatControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'hotelChatControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$hotelChatControllerHash();

  @$internal
  @override
  HotelChatController create() => HotelChatController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(HotelChatState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<HotelChatState>(value),
    );
  }
}

String _$hotelChatControllerHash() =>
    r'e1ce505a9c8db3a1e9506afc690ab42990a28f7b';

/// Chat session controller.
///
/// keepAlive: the transcript, the concierge reply queue and the order status
/// timers must survive tab switches and full-page pushes (bridge demo);
/// persistence is written from here so state also survives restarts.

abstract class _$HotelChatController extends $Notifier<HotelChatState> {
  HotelChatState build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<HotelChatState, HotelChatState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<HotelChatState, HotelChatState>,
              HotelChatState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
