import 'package:flutter/foundation.dart';

import '../core/services/supabase_service.dart';
import '../data/models/gamification_stats.dart';

class LeaderboardProvider extends ChangeNotifier {
  final SupabaseService _supa = SupabaseService.instance;
  List<GamificationStats> _entries = [];
  bool _loading = false;

  List<GamificationStats> get entries => List.unmodifiable(_entries);
  bool get isLoading => _loading;

  Future<void> load({int limit = 50}) async {
    _loading = true;
    notifyListeners();
    _entries = await _supa.fetchLeaderboard(limit: limit);
    _loading = false;
    notifyListeners();
  }

  void refreshWithUserStats(GamificationStats userStats) {
    _entries.removeWhere((e) => e.userId == userStats.userId);
    _entries.add(userStats);
    _entries.sort((a, b) => b.totalPoints.compareTo(a.totalPoints));
    notifyListeners();
  }
}
