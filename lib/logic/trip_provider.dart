import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/services/supabase_service.dart';
import '../data/models/place_model.dart';

class TripProvider extends ChangeNotifier {
  List<PlaceModel> _tripPlaces = [];
  List<PlaceModel> get tripPlaces => _tripPlaces;

  /// Set of place ids the current user has already checked in at.
  /// Refreshed on login + every check-in via [markVisited].
  final Set<String> _visitedPlaceIds = <String>{};
  Set<String> get visitedPlaceIds => Set.unmodifiable(_visitedPlaceIds);

  TripProvider() {
    _loadTrip();
    _loadVisitedFromSupabase();
  }

  Future<void> _loadTrip() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getStringList('my_trip_data') ?? [];
    _tripPlaces = data
        .map((jsonStr) => PlaceModel.fromJson(jsonDecode(jsonStr)))
        .toList();
    notifyListeners();
  }

  /// Pull every place_id the current user has ever checked in at. Safe to
  /// call multiple times — silent no-op if no user is signed in yet.
  Future<void> _loadVisitedFromSupabase() async {
    final client = SupabaseService.instance.clientOrNull;
    if (client == null) return;
    final userId = client.auth.currentUser?.id ?? '';
    if (userId.isEmpty) return;
    try {
      final rows = await client
          .from('place_checkins')
          .select('place_id')
          .eq('user_id', userId);
      _visitedPlaceIds
        ..clear()
        ..addAll(rows.map((r) => r['place_id'].toString()));
      notifyListeners();
    } catch (e) {
      debugPrint('TripProvider._loadVisitedFromSupabase: $e');
    }
  }

  /// Public re-fresh — call after sign-in / sign-out so visited set is current.
  Future<void> refreshVisited() => _loadVisitedFromSupabase();

  /// Add a freshly-checked-in place id so the trip planner can show the badge
  /// immediately (don't wait for the next refresh).
  void markVisited(String placeId) {
    if (placeId.isEmpty) return;
    if (_visitedPlaceIds.add(placeId)) notifyListeners();
  }

  bool isInTrip(String id) {
    return _tripPlaces.any((place) => place.id == id);
  }

  bool isVisited(String id) => _visitedPlaceIds.contains(id);

  Future<void> togglePlaceInTrip(PlaceModel place) async {
    if (isInTrip(place.id)) {
      _tripPlaces.removeWhere((p) => p.id == place.id);
    } else {
      _tripPlaces.add(place);
    }
    await _saveTrip();
  }

  Future<void> reorderTrip(int oldIndex, int newIndex) async {
    if (oldIndex < 0 || oldIndex >= _tripPlaces.length) return;
    if (newIndex < 0 || newIndex > _tripPlaces.length) return;
    final place = _tripPlaces.removeAt(oldIndex);
    _tripPlaces.insert(newIndex, place);
    await _saveTrip();
  }

  Future<void> _saveTrip() async {
    final prefs = await SharedPreferences.getInstance();
    final data = _tripPlaces.map((p) => jsonEncode(p.toJson())).toList();
    await prefs.setStringList('my_trip_data', data);
    notifyListeners();
  }

  Future<void> clearTrip() async {
    _tripPlaces = [];
    await _saveTrip();
  }
}
