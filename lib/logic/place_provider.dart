import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/services/supabase_service.dart';
import '../data/mock_data.dart' show fallbackPlaces;
import '../data/models/map_seed.dart';
import '../data/models/place_model.dart';
import 'offline_provider.dart';

class PlaceProvider extends ChangeNotifier {
  SupabaseClient get _client => Supabase.instance.client;

  List<PlaceModel> _places = [];
  List<PlaceModel> get places => List.unmodifiable(_places);

  bool _loading = false;
  bool get loading => _loading;

  String? _error;
  String? get error => _error;

  List<PlaceModel> _savedPlaces = [];
  List<PlaceModel> get savedPlaces => _savedPlaces;

  int _remoteSavedCount = 0;
  int _remoteCheckinCount = 0;

  int get remoteSavedCount => _remoteSavedCount;
  int get remoteCheckinCount => _remoteCheckinCount;

  PlaceProvider() {
    _loadSavedPlaces();
  }

  Future<void> fetchRemoteCounts(String userId) async {
    final effectiveUserId = userId.isNotEmpty
        ? userId
        : (Supabase.instance.client.auth.currentUser?.id ?? '');
    if (effectiveUserId.isEmpty) {
      debugPrint(
        'PlaceProvider.fetchRemoteCounts: no userId available '
        '(param empty and Supabase.currentUser null), skipping',
      );
      return;
    }

    try {
      final savedRes = await _client
          .from('saved_places')
          .select('user_id')
          .eq('user_id', effectiveUserId)
          .count();
      _remoteSavedCount =
          (savedRes as dynamic).count as int? ?? 0;

      final checkinRes = await _client
          .from('place_checkins')
          .select('user_id')
          .eq('user_id', effectiveUserId)
          .count();
      _remoteCheckinCount =
          (checkinRes as dynamic).count as int? ?? 0;

      debugPrint(
        'PlaceProvider.fetchRemoteCounts: user=$effectiveUserId '
        'saved=$_remoteSavedCount checkins=$_remoteCheckinCount',
      );

      notifyListeners();
    } catch (e, st) {
      debugPrint(
        'PlaceProvider.fetchRemoteCounts: error for user=$effectiveUserId: $e\n$st',
      );
    }
  }

  void bumpLocalSavedCount() {
    _remoteSavedCount += 1;
    notifyListeners();
    debugPrint('PlaceProvider.bumpLocalSavedCount -> $_remoteSavedCount');
  }

  void unbumpLocalSavedCount() {
    if (_remoteSavedCount > 0) _remoteSavedCount -= 1;
    notifyListeners();
    debugPrint('PlaceProvider.unbumpLocalSavedCount -> $_remoteSavedCount');
  }

  bool _isFilterOpenNow = false;
  bool _isFilterCheapest = false;
  bool _isFilterNearest = false;

  PriceLevel? _maxPriceLevel;

  bool _onlyFree = false;

  bool get isFilterOpenNow => _isFilterOpenNow;
  bool get isFilterCheapest => _isFilterCheapest;
  bool get isFilterNearest => _isFilterNearest;
  PriceLevel? get maxPriceLevel => _maxPriceLevel;
  bool get onlyFree => _onlyFree;

  Future<void> loadPlaces({bool force = false}) async {
    if (_loading) return;
    if (!force && _places.isNotEmpty) return;

    final cachedSeed = OfflineProvider.cachedFallback;
    if (cachedSeed.isNotEmpty && _places.isEmpty) {
      _places = cachedSeed;
      notifyListeners();
    }

    _loading = true;
    _error = null;
    notifyListeners();
    try {
      final res = await _client
          .from('places')
          .select()
          .order('display_order', ascending: true)
          .order('id', ascending: true)
          .timeout(const Duration(seconds: 10));
      final list = (res as List<dynamic>)
          .map((e) => _placeFromSupabase(e as Map<String, dynamic>))
          .toList();

      final filtered = _filterInvalidCoords(list);
      if (filtered.length != list.length) {
        debugPrint(
          'PlaceProvider.loadPlaces: filtered '
          '${list.length - filtered.length}/${list.length} rows '
          'with invalid coords',
        );
      }
      if (filtered.isEmpty) {
        _places = _places.isNotEmpty
            ? _places
            : (OfflineProvider.cachedFallback.isNotEmpty
                  ? OfflineProvider.cachedFallback
                  : List<PlaceModel>.from(fallbackPlaces));
        _error = null;
      } else {
        _places = filtered;
        _error = null;
      }
    } catch (e) {
      _error = 'Failed to load places: $e';
      final cached = OfflineProvider.cachedFallback;
      if (cached.isNotEmpty) {
        _places = cached;
      } else if (_places.isEmpty) {
        _places = List<PlaceModel>.from(fallbackPlaces);
      }
    } finally {
      _loading = false;

      mergeSeedHotels();
      notifyListeners();
    }
  }

  Future<void> ensureLoaded() async {
    if (_places.isEmpty) {
      await loadPlaces(force: true);
    }
  }

  Future<void> refresh() => loadPlaces(force: true);

  PlaceModel? findById(String id) {
    for (final p in _places) {
      if (p.id == id) return p;
    }

    final cached = OfflineProvider.cachedFallback;
    for (final p in cached) {
      if (p.id == id) return p;
    }
    return null;
  }

  bool get hasPlaces => _places.isNotEmpty;

  void mergeSeedHotels() {
    if (_places.isEmpty) return;
    final hotelSeeds = getSeedHotelPlaces();
    final existingIds = _places.map((p) => p.id).toSet();
    final additions = hotelSeeds
        .where((h) => !existingIds.contains(h.id))
        .toList(growable: false);
    if (additions.isEmpty) return;
    final merged = [..._places, ...additions]
      ..sort((a, b) {
        final byOrder = a.displayOrder.compareTo(b.displayOrder);
        if (byOrder != 0) return byOrder;
        final byCat = a.category.compareTo(b.category);
        if (byCat != 0) return byCat;
        return a.nameEn.compareTo(b.nameEn);
      });
    _places = List<PlaceModel>.unmodifiable(merged);
    notifyListeners();
    debugPrint(
      'PlaceProvider: merged ${additions.length} seed hotels into _places '
      '(total now ${_places.length})',
    );
  }

  PlaceModel _placeFromSupabase(Map<String, dynamic> json) {
    final model = placeModelFromSupabaseRow(json);

    if (!_hasValidCoords(model.lat, model.lng)) {
      debugPrint(
        'PlaceProvider._placeFromSupabase: filtered place '
        'id=${model.id} name="${model.nameEn}" with bad '
        'coords lat=${model.lat} lng=${model.lng}',
      );
    }
    return model;
  }

  bool _hasValidCoords(double lat, double lng) {
    if (lat == 0.0 && lng == 0.0) return false;
    if (lat < 29.5 || lat > 31.5) return false;
    if (lng < 29.0 || lng > 30.5) return false;
    return true;
  }

  List<PlaceModel> _filterInvalidCoords(List<PlaceModel> input) {
    return input
        .where((p) => _hasValidCoords(p.lat, p.lng))
        .toList(growable: false);
  }

  Future<void> _loadSavedPlaces() async {
    final prefs = await SharedPreferences.getInstance();
    final savedData = prefs.getStringList('saved_places_data') ?? [];
    _savedPlaces = savedData
        .map((jsonStr) => PlaceModel.fromJson(jsonDecode(jsonStr)))
        .toList();
    notifyListeners();
  }

  Future<bool> bootstrapForUser(String userId) async {
    if (userId.isEmpty) return false;
    debugPrint('PlaceProvider.bootstrapForUser: counting DB rows for $userId');

    final dbCounts = await SupabaseService.instance.countUserRows(userId);
    debugPrint(
      'PlaceProvider.bootstrapForUser: DB counts for $userId -> '
      'saved_places=${dbCounts.savedPlaces} '
      'place_checkins=${dbCounts.checkIns}',
    );
    final remote = await SupabaseService.instance.pullSavedPlaces(userId);
    final remoteIds = remote.map((p) => p.id).toSet();

    final cleanLocal = _savedPlaces
        .where((p) => !remoteIds.contains(p.id))
        .toList();
    final merged = [...remote, ...cleanLocal];
    if (merged.length != _savedPlaces.length ||
        !_listsSameIds(_savedPlaces, merged)) {
      final prefs = await SharedPreferences.getInstance();
      final encoded = merged.map((p) => jsonEncode(p.toJson())).toList();
      await prefs.setStringList('saved_places_data', encoded);
      _savedPlaces = merged;
      notifyListeners();
    }
    debugPrint(
      'PlaceProvider: bootstrapForUser($userId) '
      'remote=${remote.length} local+=${cleanLocal.length} total=${merged.length}',
    );
    return true;
  }

  bool _listsSameIds(List<PlaceModel> a, List<PlaceModel> b) {
    if (a.length != b.length) return false;
    final ids = b.map((p) => p.id).toSet();
    for (final p in a) {
      if (!ids.contains(p.id)) return false;
    }
    return true;
  }

  bool isSaved(String id) {
    return _savedPlaces.any((place) => place.id == id);
  }

  Future<void> toggleSave(PlaceModel place) async {
    final prefs = await SharedPreferences.getInstance();
    final wasSaved = isSaved(place.id);
    if (wasSaved) {
      _savedPlaces.removeWhere((p) => p.id == place.id);
    } else {
      _savedPlaces.add(place);
    }
    final savedData = _savedPlaces.map((p) => jsonEncode(p.toJson())).toList();
    await prefs.setStringList('saved_places_data', savedData);

    if (wasSaved) {
      unbumpLocalSavedCount();
    } else {
      bumpLocalSavedCount();
    }
    notifyListeners();

    final userId = Supabase.instance.client.auth.currentUser?.id ?? '';
    if (userId.isNotEmpty) {
      try {
        final ok = wasSaved
            ? await SupabaseService.instance.deleteSavedPlace(userId, place.id)
            : await SupabaseService.instance.pushSavedPlace(userId, place);
        if (!ok) {
          debugPrint(
            'PlaceProvider.toggleSave: Supabase write returned false '
            'for userId=$userId placeId=${place.id} wasSaved=$wasSaved',
          );

          if (wasSaved) {
            bumpLocalSavedCount();
          } else {
            unbumpLocalSavedCount();
          }
        } else {
          debugPrint(
            'PlaceProvider.toggleSave: Supabase write OK '
            'placeId=${place.id} wasSaved=$wasSaved',
          );
        }

        notifyListeners();
      } catch (e, st) {
        debugPrint(
          'PlaceProvider.toggleSave: Supabase write threw for '
          'placeId=${place.id}: $e\n$st',
        );

        if (wasSaved) {
          bumpLocalSavedCount();
        } else {
          unbumpLocalSavedCount();
        }
        notifyListeners();
      }
    } else {
      debugPrint(
        'PlaceProvider.toggleSave: no signed-in user, skipped Supabase sync',
      );
    }
  }

  Future<void> clearAllSaved() async {
    final prefs = await SharedPreferences.getInstance();
    _savedPlaces = [];
    await prefs.setStringList('saved_places_data', []);
    notifyListeners();
  }

  void toggleFilterOpenNow() {
    _isFilterOpenNow = !_isFilterOpenNow;
    notifyListeners();
  }

  void toggleFilterCheapest() {
    _isFilterCheapest = !_isFilterCheapest;
    if (!_isFilterCheapest) {
      _maxPriceLevel = null;
      _onlyFree = false;
    }
    notifyListeners();
  }

  void toggleFilterNearest() {
    _isFilterNearest = !_isFilterNearest;
    notifyListeners();
  }

  void setMaxPriceLevel(PriceLevel? level) {
    _maxPriceLevel = level;
    _isFilterCheapest = level != null;
    notifyListeners();
  }

  void toggleOnlyFree() {
    _onlyFree = !_onlyFree;
    _isFilterCheapest = _onlyFree || _maxPriceLevel != null;
    notifyListeners();
  }

  void clearFilters() {
    _isFilterOpenNow = false;
    _isFilterCheapest = false;
    _isFilterNearest = false;
    _maxPriceLevel = null;
    _onlyFree = false;
    notifyListeners();
  }

  List<PlaceModel> applyFilters(List<PlaceModel> initialPlaces) {
    List<PlaceModel> result = List<PlaceModel>.from(initialPlaces);
    if (_isFilterOpenNow) {
      result = result.where((p) => _isPlaceOpenNow(p.openHours)).toList();
    }
    if (_onlyFree) {
      result = result.where((p) => p.priceLevel == PriceLevel.free).toList();
    } else if (_maxPriceLevel != null) {
      result = result
          .where((p) => p.priceLevel.index <= _maxPriceLevel!.index)
          .toList();
    }
    if (_isFilterCheapest) {
      result.sort((a, b) => a.priceLevel.index.compareTo(b.priceLevel.index));
    }
    if (_isFilterNearest) {
      const refLat = 31.2001;
      const refLng = 29.9187;
      result.sort((a, b) {
        final da =
            (a.lat - refLat) * (a.lat - refLat) +
            (a.lng - refLng) * (a.lng - refLng);
        final db =
            (b.lat - refLat) * (b.lat - refLat) +
            (b.lng - refLng) * (b.lng - refLng);
        return da.compareTo(db);
      });
    }
    return result;
  }

  bool _isPlaceOpenNow(String openHours) {
    final clean = openHours.trim();
    if (clean.toLowerCase() == 'open 24 hours') return true;

    final parts = clean.split('-');
    if (parts.length < 2) return true;
    final open = _parseHourMin(parts[0].trim());
    final close = _parseHourMin(parts[1].trim());
    if (open == null || close == null) return true;
    final now = DateTime.now();
    final nowMins = now.hour * 60 + now.minute;
    if (close > open) {
      return nowMins >= open && nowMins < close;
    } else {
      return nowMins >= open || nowMins < close;
    }
  }

  int? _parseHourMin(String s) {
    final upper = s.toUpperCase();
    final isPm = upper.contains('PM');
    final isAm = upper.contains('AM');
    final cleaned = upper.replaceAll('AM', '').replaceAll('PM', '').trim();
    final colonIdx = cleaned.indexOf(':');
    if (colonIdx < 0) return null;
    final h = int.tryParse(cleaned.substring(0, colonIdx).trim());
    final m = int.tryParse(cleaned.substring(colonIdx + 1).trim());
    if (h == null || m == null) return null;
    var hour = h;
    if (isPm && hour < 12) hour += 12;
    if (isAm && hour == 12) hour = 0;
    return hour * 60 + m;
  }
}

PlaceModel placeModelFromSupabaseRow(Map<String, dynamic> json) {
  final urlsRaw = json['image_urls'];
  List<String> urls = const <String>[];
  if (urlsRaw is List) {
    urls = urlsRaw
        .where((e) => e != null)
        .map((e) => e.toString().trim())
        .where((s) => s.isNotEmpty)
        .toList(growable: false);
  }
  return PlaceModel(
    id: (json['id'] ?? '').toString(),
    nameEn: (json['name_en'] ?? json['name'] ?? '').toString(),
    nameAr:
        json['name_ar']?.toString() ?? json['nameAr']?.toString(),
    descriptionEn:
        (json['description_en'] ?? json['description'] ?? '').toString(),
    descriptionAr:
        json['description_ar']?.toString() ??
        json['descriptionAr']?.toString(),
    imageUrl: (json['image_url'] ?? '').toString(),
    imageUrls: urls,
    rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
    category: (json['category'] ?? 'General').toString(),
    categoryAr:
        json['category_ar']?.toString() ?? json['categoryAr']?.toString(),
    lat: (json['lat'] as num?)?.toDouble() ?? 0.0,
    lng: (json['lng'] as num?)?.toDouble() ?? 0.0,
    address: (json['address'] ?? 'Alexandria, Egypt').toString(),
    addressAr:
        json['address_ar']?.toString() ?? json['addressAr']?.toString(),
    openHours: (json['open_hours'] ?? '9:00 AM - 6:00 PM').toString(),
    reviewCount: (json['review_count'] as int?) ?? 0,
    priceLevel: _priceLevelFromStringShared(json['price_level']?.toString()),
    priceNote: (json['price_note'] ?? '').toString(),
    priceNoteAr:
        json['price_note_ar']?.toString() ?? json['priceNoteAr']?.toString(),
    isHiddenGem: (json['is_hidden_gem'] as bool?) ?? false,
    priceLocalEgp: json['price_local_egp'] as int?,
    priceForeignerEgp: json['price_foreigner_egp'] as int?,
    displayOrder: (json['display_order'] as num?)?.toInt() ?? 999,
    bestTimeNote: json['best_time_note']?.toString(),
    bestTimeToVisit: json['best_time_to_visit']?.toString(),
    isIndoor: (json['is_indoor'] as bool?) ?? false,
  );
}

PriceLevel _priceLevelFromStringShared(String? s) {
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
