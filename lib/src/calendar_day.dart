/// A calendar day as a count of days since 1970-01-01, so day arithmetic,
/// comparison, and map keys are integer operations.
///
/// Building a local [DateTime] costs ~12µs for the time-zone lookup, and
/// ~37µs through `DateTime(year, month, day)`; rows that carry a day (bank
/// posted dates, daily balances) decode into this instead. The time-zone
/// offset is looked up once per UTC day and reused, with an exact lookup only
/// on the two days a year the offset changes.
class const CalendarDay(final int sinceEpoch)
    implements Comparable<CalendarDay> {
  static const _dayMillis = Duration.millisecondsPerDay;

  /// Offsets at the start and end of each UTC day, keyed by UTC day number.
  static final Map<int, _UtcDayOffsets> _offsetsByUtcDay = {};
  static const _offsetCacheMaxEntries = 20000;

  /// The local calendar day containing the instant [millis] since epoch.
  factory fromLocalMillis(int millis) {
    return CalendarDay(_floorDiv(millis + _offsetMillisAt(millis), _dayMillis));
  }

  /// [dateTime]'s own calendar day: UTC date for a UTC instant, else local.
  factory fromDateTime(DateTime dateTime) {
    if (dateTime.isUtc) {
      return CalendarDay(
        _floorDiv(dateTime.millisecondsSinceEpoch, _dayMillis),
      );
    }
    return CalendarDay.fromLocalMillis(dateTime.millisecondsSinceEpoch);
  }

  factory of(int year, int month, int day) =>
      CalendarDay(_daysFromCivil(year, month, day));

  factory today() =>
      CalendarDay.fromLocalMillis(DateTime.now().millisecondsSinceEpoch);

  int get year => _civil.year;
  int get month => _civil.month;
  int get day => _civil.day;

  CalendarDay plusDays(int days) => CalendarDay(sinceEpoch + days);

  /// Days from [earlier] to this day; negative when [earlier] is later.
  int daysSince(CalendarDay earlier) => sinceEpoch - earlier.sinceEpoch;

  bool isBefore(CalendarDay other) => sinceEpoch < other.sinceEpoch;
  bool isAfter(CalendarDay other) => sinceEpoch > other.sinceEpoch;

  CalendarDay get startOfMonth => CalendarDay.of(year, month, 1);

  CalendarDay get startOfNextMonth => month == 12
      ? CalendarDay.of(year + 1, 1, 1)
      : CalendarDay.of(year, month + 1, 1);

  /// Local midnight that begins this day.
  DateTime get localMidnight {
    final int utcMidnightMillis = sinceEpoch * _dayMillis;
    final candidate = DateTime.fromMillisecondsSinceEpoch(
      utcMidnightMillis - _offsetMillisAt(utcMidnightMillis),
    );
    if (candidate.hour == 0) return candidate;
    final int hoursOff = candidate.hour >= 12
        ? candidate.hour - 24
        : candidate.hour;
    return DateTime.fromMillisecondsSinceEpoch(
      candidate.millisecondsSinceEpoch -
          hoursOff * Duration.millisecondsPerHour,
    );
  }

  /// Epoch milliseconds of [localMidnight]; the stored form of a day.
  int get localMidnightMillis => localMidnight.millisecondsSinceEpoch;

  /// `2026-03`.
  String get yearMonthKey {
    final civil = _civil;
    return '${civil.year.toString().padLeft(4, '0')}-'
        '${civil.month.toString().padLeft(2, '0')}';
  }

  /// `2026-03-08`.
  String get isoDate {
    final civil = _civil;
    return '${civil.year.toString().padLeft(4, '0')}-'
        '${civil.month.toString().padLeft(2, '0')}-'
        '${civil.day.toString().padLeft(2, '0')}';
  }

  @override
  int compareTo(CalendarDay other) => sinceEpoch.compareTo(other.sinceEpoch);

  @override
  bool operator ==(Object other) =>
      other is CalendarDay && other.sinceEpoch == sinceEpoch;

  @override
  int get hashCode => sinceEpoch.hashCode;

  @override
  String toString() => isoDate;

  _CivilDate get _civil => _civilFromDays(sinceEpoch);

  static int _floorDiv(int dividend, int divisor) =>
      (dividend - dividend % divisor) ~/ divisor;

  /// Local offset from UTC at [millis]. One lookup per UTC day, except on a
  /// day whose offset changes, where every instant is looked up exactly.
  static int _offsetMillisAt(int millis) {
    final int utcDay = _floorDiv(millis, _dayMillis);
    _UtcDayOffsets? offsets = _offsetsByUtcDay[utcDay];
    if (offsets == null) {
      if (_offsetsByUtcDay.length >= _offsetCacheMaxEntries) {
        _offsetsByUtcDay.clear();
      }
      offsets = _UtcDayOffsets(
        atStart: _exactOffsetMillisAt(utcDay * _dayMillis),
        atEnd: _exactOffsetMillisAt((utcDay + 1) * _dayMillis - 1),
      );
      _offsetsByUtcDay[utcDay] = offsets;
    }
    if (offsets.atStart == offsets.atEnd) return offsets.atStart;
    return _exactOffsetMillisAt(millis);
  }

  static int _exactOffsetMillisAt(int millis) =>
      DateTime.fromMillisecondsSinceEpoch(millis).timeZoneOffset.inMilliseconds;

  // Proleptic Gregorian conversions (Howard Hinnant's algorithms).
  static int _daysFromCivil(int year, int month, int day) {
    final int shiftedYear = month <= 2 ? year - 1 : year;
    final int era = (shiftedYear >= 0 ? shiftedYear : shiftedYear - 399) ~/ 400;
    final int yearOfEra = shiftedYear - era * 400;
    final int dayOfYear =
        (153 * (month > 2 ? month - 3 : month + 9) + 2) ~/ 5 + day - 1;
    final int dayOfEra =
        yearOfEra * 365 + yearOfEra ~/ 4 - yearOfEra ~/ 100 + dayOfYear;
    return era * 146097 + dayOfEra - 719468;
  }

  static _CivilDate _civilFromDays(int sinceEpoch) {
    final int shifted = sinceEpoch + 719468;
    final int era = (shifted >= 0 ? shifted : shifted - 146096) ~/ 146097;
    final int dayOfEra = shifted - era * 146097;
    final int yearOfEra =
        (dayOfEra -
            dayOfEra ~/ 1460 +
            dayOfEra ~/ 36524 -
            dayOfEra ~/ 146096) ~/
        365;
    final int dayOfYear =
        dayOfEra - (365 * yearOfEra + yearOfEra ~/ 4 - yearOfEra ~/ 100);
    final int monthIndex = (5 * dayOfYear + 2) ~/ 153;
    final int day = dayOfYear - (153 * monthIndex + 2) ~/ 5 + 1;
    final int month = monthIndex < 10 ? monthIndex + 3 : monthIndex - 9;
    final int year = yearOfEra + era * 400 + (month <= 2 ? 1 : 0);
    return _CivilDate(year: year, month: month, day: day);
  }
}

class const _CivilDate({
  required final int year,
  required final int month,
  required final int day,
});

class const _UtcDayOffsets({
  required final int atStart,
  required final int atEnd,
});

extension CalendarDayOfDateTime on DateTime {
  /// This instant's calendar day: UTC date for a UTC instant, else local.
  CalendarDay get calendarDay => CalendarDay.fromDateTime(this);
}
