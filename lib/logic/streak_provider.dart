import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// StreakProvider tracks the user's DAILY activity, not the total
/// number of visits.
///
/// Correct v1.0.56 semantics:
///   - `_currentStreak` counts CONSECUTIVE calendar days with at
///     least one check-in. Visiting twice on the same day is a
///     no-op.
///   - `_totalVisitDays` counts the number of UNIQUE calendar days
///     on which the user checked in at least once.
///   - `_longestStreak` is the longest consecutive-day run ever
///     achieved.
///   - `_visitedDates` is the set of unique calendar dates (yyyy-mm-dd)
///     the user has ever checked in.
class StreakProvider extends ChangeNotifier {
  static const _kPrefix = 'streak_v3_';

  int _currentStreak = 0;
  int _longestStreak = 0;
  DateTime? _lastVisitDate;
  int _totalVisitDays = 0;
  Set<String> _visitedDates = <String>{};
  String _userId = '';

  int get currentStreak => _currentStreak;
  int get longestStreak => _longestStreak;
  DateTime? get lastVisitDate => _lastVisitDate;
  int get totalVisitDays => _totalVisitDays;
  Set<String> get visitedDates => Set<String>.unmodifiable(_visitedDates);

  bool get hasStreakToday {
    if (_lastVisitDate == null) return false;
    final today = _dateOnly(DateTime.now());
    return _dateOnly(_lastVisitDate!) == today;
  }

  StreakProvider() {
    _load();
  }

  Future<void> setUserId(String userId) async {
    if (userId.isEmpty || userId == _userId) return;
    await _save();
    _userId = userId;
    _currentStreak = 0;
    _longestStreak = 0;
    _totalVisitDays = 0;
    _visitedDates = <String>{};
    _lastVisitDate = null;
    await _load();
    notifyListeners();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null) return;
    try {
      final map = jsonDecode(raw) as Map<String, dynamic>;
      _currentStreak = (map['currentStreak'] as int?) ?? 0;
      _longestStreak = (map['longestStreak'] as int?) ?? 0;
      _totalVisitDays = (map['totalVisitDays'] as int?) ?? 0;
      final last = map['lastVisitDate'] as String?;
      _lastVisitDate = last == null ? null : DateTime.parse(last);
      final visitedRaw = map['visitedDates'];
      if (visitedRaw is List) {
        _visitedDates = visitedRaw
            .whereType<String>()
            .where((s) => s.isNotEmpty)
            .toSet();
        if (_totalVisitDays == 0 && _visitedDates.isNotEmpty) {
          _totalVisitDays = _visitedDates.length;
        }
      }
    } catch (e) {
      debugPrint('StreakProvider load error: $e');
    }
  }

  Future<void> _save() async {
    if (_userId.isEmpty) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _key,
      jsonEncode({
        'currentStreak': _currentStreak,
        'longestStreak': _longestStreak,
        'totalVisitDays': _totalVisitDays,
        'lastVisitDate': _lastVisitDate?.toIso8601String(),
        'visitedDates': _visitedDates.toList(),
      }),
    );
  }

  /// Records a visit at [when] (defaults to now).
  ///
  /// Rules (v1.0.56):
  ///   - Multiple check-ins on the SAME calendar day are a no-op
  ///     for both the streak and the total-days counter.
  ///   - The first check-in on a NEW calendar day:
  ///       * increments `_totalVisitDays` by 1;
  ///       * if the new day is exactly yesterday relative to
  ///         `_lastVisitDate`, increments `_currentStreak`;
  ///       * otherwise resets `_currentStreak` to 1.
  ///   - `_longestStreak` is updated only when current exceeds it.
  /// Returns the current streak after the call.
  Future<int> registerVisit({DateTime? when}) async {
    if (_userId.isEmpty) return _currentStreak;
    final t = when ?? DateTime.now();
    final day = _dateOnly(t);
    final key = _dateKey(day);

    if (_visitedDates.contains(key)) {
      // Same calendar day — idempotent.
      _lastVisitDate = day;
      await _save();
      notifyListeners();
      return _currentStreak;
    }

    _visitedDates.add(key);
    _totalVisitDays = _visitedDates.length;

    if (_lastVisitDate == null) {
      _currentStreak = 1;
    } else {
      final lastDay = _dateOnly(_lastVisitDate!);
      final diff = day.difference(lastDay).inDays;
      if (diff == 1) {
        _currentStreak += 1;
      } else if (diff <= 0) {
        // Should not happen (we already checked visitedDates.contains)
        // but treat defensively as no-op for streak length.
        _currentStreak = (_currentStreak == 0) ? 1 : _currentStreak;
      } else {
        _currentStreak = 1;
      }
    }

    if (_currentStreak > _longestStreak) {
      _longestStreak = _currentStreak;
    }
    _lastVisitDate = day;
    await _save();
    notifyListeners();
    return _currentStreak;
  }

  /// Recompute the streak and totalVisitDays from an arbitrary set
  /// of visit timestamps (used when the app knows about visits that
  /// happened while offline or via a different code path).
  Future<void> recomputeFromTimestamps(Iterable<DateTime> visits) async {
    if (_userId.isEmpty) return;
    final days = <String>{};
    DateTime? latest;
    for (final v in visits) {
      final d = _dateOnly(v);
      days.add(_dateKey(d));
      if (latest == null || d.isAfter(latest)) latest = d;
    }
    _visitedDates = days;
    _totalVisitDays = days.length;
    _lastVisitDate = latest;
    _currentStreak = _computeStreakFromDays(days, latest);
    if (_currentStreak > _longestStreak) _longestStreak = _currentStreak;
    await _save();
    notifyListeners();
  }

  int _computeStreakFromDays(Set<String> days, DateTime? anchor) {
    if (days.isEmpty || anchor == null) return 0;
    var count = 0;
    var cursor = _dateOnly(anchor);
    while (days.contains(_dateKey(cursor))) {
      count += 1;
      cursor = cursor.subtract(const Duration(days: 1));
    }
    return count;
  }

  void reset() {
    _currentStreak = 0;
    _longestStreak = 0;
    _totalVisitDays = 0;
    _lastVisitDate = null;
    _visitedDates = <String>{};
    _save();
    notifyListeners();
  }

  DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);
  String _dateKey(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-'
      '${d.month.toString().padLeft(2, '0')}-'
      '${d.day.toString().padLeft(2, '0')}';

  String get _key => '$_kPrefix$_userId';
}