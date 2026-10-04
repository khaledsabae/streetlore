import 'package:flutter_test/flutter_test.dart';
import 'package:streetlore/core/geo/geo_utils.dart';

void main() {
  group('haversineKm', () {
    test('same point is zero', () {
      expect(haversineKm(31.2, 29.9, 31.2, 29.9), 0);
    });

    test('London to Paris is ~343.5 km', () {
      expect(
        haversineKm(51.5074, -0.1278, 48.8566, 2.3522),
        closeTo(343.5, 1.0),
      );
    });

    test('Qaitbay Citadel to Bibliotheca Alexandrina is ~2.3 km', () {
      expect(
        haversineKm(31.2140, 29.8856, 31.2089, 29.9092),
        closeTo(2.3, 0.2),
      );
    });

    test('long distances are correct (Alexandria to New York ~8840 km)', () {
      // The pre-fix formula, (sin(d)/2)*sin(d/2), matched at city scale
      // but returned ~6740 km here.
      expect(
        haversineKm(31.2, 29.9, 40.71, -74.0),
        closeTo(8840, 10),
      );
    });

    test('is symmetric', () {
      final a = haversineKm(31.20, 29.90, 31.25, 29.95);
      final b = haversineKm(31.25, 29.95, 31.20, 29.90);
      expect(a, closeTo(b, 1e-9));
    });
  });
}
