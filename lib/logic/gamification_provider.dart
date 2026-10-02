import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/models/gamification_stats.dart';
import '../data/achievement_catalog.dart';
import '../core/services/supabase_service.dart';
import 'achievement_provider.dart';
import 'auth_provider.dart';
import 'streak_provider.dart';

class GamificationProvider extends ChangeNotifier {
  GamificationStats _stats = GamificationStats(
    userId: 'me',
    userName: 'You',
    avatarColorHex: '0xFF3B82F6',
  );
  GamificationStats get stats => _stats;

  StreakProvider? _streak;
  AchievementProvider? _achievements;

  /// Wire the dependent providers so applyAction('check_in', ...) can
  /// update the streak and re-evaluate achievements after every
  /// check-in. Wired once in main.dart at startup. Safe to leave
  /// null — the providers still update their own state, only
  /// cross-evaluation is skipped.
  void bindHelpers({
    required StreakProvider streak,
    required AchievementProvider achievements,
  }) {
    _streak = streak;
    _achievements = achievements;
  }

  String? _lastCheckinError;
  String? get lastCheckinError => _lastCheckinError;

  void clearCheckinError() {
    if (_lastCheckinError == null) return;
    _lastCheckinError = null;
    notifyListeners();
  }

  static const _kKey = 'gamification_stats_v1';

  GamificationProvider() {
    _load();
  }

  void syncWithAuth(AuthProvider auth) {
    if (auth.userId.isEmpty) return;
    if (_stats.userId == auth.userId && _stats.userName == auth.userName) {
      return;
    }
    setUserIdentity(
      userId: auth.userId,
      userName: auth.userName.isEmpty ? 'Explorer' : auth.userName,
    );
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_kKey);
    if (raw == null) return;
    try {
      final json = jsonDecode(raw) as Map<String, dynamic>;
      _stats = GamificationStats.fromJson(json);
    } catch (e) {
      debugPrint('GamificationProvider: failed to load: $e');
    }
    notifyListeners();
  }

  Future<void> bootstrapForUser(String userId) async {
    if (userId.isEmpty) return;
    final remote = await SupabaseService.instance.pullStats(userId);
    if (remote == null) {
      debugPrint(
        'GamificationProvider: no remote stats for $userId, keeping local',
      );
      return;
    }
    final local = _stats;

    final mergedPoints = remote.totalPoints > local.totalPoints
        ? remote.totalPoints
        : local.totalPoints;
    final mergedVisited = remote.placesVisited > local.placesVisited
        ? remote.placesVisited
        : local.placesVisited;
    final mergedReviews = remote.reviewsPosted > local.reviewsPosted
        ? remote.reviewsPosted
        : local.reviewsPosted;
    final mergedPhotos = remote.photosUploaded > local.photosUploaded
        ? remote.photosUploaded
        : local.photosUploaded;
    final mergedLevel = GamificationStats.levelForPoints(mergedPoints);
    final badgeIds = local.badges.map((b) => b.id).toSet();
    final mergedBadges = <Badge>[
      ...local.badges,
      ...remote.badges.where((b) => !badgeIds.contains(b.id)),
    ];
    _stats = local.copyWith(
      totalPoints: mergedPoints,
      placesVisited: mergedVisited,
      reviewsPosted: mergedReviews,
      photosUploaded: mergedPhotos,
      level: mergedLevel,
      badges: mergedBadges,
    );
    await _save();
    notifyListeners();
    debugPrint(
      'GamificationProvider: merged stats for $userId '
      '(placesVisited=$mergedVisited, points=$mergedPoints, level=$mergedLevel)',
    );
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kKey, jsonEncode(_stats.toJson()));

    SupabaseService.instance.pushStats(_stats);
  }

  /// The single orchestrator for every user action that earns
  /// gamification points (check_in, review, photo, chat_message).
  ///
  /// In v1.0.56 this method:
  ///   1. updates gamification stats (points, level, count);
  ///   2. delegates streak math to the bound StreakProvider;
  ///   3. delegates catalog-based achievement re-evaluation to the
  ///      bound AchievementProvider (THIS is the missing piece that
  ///      used to make badges stop unlocking after a check-in);
  ///   4. writes the check-in row to the server;
  ///   5. saves locally and persists to the server.
  ///
  /// Returns the badge the user just earned (if any), preferring the
  /// highest-tier catalog badge unlocked by this action.
  Future<Badge?> applyAction(String action, {String? placeId}) async {
    if (action == 'check_in') {
      _lastCheckinError = null;
    }
    final pts = GamificationStats.pointsFor(action);
    if (pts == 0) return null;

    // For check_ins, let the streak provider update its own state
    // BEFORE we re-evaluate achievements (achievements depend on
    // streak.currentStreak for the streak_* milestones).
    if (action == 'check_in') {
      await _streak?.registerVisit();
    }

    // Run the catalog-based achievement re-eval so that reaching a
    // milestone (placesVisited, reviewsPosted, photosUploaded,
    // streak.currentStreak, etc.) actually unlocks the corresponding
    // catalog badge.
    _achievements?.refreshFromStats();

    final newPoints = _stats.totalPoints + pts;
    final newLevel = GamificationStats.levelForPoints(newPoints);
    final prevLevel = _stats.level;

    _stats = _stats.copyWith(
      totalPoints: newPoints,
      level: newLevel,
      placesVisited: action == 'check_in'
          ? _stats.placesVisited + 1
          : _stats.placesVisited,
      reviewsPosted: action == 'review'
          ? _stats.reviewsPosted + 1
          : _stats.reviewsPosted,
      photosUploaded: action == 'photo'
          ? _stats.photosUploaded + 1
          : _stats.photosUploaded,
      // Reflect the streak (now the source of truth) into the
      // gamification stats so the UI never goes out of sync.
      currentStreak: _streak?.currentStreak ?? _stats.currentStreak,
      longestStreak: _streak?.longestStreak ?? _stats.longestStreak,
      totalVisitDays: _streak?.totalVisitDays ?? _stats.totalVisitDays,
      lastVisitDate: _streak?.lastVisitDate ?? _stats.lastVisitDate,
      // Pull in any catalog badges the achievement provider just
      // unlocked (refreshFromStats called addBadgeIfMissing).
      badges: _stats.badges,
    );

    await _save();
    notifyListeners();

    if (action == 'check_in' && placeId != null && placeId.isNotEmpty) {
      final userId =
          SupabaseService.instance.clientOrNull?.auth.currentUser?.id ?? '';
      if (userId.isNotEmpty) {
        final result = await SupabaseService.instance.registerCheckin(
          userId,
          placeId,
        );
        if (!result.ok) {
          final errMsg = result.error?.message ?? 'unknown error';
          final errCode = result.error?.code ?? '';
          _lastCheckinError = errCode.isNotEmpty
              ? '[$errCode] $errMsg'
              : errMsg;
          debugPrint(
            'GamificationProvider.applyAction: registerCheckin FAILED '
            'for userId=$userId placeId=$placeId -> $_lastCheckinError',
          );
        } else {
          _lastCheckinError = null;
          debugPrint(
            'GamificationProvider.applyAction: check-in saved to DB '
            'placeId=$placeId',
          );
        }
        notifyListeners();
      } else {
        debugPrint(
          'GamificationProvider.applyAction: no signed-in user, '
          'skipped registerCheckin',
        );
      }
    }

    // Pick the most-recently unlocked catalog badge to show in the UI.
    if (newLevel != prevLevel) return _levelBadge(newLevel);
    final justUnlocked = _stats.badges
        .where((b) =>
            b.earnedAt != null &&
            DateTime.now().difference(b.earnedAt!).inSeconds.abs() < 30 &&
            AchievementCatalog.byId(b.id) != null)
        .toList();
    if (justUnlocked.isNotEmpty) {
      justUnlocked.sort((a, b) => b.earnedAt!.compareTo(a.earnedAt!));
      return justUnlocked.first;
    }
    return null;
  }

  Badge? _levelBadge(String level) {
    return Badge(
      id: 'lvl_$level',
      name: '$level rank',
      description: 'Reached the $level tier',
      iconName: 'military_tech',
      tier: 'silver',
      earnedAt: DateTime.now(),
      pointsAwarded: 25,
    );
  }

  static const List<int> streakMilestones = [5, 10, 25, 50];

  Future<Badge?> checkStreakMilestone(int streak) async {
    if (!streakMilestones.contains(streak)) return null;
    final id = 'b_streak_$streak';
    if (_stats.badges.any((b) => b.id == id)) return null;

    final badge = Badge(
      id: id,
      name: 'badge_streak_$streak',
      description: 'Visited $streak places',
      iconName: 'local_fire_department',
      tier: streak >= 25 ? 'gold' : 'silver',
      earnedAt: DateTime.now(),
      pointsAwarded: 0,
    );
    _stats = _stats.copyWith(badges: [..._stats.badges, badge]);
    await _save();
    notifyListeners();
    return badge;
  }

  Future<void> addBadgeIfMissing(Badge badge) async {
    if (_stats.badges.any((b) => b.id == badge.id)) return;
    _stats = _stats.copyWith(
      badges: [..._stats.badges, badge],
      totalPoints: _stats.totalPoints + badge.pointsAwarded,
      level: GamificationStats.levelForPoints(
        _stats.totalPoints + badge.pointsAwarded,
      ),
    );
    await _save();
    notifyListeners();
  }

  void setUserIdentity({
    required String userId,
    required String userName,
    String? avatarColorHex,
  }) {
    _stats = GamificationStats(
      userId: userId,
      userName: userName,
      avatarColorHex: avatarColorHex ?? _stats.avatarColorHex,
      totalPoints: _stats.totalPoints,
      placesVisited: _stats.placesVisited,
      reviewsPosted: _stats.reviewsPosted,
      photosUploaded: _stats.photosUploaded,
      badges: _stats.badges,
      level: _stats.level,
    );
    _save();
    notifyListeners();
  }

  void reset() {
    _stats = GamificationStats(
      userId: _stats.userId,
      userName: _stats.userName,
      avatarColorHex: _stats.avatarColorHex,
    );
    _save();
    notifyListeners();
  }
}