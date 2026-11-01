import 'package:fluttershell/features/hotel/application/hotel_clock.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'hotel_clock_provider.g.dart';

/// Real clock/timer source for the demo. keepAlive: process-wide service;
/// swapping implementations only happens in tests via overrides.
@Riverpod(keepAlive: true)
HotelClock hotelClock(Ref ref) => HotelClock();
