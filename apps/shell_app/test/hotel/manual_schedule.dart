import 'dart:async';
import 'dart:math';

import 'package:fluttershell/features/hotel/application/hotel_clock.dart';

/// Deterministic clock for controller tests: `now` advances only through
/// [elapse], and scheduled callbacks fire in deadline order inside the
/// test's own control — no real timers involved.
class ManualSchedule {
  DateTime _current = DateTime(2026, 11, 1, 9);

  final List<_Entry> _entries = <_Entry>[];

  DateTime get now => _current;

  HotelClock buildClock() {
    return HotelClock(
      now: () => _current,
      random: Random(1),
      schedule: _schedule,
    );
  }

  Timer _schedule(Duration delay, void Function() action) {
    final entry = _Entry(_current.add(delay), action);
    _entries.add(entry);
    return _ManualTimer(() => _entries.remove(entry));
  }

  bool get hasPendingTimers => _entries.isNotEmpty;

  /// Advances the clock and synchronously fires every callback whose
  /// deadline has been reached, in deadline order.
  void elapse(Duration duration) {
    _current = _current.add(duration);
    final due =
        _entries.where((entry) => !entry.deadline.isAfter(_current)).toList()
          ..sort((a, b) => a.deadline.compareTo(b.deadline));
    for (final entry in due) {
      _entries.remove(entry);
      entry.action();
    }
  }
}

class _Entry {
  const new(this.deadline, this.action);

  final DateTime deadline;
  final void Function() action;
}

class _ManualTimer implements Timer {
  new(this._onCancel);

  final void Function() _onCancel;

  @override
  void cancel() => _onCancel();

  @override
  bool get isActive => true;

  @override
  int get tick => 0;
}
