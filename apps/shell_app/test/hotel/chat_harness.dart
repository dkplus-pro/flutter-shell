import 'package:app_core/app_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fluttershell/core/logging/log_providers.dart';
import 'package:fluttershell/core/storage/storage_providers.dart';
import 'package:fluttershell/features/hotel/application/hotel_chat_providers.dart';
import 'package:fluttershell/features/hotel/application/hotel_clock_provider.dart';

import 'fake_key_value_store.dart';
import 'manual_schedule.dart';

/// Wires the session controller to the fake store and the manual clock.
/// The controller is keepAlive: read `.future` once via [ready] before
/// acting on the notifier.
class Harness {
  new() : store = FakeKeyValueStore() {
    _wire();
  }

  /// Shares the persisted state with a previous harness, simulating an app
  /// restart against the same storage.
  new withStore(this.store) {
    _wire();
  }

  final FakeKeyValueStore store;
  final ManualSchedule schedule = ManualSchedule();
  late final ProviderContainer container;

  void _wire() {
    container = ProviderContainer(
      overrides: [
        keyValueStoreProvider.overrideWithValue(store),
        appLoggerProvider.overrideWithValue(AppLogger.create(isProd: true)),
        hotelClockProvider.overrideWithValue(schedule.buildClock()),
      ],
    );
  }

  Future<void> ready() async {
    await container.read(hotelChatControllerProvider.future);
  }

  HotelChatState get state =>
      container.read(hotelChatControllerProvider).requireValue;

  HotelChatController get notifier =>
      container.read(hotelChatControllerProvider.notifier);

  /// Lets pending microtasks (persist writes) settle.
  Future<void> settle() async {
    await pumpEventQueue();
  }

  void dispose() => container.dispose();
}
