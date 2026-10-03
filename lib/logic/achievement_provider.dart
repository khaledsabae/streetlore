import 'dart:async';

import 'package:flutter/material.dart' hide Badge;
import 'package:shared_preferences/shared_preferences.dart';
import '../data/achievement_catalog.dart';
import '../data/models/gamification_stats.dart';
import 'auth_provider.dart';
import 'gamification_provider.dart';
import 'place_provider.dart';
import 'streak_provider.dart';

class AchievementProgress {
  final String achievementId;
  final int current;
  final int target;
  final bool unlocked;
  final DateTime? unlockedAt;

  const AchievementProgress({
    required this.achievementId,
    required this.current,
    required this.target,
    required this.unlocked,
    this.unlockedAt,
  });

  double get ratio => target == 0 ? 0 : (current / target).clamp(0.0, 1.0);

  Map<String, dynamic> toJson() => {
    'achievement_id': achievementId,
    'current': current,
    'unlocked': unlocked,
    'unlocked_at': unlockedAt?.toIso8601String(),
  };

  factory AchievementProgress.fromJson(Map<String, dynamic> json) =>
      AchievementProgress(
        achievementId: json['achievement_id'] as String,
        current: (json['current'] as num?)?.toInt() ?? 0,
        target: 0,
        unlocked: json['unlocked'] as bool? ?? false,
        unlockedAt: json['unlocked_at'] == null
            ? null
            : DateTime.parse(json['unlocked_at'] as String),
      );
}

class AchievementProvider extends ChangeNotifier {
  final AuthProvider auth;
  final GamificationProvider gam;
  final PlaceProvider places;
  final StreakProvider streak;

  String _userKey = 'guest';
  Map<String, AchievementProgress> _progress = {};
  static const _kPrefix = 'achievements_v2';

  AchievementProvider({
    required this.auth,
    required this.gam,
    required this.places,
    required this.streak,
  }) {
    _userKey = _effectiveKey();
    _load();
    _recalculateAll();
  }

  String _effectiveKey() {
    final id = auth.userId;
    return id.isEmpty ? 'guest' : id;
  }

  void syncWithAuth(AuthProvider auth) {
    final newKey = auth.userId.isEmpty ? 'guest' : auth.userId;
    if (newKey == _userKey) return;
    _userKey = newKey;
    _load();
    _recalculateAll();
  }

  String get _kKey => '${_kPrefix}_$_userKey';

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_kKey);
    if (raw == null) {
      _progress = {};
      return;
    }
    try {
      final list = (raw.split('|'));
      final Map<String, AchievementProgress> loaded = {};
      for (final entry in list) {
        if (entry.isEmpty) continue;
        final parts = entry.split('::');
        if (parts.length < 2) continue;
        final id = parts[0];
        final cur = int.tryParse(parts[1]) ?? 0;
        final unlocked = parts.length > 2 && parts[2] == '1';
        final unlockedAt = parts.length > 3 && parts[3].isNotEmpty
            ? DateTime.tryParse(parts[3])
            : null;
        loaded[id] = AchievementProgress(
          achievementId: id,
          current: cur,
          target: 0,
          unlocked: unlocked,
          unlockedAt: unlockedAt,
        );
      }
      _progress = loaded;
    } catch (e) {
      _progress = {};
    }
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    final entries = _progress.entries
        .map((e) {
          final p = e.value;
          return '${p.achievementId}::${p.current}::${p.unlocked ? 1 : 0}::${p.unlockedAt?.toIso8601String() ?? ''}';
        })
        .join('|');
    await prefs.setString(_kKey, entries);
  }

  AchievementProgress progressFor(String id) {
    return _progress[id] ??
        AchievementProgress(
          achievementId: id,
          current: 0,
          target: 0,
          unlocked: false,
        );
  }

  int get totalUnlocked => _progress.values.where((p) => p.unlocked).length;
  int get totalAvailable => AchievementCatalog.all.length;
  double get completionRatio =>
      totalAvailable == 0 ? 0 : totalUnlocked / totalAvailable;

  int get totalPointsEarned {
    int sum = 0;
    for (final p in _progress.values) {
      if (!p.unlocked) continue;
      final def = AchievementCatalog.byId(p.achievementId);
      if (def != null) sum += def.points;
    }
    return sum;
  }

  List<AchievementDefinition> recentUnlocked({int limit = 3}) {
    final entries =
        _progress.entries
            .where((e) => e.value.unlocked && e.value.unlockedAt != null)
            .toList()
          ..sort((a, b) => b.value.unlockedAt!.compareTo(a.value.unlockedAt!));
    return entries
        .take(limit)
        .map((e) => AchievementCatalog.byId(e.key))
        .whereType<AchievementDefinition>()
        .toList();
  }

  void _recalculateAll() {
    final stats = gam.stats;
    final all = places.places;
    final streakDays = streak.currentStreak;

    final byCategory = <String, int>{};
    for (final p in all) {
      byCategory[p.category] = (byCategory[p.category] ?? 0) + 1;
    }

    final visitedCategories = <String>{};
    final visitedCount = stats.placesVisited;

    for (final p in all.take(visitedCount)) {
      visitedCategories.add(p.category);
    }

    final hiddenGemsVisited = all
        .where((p) => p.isHiddenGem && visitedCount > all.indexOf(p))
        .length;

    for (final def in AchievementCatalog.all) {
      int cur = 0;
      switch (def.id) {
        case 'first_steps':
        case 'explorer_5':
        case 'explorer_10':
        case 'explorer_25':
        case 'lorekeeper':
          cur = visitedCount;
          break;
        case 'culture_buff':
        case 'history_nerd':
          cur = _estimateVisitedIn(all, [
            'Culture',
            'Historical',
          ], visitedCount);
          break;
        case 'foodie':
        case 'gourmet':
          cur = _estimateVisitedIn(all, ['Food'], visitedCount);
          break;
        case 'shopaholic':
          cur = _estimateVisitedIn(all, ['Shopping'], visitedCount);
          break;
        case 'spiritual_seeker':
          cur = _estimateVisitedIn(all, ['Mosques'], visitedCount);
          break;
        case 'pilgrim':
          cur = _estimateVisitedIn(all, ['Churches'], visitedCount);
          break;
        case 'streak_3':
        case 'streak_7':
        case 'streak_30':
        case 'streak_100':
          cur = streakDays;
          break;
        case 'hidden_gem_hunter':
          cur = hiddenGemsVisited;
          break;
        case 'reviewer':
        case 'critic':
          cur = stats.reviewsPosted;
          break;
        case 'photographer':
        case 'influencer':
          cur = stats.photosUploaded;
          break;
        case 'early_bird':
        case 'night_owl':
        case 'completionist':
          cur = visitedCount;
          break;
      }
      _updateProgress(def, cur);
    }
  }

  int _estimateVisitedIn(
    List<dynamic> all,
    List<String> cats,
    int visitedCount,
  ) {
    if (visitedCount <= 0) return 0;
    final filtered = all.where((p) => cats.contains(p.category)).toList();
    return filtered.length < visitedCount ? filtered.length : visitedCount;
  }

  void _updateProgress(AchievementDefinition def, int current) {
    final wasUnlocked = _progress[def.id]?.unlocked ?? false;
    final wasCurrent = _progress[def.id]?.current ?? 0;
    final shouldUnlock = current >= def.target;
    final wasAt = _progress[def.id]?.unlockedAt;
    _progress[def.id] = AchievementProgress(
      achievementId: def.id,
      current: current,
      target: def.target,
      unlocked: shouldUnlock,
      unlockedAt: shouldUnlock ? (wasAt ?? DateTime.now()) : null,
    );
    if (shouldUnlock && !wasUnlocked) {
      _grantBadge(def);
    } else if (!shouldUnlock && wasUnlocked) {
      // v1.0.63: revoke — the underlying stat dropped back below the
      // required target (e.g. user un-visited a place, placesVisited
      // went 1 → 0, first_steps' target of 1 is no longer met).
      _revokeBadge(def);
    }
    if (current != wasCurrent) {
      _save();
      notifyListeners();
    }
  }

  void _grantBadge(AchievementDefinition def) {
    gam.addBadgeIfMissing(
      Badge(
        id: def.id,
        name: def.nameKey,
        description: def.descKey,
        iconName: _iconName(def.icon),
        tier: _tierName(def.tier),
        earnedAt: DateTime.now(),
        pointsAwarded: def.points,
      ),
    );
  }

  void _revokeBadge(AchievementDefinition def) {
    gam.removeBadgeIfPresent(def.id);
  }

  String _iconName(IconData icon) {
    final code = icon.codePoint;
    return 'icon_$code';
  }

  String _tierName(AchievementTier tier) {
    return AchievementCatalog.tierName(tier).toLowerCase();
  }

  void refreshFromStats() {
    _recalculateAll();
    _save();
    notifyListeners();
  }
}
