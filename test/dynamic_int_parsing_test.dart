import 'package:ethan_utils/ethan_utils.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DynamicIntParsing.asInt', () {
    test('accepts int and num', () {
      expect(42.asInt(), 42);
      expect(3.9.asInt(), 3);
    });

    test('parses numeric strings', () {
      expect('17'.asInt(), 17);
    });

    test('throws on null', () {
      const Object? value = null;
      expect(() => value.asInt(), throwsArgumentError);
    });
  });

  group('DynamicIntParsing.asIntOrNull', () {
    test('returns null for null', () {
      const Object? value = null;
      expect(value.asIntOrNull(), isNull);
    });

    test('accepts int and num', () {
      expect(42.asIntOrNull(), 42);
      expect(3.9.asIntOrNull(), 3);
    });

    test('returns null for non-numeric strings', () {
      expect('nope'.asIntOrNull(), isNull);
    });
  });
}
