import 'package:flutter_test/flutter_test.dart';
import 'package:streetlore/data/achievement_catalog.dart';
import 'package:streetlore/data/models/gamification_stats.dart';

void main() {
  group('GamificationStats', () {
    test('levelForPoints thresholds', () {
      expect(GamificationStats.levelForPoints(0), 'Explorer');
      expect(GamificationStats.levelForPoints(499), 'Explorer');
      expect(GamificationStats.levelForPoints(500), 'Wanderer');
      expect(GamificationStats.levelForPoints(2000), 'Cartographer');
      expect(GamificationStats.levelForPoints(5000), 'Lorekeeper');
    });

    test('pointsFor matches the server-side clamp in '
        'supabase/migrations/2026_10_04_security_hardening.sql', () {
      // If these change, update leaderboard_clamp() too.
      expect(GamificationStats.pointsFor('check_in'), 50);
      expect(GamificationStats.pointsFor('review'), 20);
      expect(GamificationStats.pointsFor('photo'), 30);
      expect(GamificationStats.pointsFor('chat_message'), 2);
      expect(GamificationStats.pointsFor('unknown'), 0);
    });
  });

  group('AchievementCatalog', () {
    test('ids are unique and resolvable', () {
      final ids = AchievementCatalog.all.map((a) => a.id).toList();
      expect(ids.toSet().length, ids.length);
      for (final id in ids) {
        expect(AchievementCatalog.byId(id)?.id, id);
      }
    });

    test('every achievement has a positive target and points', () {
      for (final a in AchievementCatalog.all) {
        expect(a.target, greaterThan(0), reason: a.id);
        expect(a.points, greaterThan(0), reason: a.id);
      }
    });

    test('total badge points fit the server badge budget (3500)', () {
      final total =
          AchievementCatalog.all.fold<int>(0, (sum, a) => sum + a.points);
      expect(total, lessThanOrEqualTo(3500));
    });
  });
}
