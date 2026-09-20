import 'package:ethan_utils/ethan_utils.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('asCanonicalHttpUrl', () {
    test('strips a trailing slash on a path', () {
      expect(
        'https://example.com/watch/123/'.asCanonicalHttpUrl,
        'https://example.com/watch/123',
      );
    });

    test('treats origin slash and no slash as the same host URL', () {
      expect('https://example.com/'.asCanonicalHttpUrl, 'https://example.com');
      expect('https://example.com'.asCanonicalHttpUrl, 'https://example.com');
    });

    test('trims whitespace and lowercases host', () {
      expect(
        '  HTTPS://Example.COM/Foo/  '.asCanonicalHttpUrl,
        'https://example.com/Foo',
      );
    });

    test('drops the default https port', () {
      expect(
        'https://example.com:443/a/'.asCanonicalHttpUrl,
        'https://example.com/a',
      );
    });

    test('keeps a non-default port', () {
      expect(
        'http://localhost:8080/x/'.asCanonicalHttpUrl,
        'http://localhost:8080/x',
      );
    });

    test('keeps query and fragment', () {
      expect(
        'https://example.com/a/?q=1#t=30'.asCanonicalHttpUrl,
        'https://example.com/a?q=1#t=30',
      );
    });

    test('leaves non-http text trimmed only', () {
      expect(
        ' mailto:hi@example.com '.asCanonicalHttpUrl,
        'mailto:hi@example.com',
      );
      expect('not a url'.asCanonicalHttpUrl, 'not a url');
    });

    test('is idempotent', () {
      const urls = [
        'https://example.com/a/',
        'https://example.com/',
        'https://example.com:443/a/?q=1#t=30',
        '  HTTPS://Example.COM/Foo/  ',
      ];
      for (final url in urls) {
        final canonicalUrl = url.asCanonicalHttpUrl;
        expect(canonicalUrl.asCanonicalHttpUrl, canonicalUrl);
      }
    });
  });

  group('isSameHttpUrlAs', () {
    test('trailing-slash twins are the same item', () {
      expect(
        'https://example.com/a/'.isSameHttpUrlAs('https://example.com/a'),
        isTrue,
      );
      expect(
        'https://example.com/'.isSameHttpUrlAs('https://example.com'),
        isTrue,
      );
    });

    test('http and https are different items', () {
      expect(
        'http://example.com/a'.isSameHttpUrlAs('https://example.com/a'),
        isFalse,
      );
    });

    test('query strings distinguish items', () {
      expect(
        'https://example.com/a?view=1'.isSameHttpUrlAs(
          'https://example.com/a?view=2',
        ),
        isFalse,
      );
    });
  });

  group('equivalentHttpUrls', () {
    test('includes canonical and trailing-slash twin', () {
      expect('https://example.com/a'.equivalentHttpUrls, [
        'https://example.com/a',
        'https://example.com/a/',
      ]);
    });

    test('includes the trimmed original when it still differs', () {
      expect('  HTTPS://Example.COM/a/  '.equivalentHttpUrls, [
        'https://example.com/a',
        'https://example.com/a/',
        'HTTPS://Example.COM/a/',
      ]);
    });
  });
}
