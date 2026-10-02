import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/services/supabase_service.dart';
import '../data/models/itinerary_model.dart';
import '../data/models/place_model.dart';
import '../data/mock_data.dart' show fallbackTours;

class TourProvider extends ChangeNotifier {
  SupabaseClient get _client => Supabase.instance.client;

  List<ItineraryModel> _tours = [];
  List<ItineraryModel> get tours => List.unmodifiable(_tours);

  bool _loading = false;
  bool get loading => _loading;

  String? _error;
  String? get error => _error;

  List<ItineraryModel> _savedTours = [];
  List<ItineraryModel> get savedTours => _savedTours;

  Set<String> _visitedTourIds = <String>{};
  Set<String> get visitedTourIds => Set<String>.unmodifiable(_visitedTourIds);
  int get visitedToursCount => _visitedTourIds.length;
  bool isTourVisited(String tourId) => _visitedTourIds.contains(tourId);

  TourProvider() {
    _loadSavedTours();
    _loadVisitedTourIds();
  }

  Future<void> loadTours({bool force = false}) async {
    if (_loading) return;
    if (!force && _tours.isNotEmpty) return;
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      final res = await _client
          .from('tours_with_places')
          .select()
          .order('id')
          .timeout(const Duration(seconds: 10));
      final loaded = (res as List<dynamic>)
          .map((e) => _tourFromSupabase(e as Map<String, dynamic>))
          .toList();
      if (loaded.isEmpty) {
        _tours = List<ItineraryModel>.from(fallbackTours);
      } else {
        _tours = loaded;
      }
      _error = null;
    } catch (e) {
      _error = 'Failed to load tours: $e';
      debugPrint('TourProvider: $e');
      if (_tours.isEmpty) {
        _tours = List<ItineraryModel>.from(fallbackTours);
      }
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> refresh() => loadTours(force: true);

  ItineraryModel _tourFromSupabase(Map<String, dynamic> json) {
    final placesJson = (json['places'] as List<dynamic>?) ?? const [];
    final places = placesJson
        .map((e) => _placeFromSupabaseJson(e as Map<String, dynamic>))
        .toList();
    return ItineraryModel(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      duration: json['duration'] as String,
      imageUrl: json['image_url'] as String,
      places: places,
    );
  }

  PlaceModel _placeFromSupabaseJson(Map<String, dynamic> json) {
    return PlaceModel(
      id: (json['id'] as String?) ?? '',
      nameEn: (json['name_en'] as String?) ??
          (json['name'] as String?) ??
          'Unknown Place',
      nameAr: json['name_ar'] as String?,
      descriptionEn: (json['description_en'] as String?) ??
          (json['description'] as String?) ??
          '',
      descriptionAr: json['description_ar'] as String?,

      imageUrl:
          (json['image_url'] as String?) ?? (json['imageUrl'] as String?) ?? '',
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      category: (json['category'] as String?) ?? 'General',
      lat: (json['lat'] as num?)?.toDouble() ?? 0.0,
      lng: (json['lng'] as num?)?.toDouble() ?? 0.0,
      address: (json['address'] as String?) ?? 'Alexandria, Egypt',
      openHours:
          (json['open_hours'] as String?) ??
          (json['openHours'] as String?) ??
          '9:00 AM - 6:00 PM',
      reviewCount:
          (json['review_count'] as int?) ?? (json['reviewCount'] as int?) ?? 0,
      priceLevel: _priceLevelFromString(
        (json['price_level'] as String?) ?? (json['priceLevel'] as String?),
      ),
      priceNote:
          (json['price_note'] as String?) ??
          (json['priceNote'] as String?) ??
          '',
      isHiddenGem:
          (json['is_hidden_gem'] as bool?) ??
          (json['isHiddenGem'] as bool?) ??
          false,
      priceLocalEgp:
          (json['price_local_egp'] as int?) ?? (json['priceLocalEgp'] as int?),
      priceForeignerEgp:
          (json['price_foreigner_egp'] as int?) ??
          (json['priceForeignerEgp'] as int?),
    );
  }

  PriceLevel _priceLevelFromString(String? s) {
    switch (s) {
      case 'cheap':
        return PriceLevel.cheap;
      case 'moderate':
        return PriceLevel.moderate;
      case 'expensive':
        return PriceLevel.expensive;
      default:
        return PriceLevel.free;
    }
  }

  Future<void> _loadSavedTours() async {
    final prefs = await SharedPreferences.getInstance();
    final String? toursJson = prefs.getString('saved_tours_data');
    if (toursJson != null) {
      final List<dynamic> decodedList = json.decode(toursJson);
      _savedTours = decodedList
          .map((item) => ItineraryModel.fromJson(item))
          .toList();
      notifyListeners();
    }
  }

  Future<void> _saveToursToStorage() async {
    final prefs = await SharedPreferences.getInstance();
    final String encodedList = json.encode(
      _savedTours.map((t) => t.toJson()).toList(),
    );
    await prefs.setString('saved_tours_data', encodedList);
  }

  Future<void> _loadVisitedTourIds() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList('visited_tour_ids') ?? const <String>[];
    _visitedTourIds = raw.toSet();
    notifyListeners();
  }

  Future<void> _persistVisitedTourIds() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('visited_tour_ids', _visitedTourIds.toList());
  }

  Future<({bool ok})> markTourVisited(
    ItineraryModel tour,
    String userId,
  ) async {
    if (_visitedTourIds.contains(tour.id)) {
      return (ok: true);
    }
    _visitedTourIds.add(tour.id);
    notifyListeners();
    await _persistVisitedTourIds();

    if (userId.isEmpty) {
      return (ok: true);
    }

    bool allOk = true;
    for (final p in tour.places) {
      if (p.id.isEmpty) continue;
      try {
        final res = await SupabaseService.instance.registerCheckin(
          userId,
          p.id,
        );
        if (!res.ok) allOk = false;
      } catch (_) {
        allOk = false;
      }
    }
    return (ok: allOk);
  }

  Future<void> unmarkTourVisited(String tourId) async {
    if (!_visitedTourIds.contains(tourId)) return;
    _visitedTourIds.remove(tourId);
    notifyListeners();
    await _persistVisitedTourIds();
  }

  
  
  Future<bool> bootstrapForUser(String userId) async {
    if (userId.isEmpty) return false;
    final remoteMaps = await SupabaseService.instance.pullSavedTours(userId);
    if (remoteMaps.isEmpty) {
      debugPrint(
        'TourProvider: no remote saved tours for $userId, keeping local',
      );
    } else {
      final remote = <ItineraryModel>[];
      for (final m in remoteMaps) {
        try {
          remote.add(ItineraryModel.fromJson(m));
        } catch (_) {}
      }
      final remoteIds = remote.map((t) => t.id).toSet();
      final localOnly =
          _savedTours.where((t) => !remoteIds.contains(t.id)).toList();
      final merged = [...remote, ...localOnly];
      _savedTours = merged;
      await _saveToursToStorage();
      notifyListeners();
      debugPrint(
        'TourProvider: pulled ${remote.length} saved tours for $userId '
        '(total now ${merged.length})',
      );
    }

    await _syncVisitedFromCheckins(userId);
    return true;
  }

  Future<void> _syncVisitedFromCheckins(String userId) async {
    if (_tours.isEmpty) {
      try {
        await loadTours();
      } catch (_) {}
    }
    if (_tours.isEmpty) return;

    try {
      final res = await _client
          .from('place_checkins')
          .select('place_id')
          .eq('user_id', userId);
      final checkedInPlaceIds = (res as List)
          .map((e) => (e as Map<String, dynamic>)['place_id'] as String?)
          .whereType<String>()
          .toSet();

      bool changed = false;
      for (final tour in _tours) {
        if (tour.places.isEmpty) continue;
        final allCheckedIn =
            tour.places.every((p) => checkedInPlaceIds.contains(p.id));
        if (allCheckedIn && !_visitedTourIds.contains(tour.id)) {
          _visitedTourIds.add(tour.id);
          changed = true;
        }
      }
      if (changed) {
        await _persistVisitedTourIds();
        notifyListeners();
        debugPrint(
          'TourProvider: synced visited tours from place_checkins -> '
          '${_visitedTourIds.length} visited',
        );
      }
    } catch (e) {
      debugPrint('TourProvider._syncVisitedFromCheckins error: $e');
    }
  }

  void toggleTourSaved(ItineraryModel tour) {
    final isExisting = _savedTours.any((t) => t.id == tour.id);
    if (isExisting) {
      _savedTours.removeWhere((t) => t.id == tour.id);
    } else {
      _savedTours.add(tour);
    }
    _saveToursToStorage();
    notifyListeners();
  }

  bool isSaved(String id) {
    return _savedTours.any((t) => t.id == id);
  }
}
