import 'package:ethan_utils/ethan_utils.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CalendarDay', () {
    test('epoch and civil dates round-trip', () {
      expect(CalendarDay.of(1970, 1, 1).sinceEpoch, 0);
      expect(CalendarDay.of(1969, 12, 31).sinceEpoch, -1);
      expect(CalendarDay.of(2000, 3, 1).sinceEpoch, 11017);
      for (final (year, month, day) in [
        (2026, 3, 8),
        (2024, 2, 29),
        (1999, 12, 31),
        (1969, 7, 20),
      ]) {
        final calendarDay = CalendarDay.of(year, month, day);
        expect(calendarDay.year, year);
        expect(calendarDay.month, month);
        expect(calendarDay.day, day);
        expect(
          calendarDay.isoDate,
          DateTime(year, month, day).toIso8601String().substring(0, 10),
        );
      }
    });

    test('fromLocalMillis picks the local day, including around DST', () {
      for (final instant in [
        DateTime(2026, 4, 5, 10, 11),
        DateTime(2026, 4, 5),
        DateTime(2026, 4, 5, 23, 59, 59, 999),
        DateTime(2026, 3, 8, 1, 30),
        DateTime(2026, 3, 8, 3, 30),
        DateTime(2026, 3, 8, 23, 30),
        DateTime(2026, 11, 1, 0, 30),
        DateTime(2026, 11, 1, 1, 30),
        DateTime(2026, 11, 1, 23, 30),
        DateTime(2026, 11, 2),
      ]) {
        expect(
          CalendarDay.fromLocalMillis(instant.millisecondsSinceEpoch),
          CalendarDay.of(instant.year, instant.month, instant.day),
          reason: '$instant',
        );
        expect(
          instant.calendarDay,
          CalendarDay.of(instant.year, instant.month, instant.day),
        );
      }
    });

    test('a UTC instant keeps its UTC date', () {
      expect(
        DateTime.utc(2026, 4, 5, 23, 59).calendarDay,
        CalendarDay.of(2026, 4, 5),
      );
    });

    test('localMidnight matches DateTime(year, month, day) across DST', () {
      for (final (year, month, day) in [
        (2026, 4, 5),
        (2026, 3, 8),
        (2026, 3, 9),
        (2026, 11, 1),
        (2026, 11, 2),
        (1969, 7, 20),
      ]) {
        final calendarDay = CalendarDay.of(year, month, day);
        expect(calendarDay.localMidnight, DateTime(year, month, day));
        expect(
          calendarDay.localMidnightMillis,
          DateTime(year, month, day).millisecondsSinceEpoch,
        );
      }
    });

    test('day arithmetic and month starts are integer steps', () {
      final day = CalendarDay.of(2026, 3, 7);
      expect(day.plusDays(1), CalendarDay.of(2026, 3, 8));
      expect(day.plusDays(2), CalendarDay.of(2026, 3, 9));
      expect(CalendarDay.of(2026, 3, 9).daysSince(day), 2);
      expect(day.daysSince(CalendarDay.of(2026, 3, 9)), -2);
      expect(day.startOfMonth, CalendarDay.of(2026, 3, 1));
      expect(day.startOfNextMonth, CalendarDay.of(2026, 4, 1));
      expect(
        CalendarDay.of(2026, 12, 25).startOfNextMonth,
        CalendarDay.of(2027, 1, 1),
      );
      expect(day.isBefore(day.plusDays(1)), isTrue);
      expect(day.isAfter(day.plusDays(1)), isFalse);
      expect(day.compareTo(day.plusDays(1)), lessThan(0));
    });
  });
}
