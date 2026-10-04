/// Parses the `open_hours` strings used in the places table, e.g.
/// "9:00 AM - 6:00 PM", "8:00 AM - 10:00 PM", "Open 24 hours",
/// "09:00-18:00". Unparseable / empty values fall back to 9 AM - 6 PM,
/// which is what the app assumed for every place before.
class OpeningHours {
  OpeningHours._();

  static final RegExp _range = RegExp(
    r'(\d{1,2})(?::(\d{2}))?\s*(am|pm)?\s*[-–—]\s*(\d{1,2})(?::(\d{2}))?\s*(am|pm)?',
    caseSensitive: false,
  );

  static bool isOpenAt(String openHours, DateTime at) {
    final text = openHours.trim().toLowerCase();
    if (text.contains('24 hours') || text.contains('24h')) return true;

    var open = 9 * 60;
    var close = 18 * 60;
    final m = _range.firstMatch(text);
    if (m != null) {
      final o = _toMinutes(m.group(1)!, m.group(2), m.group(3));
      final c = _toMinutes(m.group(4)!, m.group(5), m.group(6));
      if (o != null && c != null) {
        open = o;
        close = c;
      }
    }
    final now = at.hour * 60 + at.minute;
    if (close > open) return now >= open && now < close;
    // Overnight range, e.g. "6:00 PM - 2:00 AM".
    return now >= open || now < close;
  }

  static int? _toMinutes(String h, String? m, String? ampm) {
    var hour = int.tryParse(h);
    final minute = m == null ? 0 : int.tryParse(m);
    if (hour == null || minute == null || minute > 59) return null;
    final suffix = ampm?.toLowerCase();
    if (suffix != null) {
      if (hour < 1 || hour > 12) return null;
      if (suffix == 'am' && hour == 12) hour = 0;
      if (suffix == 'pm' && hour != 12) hour += 12;
    } else if (hour > 24) {
      return null;
    }
    return (hour % 24) * 60 + minute;
  }
}
