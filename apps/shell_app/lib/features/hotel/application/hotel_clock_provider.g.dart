// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'hotel_clock_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Real clock/timer source for the demo. keepAlive: process-wide service;
/// swapping implementations only happens in tests via overrides.

@ProviderFor(hotelClock)
final hotelClockProvider = HotelClockProvider._();

/// Real clock/timer source for the demo. keepAlive: process-wide service;
/// swapping implementations only happens in tests via overrides.

final class HotelClockProvider
    extends $FunctionalProvider<HotelClock, HotelClock, HotelClock>
    with $Provider<HotelClock> {
  /// Real clock/timer source for the demo. keepAlive: process-wide service;
  /// swapping implementations only happens in tests via overrides.
  HotelClockProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'hotelClockProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$hotelClockHash();

  @$internal
  @override
  $ProviderElement<HotelClock> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  HotelClock create(Ref ref) {
    return hotelClock(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(HotelClock value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<HotelClock>(value),
    );
  }
}

String _$hotelClockHash() => r'dc16c0f7628684de6afd808aee61ab7c7703ac35';
