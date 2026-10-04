import 'package:flutter_test/flutter_test.dart';
import 'package:streetlore/core/services/sun_times_service.dart';

void main() {
  final svc = SunTimesService.instance;

  test('Alexandria: summer days are long, winter days short', () {
    final june = svc.compute(date: DateTime(2026, 6, 21));
    final dec = svc.compute(date: DateTime(2026, 12, 21));
    expect(june.daylight.inMinutes, inInclusiveRange(13 * 60 + 40, 14 * 60 + 20));
    expect(dec.daylight.inMinutes, inInclusiveRange(10 * 60, 10 * 60 + 30));
  });

  test('sunrise < solar noon < sunset on the same day', () {
    final t = svc.compute(date: DateTime(2026, 10, 4));
    expect(t.sunrise.isBefore(t.solarNoon), isTrue);
    expect(t.solarNoon.isBefore(t.sunset), isTrue);
    expect(t.sunrise.day, 4);
    expect(t.sunset.day, 4);
  });
}
