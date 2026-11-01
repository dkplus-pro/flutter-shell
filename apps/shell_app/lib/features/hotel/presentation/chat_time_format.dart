/// Chat transcript time formatting.
///
/// Deliberately hand-rolled instead of pulling `intl` into the app: the
/// transcript only needs `HH:mm` timestamps and a `yyyy-MM-dd` date label.
abstract final class ChatTimeFormat {
  /// `HH:mm` in 24-hour form, zero-padded.
  static String hm(DateTime time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  /// `yyyy-MM-dd`, used by the day separator.
  static String day(DateTime time) {
    final month = time.month.toString().padLeft(2, '0');
    final day = time.day.toString().padLeft(2, '0');
    return '${time.year}-$month-$day';
  }
}
