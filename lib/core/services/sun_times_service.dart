import 'dart:math' as math;



class SunTimes {
  final DateTime sunrise;
  final DateTime sunset;
  final DateTime solarNoon;
  final Duration daylight;

  const SunTimes({
    required this.sunrise,
    required this.sunset,
    required this.solarNoon,
    required this.daylight,
  });

  bool get isDaylightNow {
    final now = DateTime.now();
    return now.isAfter(sunrise) && now.isBefore(sunset);
  }

  Duration get timeUntilSunset {
    final now = DateTime.now();
    if (now.isAfter(sunset)) return Duration.zero;
    return sunset.difference(now);
  }

  Duration get timeUntilSunrise {
    final now = DateTime.now();
    if (now.isBefore(sunrise)) return sunrise.difference(now);
    return Duration.zero;
  }
}











class SunTimesService {
  SunTimesService._();
  static final SunTimesService instance = SunTimesService._();

  
  static const double _lat = 31.2001;
  static const double _lng = 29.9187;

  
  static const double _altitudeDeg = -0.833;

  
  SunTimes compute({
    DateTime? date,
    double latitude = _lat,
    double longitude = _lng,
  }) {
    final d = date ?? DateTime.now();
    
    final startOfYear = DateTime(d.year, 1, 1);
    final dayOfYear =
        DateTime(d.year, d.month, d.day).difference(startOfYear).inDays + 1;

    
    final declDeg =
        23.45 * math.sin(2 * math.pi * (284 + dayOfYear) / 365.0);
    final declRad = declDeg * math.pi / 180.0;

    final latRad = latitude * math.pi / 180.0;
    final altRad = _altitudeDeg * math.pi / 180.0;

    
    final cosNumerator = math.sin(altRad) -
        math.sin(latRad) * math.sin(declRad);
    final cosDenominator = math.cos(latRad) * math.cos(declRad);
    if (cosDenominator.abs() < 1e-9) {
      
      return _polarFallback(d, longitude);
    }
    final cosH = cosNumerator / cosDenominator;

    final solarNoon = _solarNoon(d, longitude);

    if (cosH > 1) {
      
      return SunTimes(
        sunrise: solarNoon,
        sunset: solarNoon,
        solarNoon: solarNoon,
        daylight: Duration.zero,
      );
    }
    if (cosH < -1) {
      
      return SunTimes(
        sunrise: DateTime(d.year, d.month, d.day, 0, 0),
        sunset: DateTime(d.year, d.month, d.day, 23, 59),
        solarNoon: solarNoon,
        daylight: const Duration(hours: 24),
      );
    }

    
    
    final hRad = math.acos(cosH);
    final hDeg = hRad * 180.0 / math.pi;
    var halfMinutes = (hDeg * 4).round(); 

    
    
    
    if (halfMinutes < 0) halfMinutes = 0;
    if (halfMinutes > 720) halfMinutes = 720; 

    final sunrise = solarNoon.subtract(Duration(minutes: halfMinutes));
    final sunset = solarNoon.add(Duration(minutes: halfMinutes));

    var daylight = sunset.difference(sunrise);
    if (daylight.isNegative) daylight = Duration.zero;
    if (daylight > const Duration(hours: 24)) {
      daylight = const Duration(hours: 24);
    }

    return SunTimes(
      sunrise: sunrise,
      sunset: sunset,
      solarNoon: solarNoon,
      daylight: daylight,
    );
  }

  SunTimes _polarFallback(DateTime d, double longitude) {
    final noon = _solarNoon(d, longitude);
    return SunTimes(
      sunrise: noon,
      sunset: noon,
      solarNoon: noon,
      daylight: Duration.zero,
    );
  }

  
  DateTime _solarNoon(DateTime date, double longitude) {
    final startOfYear = DateTime(date.year, 1, 1);
    final dayOfYear =
        DateTime(date.year, date.month, date.day)
            .difference(startOfYear)
            .inDays +
        1;
    final b = 2 * math.pi * (dayOfYear - 81) / 365.0;
    final equationOfTime =
        9.87 * math.sin(2 * b) - 7.53 * math.cos(b) - 1.5 * math.sin(b);
    final timeCorrectionMinutes = 4 * longitude + equationOfTime;
    
    final solarNoonUtc = 12.0 - timeCorrectionMinutes / 60.0;
    
    
    final localOffset = date.timeZoneOffset.inMinutes / 60.0;
    var solarNoonLocal = solarNoonUtc + localOffset;
    
    solarNoonLocal = solarNoonLocal % 24.0;
    if (solarNoonLocal < 0) solarNoonLocal += 24.0;
    final hour = solarNoonLocal.floor();
    final minute = ((solarNoonLocal - hour) * 60).round();
    return DateTime(date.year, date.month, date.day, hour, minute);
  }

  
  
  String formatTime(DateTime dt) {
    final h = (dt.hour % 24).toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  
  
  String formatDuration(Duration d) {
    final clamped = d.isNegative ? Duration.zero : d;
    final capped = clamped > const Duration(hours: 24)
        ? const Duration(hours: 24)
        : clamped;
    if (capped.inMinutes == 0) return '0m';
    final h = capped.inHours;
    final m = capped.inMinutes.remainder(60);
    if (h == 0) return '${m}m';
    if (m == 0) return '${h}h';
    return '${h}h ${m}m';
  }
}
