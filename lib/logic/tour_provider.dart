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

  TourProvider() {
    _loadSavedTours();
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
      name: (json['name'] as String?) ?? 'Unknown Place',
      description: (json['description'] as String?) ?? '',

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

  
  
  Future<bool> bootstrapForUser(String userId) async {
    if (userId.isEmpty) return false;
    final remoteMaps = await SupabaseService.instance.pullSavedTours(userId);
    if (remoteMaps.isEmpty) {
      debugPrint(
        'TourProvider: no remote saved tours for $userId, keeping local',
      );
      return false;
    }
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
    return true;
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
