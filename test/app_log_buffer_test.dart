import 'package:ethan_utils/ethan_utils.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('record keeps insertion order and preserves timestamp', () {
    final fixedTimestamp = DateTime(2026, 4, 5, 10, 11, 12, 130);
    final appLogBufferUnderTest = AppLogBuffer(clock: () => fixedTimestamp);

    appLogBufferUnderTest.record(
      component: 'Test',
      level: AppLogLevel.info,
      message: 'first',
    );
    appLogBufferUnderTest.record(
      component: 'Test',
      level: AppLogLevel.warning,
      message: 'second',
    );

    expect(appLogBufferUnderTest.entries.length, 2);
    expect(appLogBufferUnderTest.entries.first.message, 'first');
    expect(appLogBufferUnderTest.entries.last.message, 'second');
    expect(appLogBufferUnderTest.entries.first.timestamp, fixedTimestamp);
    expect(appLogBufferUnderTest.entries.last.timestamp, fixedTimestamp);
  });

  test('record enforces max retention', () {
    final appLogBufferUnderTest = AppLogBuffer(maxEntries: 2);

    appLogBufferUnderTest.record(
      component: 'Test',
      level: AppLogLevel.info,
      message: 'one',
    );
    appLogBufferUnderTest.record(
      component: 'Test',
      level: AppLogLevel.info,
      message: 'two',
    );
    appLogBufferUnderTest.record(
      component: 'Test',
      level: AppLogLevel.info,
      message: 'three',
    );

    expect(appLogBufferUnderTest.entries.length, 2);
    expect(appLogBufferUnderTest.entries.first.message, 'two');
    expect(appLogBufferUnderTest.entries.last.message, 'three');
  });

  test('clear removes all entries', () {
    final appLogBufferUnderTest = AppLogBuffer();
    appLogBufferUnderTest.record(
      component: 'Test',
      level: AppLogLevel.error,
      message: 'boom',
    );

    appLogBufferUnderTest.clear();

    expect(appLogBufferUnderTest.entries, isEmpty);
  });

  test('debug print capture ignores structured ELogger lines', () {
    final appLogBufferUnderTest = AppLogBuffer();
    appLogBufferUnderTest.captureDebugPrintLine(
      '[10:11:12.13|Search] Query changed',
    );
    appLogBufferUnderTest.captureDebugPrintLine('RenderObject overflowed');

    expect(appLogBufferUnderTest.entries.length, 1);
    expect(
      appLogBufferUnderTest.entries.single.message,
      'RenderObject overflowed',
    );
  });
}
