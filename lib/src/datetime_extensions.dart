import 'package:intl/intl.dart';

/// Converts epoch milliseconds to [DateTime].
extension DateTimeFromMillis on int {
  DateTime get dateTimeFromMillis =>
      DateTime.fromMillisecondsSinceEpoch(this);
}

/// Converts nullable epoch milliseconds to a nullable [DateTime].
extension NullableDateTimeFromMillis on int? {
  DateTime? get dateTimeFromMillis {
    if (this == null) return null;
    return DateTime.fromMillisecondsSinceEpoch(this!);
  }
}

/// Extensions on DateTime.
extension DateTimeExtensions on DateTime {
  /// Check if same calendar day as another date.
  bool sameDayAs(DateTime other) =>
      year == other.year && month == other.month && day == other.day;

  /// Check if this date is today.
  bool get isToday => sameDayAs(DateTime.now());

  /// Milliseconds since epoch as double.
  double get millisSinceEpoch => millisecondsSinceEpoch.toDouble();

  /// Start of day (midnight).
  DateTime get startOfDay => DateTime(year, month, day);

  /// End of day (23:59:59.999).
  DateTime get endOfDay => DateTime(year, month, day, 23, 59, 59, 999);

  /// First instant of this calendar month.
  DateTime get startOfMonth => DateTime(year, month, 1);

  /// First instant of the next calendar month.
  DateTime get startOfNextMonth =>
      month == 12 ? DateTime(year + 1, 1, 1) : DateTime(year, month + 1, 1);

  /// `YYYY-MM` for this date's year/month components.
  String get yearMonthKey {
    final month = this.month.toString().padLeft(2, '0');
    return '$year-$month';
  }

  /// Local calendar day as `YYYY-MM-DD`.
  String get dayKey {
    final local = toLocal();
    final month = local.month.toString().padLeft(2, '0');
    final day = local.day.toString().padLeft(2, '0');
    return '${local.year}-$month-$day';
  }

  /// Midnight of the calendar day [days] away from this date.
  ///
  /// Shifts via the `DateTime` constructor rather than `Duration(days:)` so
  /// daylight-saving transitions never push the result off local midnight.
  /// The time component is always dropped, so the result is comparable with
  /// other midnight-keyed dates.
  DateTime shiftedByDays(int days) => DateTime(year, month, day + days);

  /// Absolute difference in local calendar days between this and [other].
  int calendarDayDiff(DateTime other) => toLocal()
      .startOfDay
      .difference(other.toLocal().startOfDay)
      .inDays
      .abs();

  /// Compact relative label (`just now`, `5m ago`, `3d ago`, `2w ago`,
  /// `4mo ago`, `1y ago`). When [includeClock] is true and the span is a
  /// week or longer, returns a calendar date with time instead.
  String relativeTimeAgo({bool includeClock = false}) {
    final local = toLocal();
    final difference = DateTime.now().difference(local);
    if (difference.inMinutes < 1) return 'just now';
    if (difference.inHours < 1) return '${difference.inMinutes}m ago';
    if (difference.inDays < 1) return '${difference.inHours}h ago';
    if (difference.inDays < 7) return '${difference.inDays}d ago';
    if (includeClock) return DateFormat.MMMd().add_jm().format(local);
    if (difference.inDays < 30) return '${difference.inDays ~/ 7}w ago';
    if (difference.inDays < 365) return '${difference.inDays ~/ 30}mo ago';
    return '${difference.inDays ~/ 365}y ago';
  }
}