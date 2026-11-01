/// Normalization and slot parsers for the scripted concierge (PRD 7.1).
///
/// Pure functions; intentionally limited templates. Anything that fails to
/// parse returns null and the agent falls back to tappable chips instead of
/// guessing (PRD 11).
library;

/// Normalized text: trimmed, lower-cased, full-width characters folded to
/// half-width (e.g. `ＷＩＦＩ` -> `wifi`, `：` -> `:`).
String normalizeInput(String raw) {
  final buffer = StringBuffer();
  for (final rune in raw.trim().runes) {
    if (rune == 0x3000) {
      buffer.writeCharCode(0x20);
    } else if (rune >= 0xFF01 && rune <= 0xFF5E) {
      buffer.writeCharCode(rune - 0xFEE0);
    } else {
      buffer.writeCharCode(rune);
    }
  }
  return buffer.toString().toLowerCase();
}

/// Chinese numerals accepted by the quantity slot; `two` maps to 2 (PRD 7.1).
const _chineseDigits = <String, int>{
  '一': 1,
  '二': 2,
  '两': 2,
  '三': 3,
  '四': 4,
  '五': 5,
  '六': 6,
  '七': 7,
  '八': 8,
  '九': 9,
};

/// Quantity slot: accepts Arabic digits or Chinese numerals, clamped to
/// 1-9. Returns null when no valid quantity is present.
int? parseQuantity(String normalized) {
  final arabic = RegExp(r'\d+').firstMatch(normalized);
  if (arabic != null) {
    final value = int.parse(arabic.group(0)!);
    return value >= 1 && value <= 9 ? value : null;
  }
  for (final rune in normalized.runes) {
    final digit = _chineseDigits[String.fromCharCode(rune)];
    if (digit != null) {
      return digit;
    }
  }
  return null;
}

/// Parsed time slot: wall-clock time plus whether it refers to tomorrow.
class TimeSlot {
  const new({required this.hour, required this.minute, required this.nextDay});

  final int hour;
  final int minute;
  final bool nextDay;

  /// Zero-padded `HH:mm`.
  String get label =>
      '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
}

const _tomorrowMarkers = ['明天', '明日', '明早', 'tomorrow'];

/// Chinese hour numerals accepted by the time slot (`两点` -> 2, `十二点`
/// -> 12); `两` maps to 2 like the quantity slot.
const _chineseHours = <String, int>{
  '一': 1,
  '二': 2,
  '两': 2,
  '三': 3,
  '四': 4,
  '五': 5,
  '六': 6,
  '七': 7,
  '八': 8,
  '九': 9,
  '十': 10,
};

/// Parses `X` as an hour: Arabic digits or up to two Chinese numerals
/// (十/十一/十二 included).
int? _parseHour(String raw) {
  final arabic = int.tryParse(raw);
  if (arabic != null) {
    return arabic;
  }
  if (raw == '十一') {
    return 11;
  }
  if (raw == '十二') {
    return 12;
  }
  return _chineseHours[raw];
}

/// Time slot: supports `HH:mm`, `X点半/X点Y分` (Arabic or Chinese hours)
/// with day-period words (早上/上午/中午/下午/晚上) and tomorrow markers.
/// Returns null when no recognizable time template is present.
TimeSlot? parseTimeOfDay(String normalized) {
  final nextDay = _tomorrowMarkers.any(normalized.contains);

  final clock = RegExp(r'(\d{1,2})\s*[:：]\s*(\d{2})').firstMatch(normalized);
  if (clock != null) {
    final hour = int.parse(clock.group(1)!);
    final minute = int.parse(clock.group(2)!);
    return _slot(hour, minute, nextDay);
  }

  final spoken = RegExp(
    r'(\d{1,2}|[一二两三四五六七八九十]{1,2})\s*点\s*(?:半|(\d{1,2})\s*分)?',
  ).firstMatch(normalized);
  if (spoken == null) {
    return null;
  }
  final hour = _parseHour(spoken.group(1)!);
  if (hour == null) {
    return null;
  }
  final half = spoken.group(0)!.contains('半');
  final minute = half ? 30 : int.tryParse(spoken.group(2) ?? '') ?? 0;

  final isAfternoon = normalized.contains('下午') || normalized.contains('晚上');
  final isNoon = normalized.contains('中午');
  final adjusted = isAfternoon || isNoon ? hour % 12 + 12 : hour;
  return _slot(adjusted, minute, nextDay);
}

TimeSlot? _slot(int hour, int minute, bool nextDay) {
  if (hour < 0 || hour > 23 || minute < 0 || minute > 59) {
    return null;
  }
  return TimeSlot(hour: hour, minute: minute, nextDay: nextDay);
}

/// Guest phrases that abandon an active slot-filling flow (PRD 7.1).
const _cancelMarkers = [
  '不用了',
  '不用',
  '取消',
  '算了',
  'cancel',
  'never mind',
  'no thanks',
];

bool isCancelIntent(String normalized) =>
    _cancelMarkers.any(normalized.contains);
