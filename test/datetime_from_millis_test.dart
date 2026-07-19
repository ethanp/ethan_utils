import 'package:ethan_utils/ethan_utils.dart';
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
      const int? millis = 1000;
      expect(
        millis.dateTimeFromMillis,
        DateTime.fromMillisecondsSinceEpoch(1000),
      );
    });
  });
}
