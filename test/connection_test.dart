import 'package:tautulli/tautulli.dart';
import 'package:test/test.dart';

void main() {
  const base = TautulliConnection(
    protocol: 'https',
    domain: 'tautulli.example.com',
    path: '/tautulli',
    apiKey: 'secret_key',
    headers: {'Authorization': 'Basic zzz'},
    useDeviceToken: true,
  );

  group('TautulliConnection value semantics', () {
    test('two connections with the same fields are equal', () {
      const other = TautulliConnection(
        protocol: 'https',
        domain: 'tautulli.example.com',
        path: '/tautulli',
        apiKey: 'secret_key',
        headers: {'Authorization': 'Basic zzz'},
        useDeviceToken: true,
      );
      expect(base, equals(other));
      expect(base.hashCode, equals(other.hashCode));
    });

    test('changing any single field breaks equality', () {
      expect(base, isNot(equals(base.copyWith(domain: 'other.example.com'))));
      expect(base, isNot(equals(base.copyWith(apiKey: 'different'))));
      expect(base, isNot(equals(base.copyWith(useDeviceToken: false))));
      expect(
        base,
        isNot(equals(base.copyWith(headers: {'Authorization': 'Basic aaa'}))),
      );
    });

    test('header equality is order-independent', () {
      const a = TautulliConnection(
        protocol: 'http',
        domain: 'h',
        apiKey: 'k',
        headers: {'A': '1', 'B': '2'},
      );
      const b = TautulliConnection(
        protocol: 'http',
        domain: 'h',
        apiKey: 'k',
        headers: {'B': '2', 'A': '1'},
      );
      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });
  });

  group('TautulliConnection.copyWith', () {
    test('replaces only the given field, preserving the rest', () {
      final copy = base.copyWith(apiKey: 'new_key');
      expect(copy.apiKey, equals('new_key'));
      expect(copy.protocol, equals(base.protocol));
      expect(copy.domain, equals(base.domain));
      expect(copy.path, equals(base.path));
      expect(copy.headers, equals(base.headers));
      expect(copy.useDeviceToken, equals(base.useDeviceToken));
    });
  });

  group('TautulliConnection.toString', () {
    test('redacts the apiKey and header values', () {
      final s = base.toString();
      expect(s, isNot(contains('secret_key')));
      expect(s, isNot(contains('Basic zzz')));
      expect(s, contains('<redacted>'));
      expect(s, contains('1 entries'));
      expect(s, contains('tautulli.example.com'));
    });
  });
}
