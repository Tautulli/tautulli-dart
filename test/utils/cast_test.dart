import 'package:tautulli/src/utils/cast.dart';
import 'package:tautulli/tautulli.dart' show TautulliBadResponseException;
import 'package:test/test.dart';

void main() {
  group('Cast.castToBool', () {
    test('numeric 0 is false, non-zero is true', () {
      expect(Cast.castToBool(0), isFalse);
      expect(Cast.castToBool(1), isTrue);
      expect(Cast.castToBool(2), isTrue);
    });

    test('falsy strings coerce to false (case-insensitive)', () {
      for (final v in ['', '0', 'false', 'FALSE', 'no', 'No', 'off', 'OFF']) {
        expect(Cast.castToBool(v), isFalse, reason: 'expected "$v" -> false');
      }
    });

    test('other strings coerce to true', () {
      for (final v in ['1', 'true', 'yes', 'on', 'anything']) {
        expect(Cast.castToBool(v), isTrue, reason: 'expected "$v" -> true');
      }
    });

    test('null and unhandled types return null', () {
      expect(Cast.castToBool(null), isNull);
      expect(Cast.castToBool([1, 2]), isNull);
    });
  });

  group('Cast.castToIntList', () {
    test('coerces mixed values and preserves position', () {
      expect(Cast.castToIntList([1, '2', 3.9, true]), [1, 2, 3, 1]);
    });

    test('substitutes 0 for values that fail to coerce, keeping alignment', () {
      expect(Cast.castToIntList([1, 'x', null, 4]), [1, 0, 0, 4]);
    });
  });

  group('Cast.dateTimeFromEpochSeconds', () {
    test('returns a UTC DateTime at the correct instant', () {
      final dt = Cast.dateTimeFromEpochSeconds(1751587200);
      expect(dt, isNotNull);
      expect(dt!.isUtc, isTrue);
      expect(
        dt.millisecondsSinceEpoch,
        DateTime.utc(2025, 7, 4).millisecondsSinceEpoch,
      );
    });

    test('accepts string epoch seconds', () {
      final dt = Cast.dateTimeFromEpochSeconds('1751587200');
      expect(dt, isNotNull);
      expect(dt!.isUtc, isTrue);
    });

    test('returns null when the value does not coerce to an int', () {
      expect(Cast.dateTimeFromEpochSeconds(null), isNull);
      expect(Cast.dateTimeFromEpochSeconds('not-a-number'), isNull);
    });
  });

  group('Cast.dataMap', () {
    test('returns the map unchanged when given an object', () {
      final m = {'a': 1};
      expect(Cast.dataMap(m, 'cmd'), same(m));
    });

    test('returns an empty map when data is null', () {
      expect(Cast.dataMap(null, 'cmd'), isEmpty);
    });

    test(
      'throws TautulliBadResponseException naming the command on wrong shape',
      () {
        expect(
          () => Cast.dataMap(<dynamic>[1, 2], 'get_history'),
          throwsA(
            isA<TautulliBadResponseException>().having(
              (e) => e.message,
              'message',
              contains('get_history'),
            ),
          ),
        );
      },
    );
  });

  group('Cast.dataList', () {
    test('returns the list unchanged when given a list', () {
      final l = [1, 2, 3];
      expect(Cast.dataList(l, 'cmd'), same(l));
    });

    test('returns an empty list when data is null', () {
      expect(Cast.dataList(null, 'cmd'), isEmpty);
    });

    test(
      'throws TautulliBadResponseException naming the command on wrong shape',
      () {
        expect(
          () => Cast.dataList(<String, dynamic>{'a': 1}, 'get_libraries'),
          throwsA(
            isA<TautulliBadResponseException>().having(
              (e) => e.message,
              'message',
              contains('get_libraries'),
            ),
          ),
        );
      },
    );
  });
}
