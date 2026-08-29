import 'package:ethan_utils/ethan_utils.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('dateTimeFromMillis', () {
    test('converts int milliseconds', () {
      expect(
        0.dateTimeFromMillis,
        DateTime.fromMillisecondsSinceEpoch(0),
      );
      expect(
        1700000000000.dateTimeFromMillis,
        DateTime.fromMillisecondsSinceEpoch(1700000000000),
      );
    });

    test('returns null for null int', () {
      const int? millis = null;
      expect(millis.dateTimeFromMillis, isNull);
    });

    test('converts non-null nullable int', () {
      const int millis = 1000;
      expect(
        millis.dateTimeFromMillis,
        DateTime.fromMillisecondsSinceEpoch(1000),
      );
    });
  });

  group('calendarDayDiff', () {
    test('same local calendar day is zero', () {
      final morning = DateTime(2026, 5, 1, 9);
      final evening = DateTime(2026, 5, 1, 23, 59);
      expect(morning.calendarDayDiff(evening), 0);
    });

    test('counts whole local calendar days apart', () {
      final friday = DateTime(2026, 5, 1, 16);
      final monday = DateTime(2026, 5, 4, 10);
      expect(friday.calendarDayDiff(monday), 3);
      expect(monday.calendarDayDiff(friday), 3);
    });
  });

  group('month and day keys', () {
    test('yearMonthKey and startOfMonth', () {
      final date = DateTime(2026, 5, 17, 15);
      expect(date.yearMonthKey, '2026-05');
      expect(date.startOfMonth, DateTime(2026, 5, 1));
      expect(date.startOfNextMonth, DateTime(2026, 6, 1));
    });

    test('dayKey uses local calendar day', () {
      final date = DateTime(2026, 5, 4, 10, 30);
      expect(date.dayKey, '2026-05-04');
    });
  });

  group('asCents', () {
    test('parses decimal amounts', () {
      expect('-12.34'.asCents, -1234);
      expect('0.1'.asCents, 10);
      expect('100'.asCents, 10000);
    });
  });

  group('formatCents', () {
    test('formats with two decimal places', () {
      expect(formatCents(1234), r'$12.34');
    });
  });

  group('niceNumber', () {
    test('snaps to 1/2/5 × 10^n', () {
      expect(1200.niceNumber(round: true), 1000);
      expect(3000.niceNumber(round: true), 5000);
    });
  });

  group('asCompactCount', () {
    test('keeps small values plain', () {
      expect(324.asCompactCount, '324');
      expect(0.asCompactCount, '0');
    });

    test('uses k and M suffixes', () {
      expect(1000.asCompactCount, '1k');
      expect(1200.asCompactCount, '1.2k');
      expect(10845.asCompactCount, '10.8k');
      expect(1500000.asCompactCount, '1.5M');
    });
  });

  group('NiceValueScale', () {
    test('builds human-round ticks covering the data max', () {
      final scale = NiceValueScale.forMax(10845);
      expect(scale.max, 12000);
      expect(scale.ticks, [0, 2000, 4000, 6000, 8000, 10000, 12000]);
    });

    test('uses fallback when data max is non-positive', () {
      final scale = NiceValueScale.forMax(0, fallbackMax: 10000);
      expect(scale.max, 10000);
      expect(scale.ticks.first, 0);
      expect(scale.ticks.last, 10000);
    });
  });

  group('stableHash and shadeKeyedBy', () {
    test('stableHash is deterministic', () {
      expect('abc'.stableHash, 'abc'.stableHash);
      expect('abc'.stableHash, isNot('abd'.stableHash));
    });

    test('shadeKeyedBy returns a color', () {
      const base = Color(0xFF4361EE);
      expect(base.shadeKeyedBy('cat-1'), isA<Color>());
    });
  });

  group('measureWidth', () {
    test('returns positive width', () {
      const style = TextStyle(fontSize: 14);
      expect('Hello'.measureWidth(style), greaterThan(0));
      expect(['a', 'www'].maxPaintedWidth(style), greaterThan(0));
    });
  });

  group('mdyy', () {
    test('formats local calendar date as m/d/yy', () {
      expect(DateTime(2026, 8, 23).mdyy, '8/23/26');
      expect(DateTime(2009, 1, 5).mdyy, '1/5/09');
    });
  });

  group('relativeTimeAgo', () {
    test('uses compact units through years', () {
      final now = DateTime.now();
      expect(now.relativeTimeAgo(), 'just now');
      expect(
        now.subtract(const Duration(minutes: 5)).relativeTimeAgo(),
        '5m ago',
      );
      expect(
        now.subtract(const Duration(hours: 3)).relativeTimeAgo(),
        '3h ago',
      );
      expect(
        now.subtract(const Duration(days: 2)).relativeTimeAgo(),
        '2d ago',
      );
      expect(
        now.subtract(const Duration(days: 14)).relativeTimeAgo(),
        '2w ago',
      );
      expect(
        now.subtract(const Duration(days: 60)).relativeTimeAgo(),
        '2mo ago',
      );
      expect(
        now.subtract(const Duration(days: 400)).relativeTimeAgo(),
        '1y ago',
      );
    });

    test('includeClock keeps a dated clock after a week', () {
      final stamped = DateTime.now().subtract(const Duration(days: 10));
      expect(
        stamped.relativeTimeAgo(includeClock: true),
        isNot(contains('ago')),
      );
    });
  });

  group('relativeTimeShort', () {
    test('omits ago suffix', () {
      final now = DateTime.now();
      expect(now.relativeTimeShort(), 'now');
      expect(
        now.subtract(const Duration(minutes: 5)).relativeTimeShort(),
        '5m',
      );
      expect(
        now.subtract(const Duration(hours: 3)).relativeTimeShort(),
        '3h',
      );
      expect(
        now.subtract(const Duration(days: 2)).relativeTimeShort(),
        '2d',
      );
    });
  });
}
