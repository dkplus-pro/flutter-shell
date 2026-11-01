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

/// Chat session controller: transcript, concierge reply queue, order state
/// machine and KeyValueStore persistence.
///
/// keepAlive: the transcript, the reply queue and the order timers must
/// survive tab switches and pushes; persistence is written from here so the
/// session also survives restarts (PRD D10).

@ProviderFor(HotelChatController)
final hotelChatControllerProvider = HotelChatControllerProvider._();

/// Chat session controller: transcript, concierge reply queue, order state
/// machine and KeyValueStore persistence.
///
/// keepAlive: the transcript, the reply queue and the order timers must
/// survive tab switches and pushes; persistence is written from here so the
/// session also survives restarts (PRD D10).
final class HotelChatControllerProvider
    extends $AsyncNotifierProvider<HotelChatController, HotelChatState> {
  /// Chat session controller: transcript, concierge reply queue, order state
  /// machine and KeyValueStore persistence.
  ///
  /// keepAlive: the transcript, the reply queue and the order timers must
  /// survive tab switches and pushes; persistence is written from here so the
  /// session also survives restarts (PRD D10).
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
}

String _$hotelChatControllerHash() =>
    r'a37c611404df9acdf8b8440ce3accac72a84737f';

/// Chat session controller: transcript, concierge reply queue, order state
/// machine and KeyValueStore persistence.
///
/// keepAlive: the transcript, the reply queue and the order timers must
/// survive tab switches and pushes; persistence is written from here so the
/// session also survives restarts (PRD D10).

abstract class _$HotelChatController extends $AsyncNotifier<HotelChatState> {
  FutureOr<HotelChatState> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<HotelChatState>, HotelChatState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<HotelChatState>, HotelChatState>,
              AsyncValue<HotelChatState>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
