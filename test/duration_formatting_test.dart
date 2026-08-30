import 'package:ethan_utils/ethan_utils.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('formattedSeconds', () {
    test('whole seconds with unit', () {
      expect(Duration.zero.formattedSeconds, '0s');
      expect(const Duration(milliseconds: 999).formattedSeconds, '0s');
      expect(const Duration(seconds: 3).formattedSeconds, '3s');
      expect(const Duration(minutes: 2, seconds: 5).formattedSeconds, '125s');
    });
  });

  group('formattedElapsed', () {
    test('uses unpadded m:ss under one hour', () {
      expect(Duration.zero.formattedElapsed, '0:00');
      expect(const Duration(seconds: 5).formattedElapsed, '0:05');
      expect(const Duration(minutes: 1).formattedElapsed, '1:00');
      expect(const Duration(minutes: 3, seconds: 5).formattedElapsed, '3:05');
      expect(
        const Duration(minutes: 59, seconds: 59).formattedElapsed,
        '59:59',
      );
    });

    test('uses h:mm:ss from one hour', () {
      expect(const Duration(hours: 1).formattedElapsed, '1:00:00');
      expect(
        const Duration(hours: 2, minutes: 3, seconds: 4).formattedElapsed,
        '2:03:04',
      );
    });
  });

  group('formattedClock', () {
    test('zero-pads mm:ss under one hour', () {
      expect(Duration.zero.formattedClock, '00:00');
      expect(const Duration(seconds: 5).formattedClock, '00:05');
      expect(const Duration(minutes: 3, seconds: 5).formattedClock, '03:05');
    });

    test('zero-pads HH:mm:ss from one hour', () {
      expect(const Duration(hours: 1).formattedClock, '01:00:00');
      expect(
        const Duration(hours: 2, minutes: 3, seconds: 4).formattedClock,
        '02:03:04',
      );
    });
  });

  group('formattedMinutesSeconds', () {
    test('uses total minutes, never hours', () {
      expect(Duration.zero.formattedMinutesSeconds, '0:00');
      expect(const Duration(seconds: 5).formattedMinutesSeconds, '0:05');
      expect(
        const Duration(minutes: 3, seconds: 5).formattedMinutesSeconds,
        '3:05',
      );
      expect(
        const Duration(
          hours: 1,
          minutes: 15,
          seconds: 30,
        ).formattedMinutesSeconds,
        '75:30',
      );
    });
  });

  test('negative durations format as absolute', () {
    expect(const Duration(seconds: -5).formattedSeconds, '5s');
    expect(const Duration(seconds: -5).formattedElapsed, '0:05');
    expect(const Duration(seconds: -5).formattedClock, '00:05');
    expect(const Duration(seconds: -65).formattedMinutesSeconds, '1:05');
  });
}
