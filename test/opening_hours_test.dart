import 'package:flutter_test/flutter_test.dart';
import 'package:streetlore/core/utils/opening_hours.dart';

DateTime at(int h, [int m = 0]) => DateTime(2026, 10, 4, h, m);

void main() {
  group('OpeningHours.isOpenAt', () {
    test('12-hour range from the places table', () {
      const hours = '8:00 AM - 10:00 PM';
      expect(OpeningHours.isOpenAt(hours, at(7, 59)), isFalse);
      expect(OpeningHours.isOpenAt(hours, at(8)), isTrue);
      expect(OpeningHours.isOpenAt(hours, at(21, 59)), isTrue);
      expect(OpeningHours.isOpenAt(hours, at(22)), isFalse);
    });

    test('uses the real closing time, not a fixed 6 PM', () {
      expect(OpeningHours.isOpenAt('9:00 AM - 9:00 PM', at(20)), isTrue);
      expect(OpeningHours.isOpenAt('9:00 AM - 4:00 PM', at(17)), isFalse);
    });

    test('24 hours variants', () {
      expect(OpeningHours.isOpenAt('Open 24 hours', at(3)), isTrue);
      expect(OpeningHours.isOpenAt('24 hours', at(3)), isTrue);
    });

    test('24-hour clock without AM/PM', () {
      expect(OpeningHours.isOpenAt('09:00-18:00', at(12)), isTrue);
      expect(OpeningHours.isOpenAt('09:00-18:00', at(18, 30)), isFalse);
    });

    test('overnight range', () {
      const hours = '6:00 PM - 2:00 AM';
      expect(OpeningHours.isOpenAt(hours, at(23)), isTrue);
      expect(OpeningHours.isOpenAt(hours, at(1)), isTrue);
      expect(OpeningHours.isOpenAt(hours, at(12)), isFalse);
    });

    test('12 AM / 12 PM edges', () {
      expect(OpeningHours.isOpenAt('12:00 PM - 11:00 PM', at(12)), isTrue);
      expect(OpeningHours.isOpenAt('12:00 PM - 11:00 PM', at(11)), isFalse);
    });

    test('empty or unparseable falls back to 9 AM - 6 PM', () {
      expect(OpeningHours.isOpenAt('', at(10)), isTrue);
      expect(OpeningHours.isOpenAt('', at(19)), isFalse);
      expect(OpeningHours.isOpenAt('ask at the gate', at(8)), isFalse);
    });
  });
}
