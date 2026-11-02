import 'dart:async';
import 'dart:math';

/// Process-wide clock/timer service for the hotel demo (PRD 7.3: pacing and
/// state-machine intervals are constants, injectable for tests).
class HotelClock {
  new({
    DateTime Function()? now,
    Random? random,
    Timer Function(Duration delay, void Function() action)? schedule,
    this.placedToDelivering = const Duration(seconds: 3),
    this.deliveringToDelivered = const Duration(seconds: 8),
    this.minTypingDelay = const Duration(milliseconds: 800),
    this.maxTypingDelay = const Duration(milliseconds: 1500),
  }) : _now = now ?? DateTime.now,
       _random = random ?? Random(),
       _schedule = schedule ?? _defaultSchedule;

  static Timer _defaultSchedule(Duration delay, void Function() action) =>
      Timer(delay, action);

  final DateTime Function() _now;
  final Random _random;
  final Timer Function(Duration delay, void Function() action) _schedule;

  /// Order state machine pacing (PRD 6.3: ~3s placed, ~8s delivering).
  final Duration placedToDelivering;
  final Duration deliveringToDelivered;

  /// "Typing" indicator range before a concierge reply (PRD 7.3).
  final Duration minTypingDelay;
  final Duration maxTypingDelay;

  DateTime now() => _now();

  /// Uniformly random duration in [minTypingDelay, maxTypingDelay].
  Duration nextTypingDelay() {
    final span = maxTypingDelay.inMilliseconds - minTypingDelay.inMilliseconds;
    final offset = span <= 0 ? 0 : _random.nextInt(span + 1);
    return minTypingDelay + Duration(milliseconds: offset);
  }

  Timer schedule(Duration delay, void Function() action) =>
      _schedule(delay, action);
}
