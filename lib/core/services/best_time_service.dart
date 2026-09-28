import 'package:flutter/material.dart';
import '../../data/models/place_model.dart';

class BestTimeRecommendation {
  final int score;
  final String labelKey;
  final String hintKey;
  final IconData icon;
  final Color color;
  
  
  final String? customLabel;

  const BestTimeRecommendation({
    required this.score,
    required this.labelKey,
    required this.hintKey,
    required this.icon,
    required this.color,
    this.customLabel,
  });

  bool get isGoodNow => score >= 70;
  bool get isOkayNow => score >= 40 && score < 70;
  bool get isBadNow => score < 40;
}

class BestTimeService {
  BestTimeService._();
  static final BestTimeService instance = BestTimeService._();

  BestTimeRecommendation recommend(PlaceModel place, {DateTime? now}) {
    final t = now ?? DateTime.now();

    
    
    
    final adminLabel = place.bestTimeToVisit?.trim();
    if (adminLabel != null && adminLabel.isNotEmpty) {
      return BestTimeRecommendation(
        score: 100,
        labelKey: 'bt_label_go_now',
        hintKey: 'bt_reason_admin_set',
        icon: _iconForLabel(adminLabel),
        color: const Color(0xFF10B981),
        customLabel: adminLabel,
      );
    }

    final hour = t.hour;
    final minute = t.minute;
    final weekday = t.weekday;
    final isWeekend =
        weekday == DateTime.friday || weekday == DateTime.saturday;
    final category = place.category.toLowerCase();

    final slot = _slotFor(hour);
    
    final windows = place.bestTimeOverride != null
        ? _windowsFromOverride(place.bestTimeOverride!, category)
        : _windowsFor(category);

    int bestScore = 0;
    _Window best = windows.first;
    for (final w in windows) {
      final s = _scoreForSlot(
        slot,
        w,
        isWeekend: isWeekend,
        hour: hour,
        minute: minute,
      );
      if (s > bestScore) {
        bestScore = s;
        best = w;
      }
    }

    final nextWindow = _nextWindowText(windows, t);

    if (bestScore >= 75) {
      return BestTimeRecommendation(
        score: bestScore,
        labelKey: 'bt_label_go_now',
        hintKey: best.reasonKey,
        icon: best.icon,
        color: const Color(0xFF10B981),
      );
    } else if (bestScore >= 50) {
      return BestTimeRecommendation(
        score: bestScore,
        labelKey: 'bt_label_decent_now',
        hintKey: best.reasonKey,
        icon: best.icon,
        color: const Color(0xFFF59E0B),
      );
    } else {
      return BestTimeRecommendation(
        score: bestScore,
        labelKey: nextWindow.titleKey,
        hintKey: nextWindow.bodyKey,
        icon: best.icon,
        color: const Color(0xFFEF4444),
      );
    }
  }

  IconData _iconForLabel(String label) {
    final l = label.toLowerCase();
    if (l.contains('morning') && !l.contains('late') && !l.contains('early')) {
      return Icons.wb_sunny_rounded;
    }
    if (l.contains('early')) return Icons.wb_twilight_rounded;
    if (l.contains('midday') || l.contains('noon')) {
      return Icons.wb_sunny_outlined;
    }
    if (l.contains('afternoon')) return Icons.wb_cloudy_rounded;
    if (l.contains('sunset') || l.contains('evening') || l.contains('golden')) {
      return Icons.wb_twilight_rounded;
    }
    if (l.contains('night')) return Icons.nightlight_round;
    if (l.contains('late')) return Icons.bedtime_rounded;
    return Icons.access_time_rounded;
  }

  String _slotFor(int hour) {
    if (hour < 6) return 'late_night';
    if (hour < 9) return 'early_morning';
    if (hour < 12) return 'morning';
    if (hour < 15) return 'midday';
    if (hour < 18) return 'afternoon';
    if (hour < 21) return 'evening';
    return 'night';
  }

  List<_Window> _windowsFor(String category) {
    if (category.contains('nature') || category.contains('beach')) {
      return const [
        _Window(
          'early_morning',
          95,
          'bt_reason_quietest',
          Icons.wb_twilight_rounded,
        ),
        _Window('morning', 80, 'bt_reason_cool_photo', Icons.wb_sunny_rounded),
        _Window('midday', 30, 'bt_reason_hot_crowd', Icons.wb_sunny_outlined),
        _Window('afternoon', 55, 'bt_reason_warm_ok', Icons.wb_cloudy_rounded),
        _Window(
          'evening',
          90,
          'bt_reason_golden_hour',
          Icons.wb_twilight_rounded,
        ),
        _Window('night', 20, 'bt_reason_closed_unsafe', Icons.nightlight_round),
      ];
    }
    if (category.contains('historical')) {
      return const [
        _Window(
          'early_morning',
          90,
          'bt_reason_cool_empty',
          Icons.wb_twilight_rounded,
        ),
        _Window('morning', 88, 'bt_reason_best_photos', Icons.wb_sunny_rounded),
        _Window('midday', 55, 'bt_reason_hot_shaded', Icons.wb_sunny_outlined),
        _Window(
          'afternoon',
          70,
          'bt_reason_soft_light',
          Icons.wb_cloudy_rounded,
        ),
        _Window(
          'evening',
          60,
          'bt_reason_often_closing',
          Icons.wb_twilight_rounded,
        ),
        _Window('night', 5, 'bt_reason_closed', Icons.nightlight_round),
      ];
    }
    if (category.contains('culture') || category.contains('museum')) {
      return const [
        _Window(
          'early_morning',
          65,
          'bt_reason_quietest',
          Icons.wb_twilight_rounded,
        ),
        _Window('morning', 92, 'bt_reason_cool_photo', Icons.wb_sunny_rounded),
        _Window('midday', 70, 'bt_reason_hot_shaded', Icons.wb_sunny_outlined),
        _Window('afternoon', 80, 'bt_reason_warm_ok', Icons.wb_cloudy_rounded),
        _Window('evening', 88, 'bt_reason_golden_hour', Icons.nightlight_round),
        _Window('night', 10, 'bt_reason_closed', Icons.nightlight_round),
      ];
    }
    if (category.contains('food')) {
      return const [
        _Window(
          'early_morning',
          30,
          'bt_reason_too_early',
          Icons.wb_twilight_rounded,
        ),
        _Window('morning', 60, 'bt_reason_breakfast', Icons.wb_sunny_rounded),
        _Window('midday', 90, 'bt_reason_lunch', Icons.restaurant_rounded),
        _Window('afternoon', 50, 'bt_reason_warm_ok', Icons.coffee_rounded),
        _Window('evening', 95, 'bt_reason_dinner', Icons.local_dining_rounded),
        _Window('night', 70, 'bt_reason_often_closing', Icons.nightlight_round),
      ];
    }
    return const [
      _Window(
        'early_morning',
        75,
        'bt_reason_quietest',
        Icons.wb_twilight_rounded,
      ),
      _Window('morning', 85, 'bt_reason_best_photos', Icons.wb_sunny_rounded),
      _Window('midday', 55, 'bt_reason_hot_crowd', Icons.wb_sunny_outlined),
      _Window('afternoon', 65, 'bt_reason_warm_ok', Icons.wb_cloudy_rounded),
      _Window(
        'evening',
        80,
        'bt_reason_golden_hour',
        Icons.wb_twilight_rounded,
      ),
      _Window('night', 25, 'bt_reason_closed', Icons.nightlight_round),
    ];
  }

  int _scoreForSlot(
    String slot,
    _Window w, {
    required bool isWeekend,
    required int hour,
    required int minute,
  }) {
    var base = switch (slot) {
      'early_morning' => _match(w.slot, 'early_morning'),
      'morning' => _match(w.slot, 'morning'),
      'midday' => _match(w.slot, 'midday'),
      'afternoon' => _match(w.slot, 'afternoon'),
      'evening' => _match(w.slot, 'evening'),
      'night' => _match(w.slot, 'night'),
      'late_night' => 0,
      _ => 50,
    };
    if (base <= 0) return base;
    if (isWeekend && (slot == 'morning' || slot == 'afternoon')) {
      base = (base * 0.85).round();
    }
    if (!isWeekend && slot == 'morning') {
      base = (base * 1.05).round().clamp(0, 100);
    }
    return base;
  }

  int _match(String a, String b) {
    if (a == b) return 95;
    final hour = const {
      'early_morning': 0,
      'morning': 1,
      'midday': 2,
      'afternoon': 3,
      'evening': 4,
      'night': 5,
    };
    final da = (hour[a]! - hour[b]!).abs();
    if (da == 0) return 95;
    if (da == 1) return 70;
    if (da == 2) return 45;
    if (da == 3) return 25;
    return 10;
  }

  _NextWindow _nextWindowText(List<_Window> windows, DateTime now) {
    final hour = now.hour;
    int? nextBestHour;
    int bestScore = 0;
    String labelKey = 'bt_reason_cool_photo';
    for (final w in windows) {
      final slotStart = _slotStart(w.slot);
      if (slotStart > hour) {
        final s = w.score;
        if (s > bestScore) {
          bestScore = s;
          nextBestHour = slotStart;
          labelKey = w.reasonKey;
        }
      }
    }
    if (nextBestHour == null) {
      return _NextWindow(titleKey: 'bt_label_wait', bodyKey: labelKey);
    }
    return _NextWindow(titleKey: 'bt_label_wait', bodyKey: labelKey);
  }

  int _slotStart(String slot) {
    switch (slot) {
      case 'early_morning':
        return 6;
      case 'morning':
        return 9;
      case 'midday':
        return 12;
      case 'afternoon':
        return 15;
      case 'evening':
        return 18;
      case 'night':
        return 21;
      default:
        return 9;
    }
  }

  
  
  
  List<_Window> _windowsFromOverride(
    Map<String, int> override,
    String category,
  ) {
    final fallback = _windowsFor(category);
    return fallback.map((w) {
      final v = override[w.slot];
      return v == null
          ? w
          : _Window(w.slot, v.clamp(0, 100), w.reasonKey, w.icon);
    }).toList(growable: false);
  }
}

class _Window {
  final String slot;
  final int score;
  final String reasonKey;
  final IconData icon;
  const _Window(this.slot, this.score, this.reasonKey, this.icon);
}

class _NextWindow {
  final String titleKey;
  final String bodyKey;
  const _NextWindow({required this.titleKey, required this.bodyKey});
}
