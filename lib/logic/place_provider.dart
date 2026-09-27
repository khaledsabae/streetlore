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
  /// v1.0.39: monotonic lifetime check-in count. Incremented only
  /// on a successful check-in (never decremented on uncheck) and
  /// persisted to SharedPreferences so it survives cold start.
  /// Reconciled against the server count by `fetchRemoteCounts`
  /// (which only ever raises it, never lowers it). The Profile
  /// screen's "Explored" counter uses this so a check-in +
  /// uncheck sequence still increments the achievement.
  int _lifetimeCheckinCount = 0;
  static const String _kLifetimeCheckinKey = 'lifetime_checkin_count_v1';

  int get remoteSavedCount => _remoteSavedCount;
  int get remoteCheckinCount => _remoteCheckinCount;
  int get lifetimeCheckinCount => _lifetimeCheckinCount;

  PlaceProvider() {
    _loadSavedPlaces();
    _loadLifetimeCheckin();
  }

  Future<void> _loadLifetimeCheckin() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _lifetimeCheckinCount = prefs.getInt(_kLifetimeCheckinKey) ?? 0;
      notifyListeners();
    } catch (e) {
      debugPrint('PlaceProvider._loadLifetimeCheckin: $e');
    }
  }

  Future<void> _saveLifetimeCheckin() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_kLifetimeCheckinKey, _lifetimeCheckinCount);
    } catch (e) {
      debugPrint('PlaceProvider._saveLifetimeCheckin: $e');
    }
  }

  Future<void> fetchRemoteCounts(String userId) async {
    if (userId.isEmpty) return;
    try {
      final savedRes = await _client
          .from('saved_places')
          .select()
          .eq('user_id', userId)
          .count(CountOption.exact);
      _remoteSavedCount = savedRes.count;

      final checkinRes = await _client
          .from('place_checkins')
          .select()
          .eq('user_id', userId)
          .count(CountOption.exact);
      _remoteCheckinCount = checkinRes.count;
      // v1.0.39: raise the monotonic lifetime if the server count
      // is higher (e.g. user checked in from another device). Never
      // lower it - the local counter is the source of truth.
      if (checkinRes.count > _lifetimeCheckinCount) {
        _lifetimeCheckinCount = checkinRes.count;
        await _saveLifetimeCheckin();
      }

      debugPrint('Remote counts: saved=$_remoteSavedCount, checkins=$_remoteCheckinCount, lifetime=$_lifetimeCheckinCount');
      notifyListeners();
    } catch (e) {
      debugPrint('fetchRemoteCounts error: $e');
    }
  }

  /// Optimistic local increment of the remote check-in counter. The UI
  /// must show the new total the INSTANT the user taps Check-in - we
  /// cannot wait for `fetchRemoteCounts` to round-trip Supabase. The
  /// counter will be reconciled by the follow-up `fetchRemoteCounts`
  /// call the check-in screen fires right after this.
  ///
  /// v1.0.39: also bumps [lifetimeCheckinCount] and persists it to
  /// SharedPreferences. The lifetime counter never decreases on
  /// uncheck, so the Profile "Explored" digit only goes up.
  void bumpLocalCheckinCount() {
    _remoteCheckinCount += 1;
    _lifetimeCheckinCount += 1;
    _saveLifetimeCheckin();
    notifyListeners();
    debugPrint(
      'PlaceProvider.bumpLocalCheckinCount -> '
      'remote=$_remoteCheckinCount lifetime=$_lifetimeCheckinCount',
    );
  }

  /// v1.0.38: optimistic local decrement of the remote check-in
  /// counter (mirror of [bumpLocalCheckinCount] for the un-check
  /// path). The UI flips back to "Check-in" the moment the user
  /// taps the green Visited button; the follow-up
  /// `fetchRemoteCounts` reconciles the persisted count once the
  /// DELETE round-trip completes.
  ///
  /// v1.0.39: NO-OP for [lifetimeCheckinCount] - we keep the
  /// achievement counter monotonic, so uncheck decrements only the
  /// "currently active" count.
  void unbumpLocalCheckinCount() {
    if (_remoteCheckinCount > 0) _remoteCheckinCount -= 1;
    notifyListeners();
    debugPrint(
      'PlaceProvider.unbumpLocalCheckinCount -> '
      'remote=$_remoteCheckinCount lifetime=$_lifetimeCheckinCount',
    );
  }

  /// Optimistic local increment of the remote saved-places counter. The
  /// UI updates immediately so the Profile screen never flashes 0 while
  /// the Supabase upsert is in flight. Reconciled by the next
  /// `fetchRemoteCounts` (the save provider always fires one).
  void bumpLocalSavedCount() {
    _remoteSavedCount += 1;
    notifyListeners();
    debugPrint(
      'PlaceProvider.bumpLocalSavedCount -> $_remoteSavedCount',
    );
  }

  /// Optimistic local decrement of the remote saved-places counter
  /// (mirror of [bumpLocalSavedCount] for unsave actions).
  void unbumpLocalSavedCount() {
    if (_remoteSavedCount > 0) _remoteSavedCount -= 1;
    notifyListeners();
    debugPrint(
      'PlaceProvider.unbumpLocalSavedCount -> $_remoteSavedCount',
    );
  }

  bool _isFilterOpenNow = false;
  bool _isFilterCheapest = false;
  bool _isFilterNearest = false;
  /// Max price level the user wants to see (null = any).
  PriceLevel? _maxPriceLevel;
  /// Show only free places when true (overrides _maxPriceLevel).
  bool _onlyFree = false;

  bool get isFilterOpenNow => _isFilterOpenNow;
  bool get isFilterCheapest => _isFilterCheapest;
  bool get isFilterNearest => _isFilterNearest;
  PriceLevel? get maxPriceLevel => _maxPriceLevel;
  bool get onlyFree => _onlyFree;

  Future<void> loadPlaces({bool force = false}) async {
    if (_loading) return;
    if (!force && _places.isNotEmpty) return;

    // 0) Offline-first seed: if we have a Hive cache from a previous
    //    download, hydrate `_places` immediately so the UI never has
    //    to wait for a (potentially timing-out) Supabase round-trip.
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
          .order('id')
          .timeout(const Duration(seconds: 10));
      final list = (res as List<dynamic>)
          .map((e) => _placeFromSupabase(e as Map<String, dynamic>))
          .toList();
      if (list.isEmpty) {
        // Supabase answered but empty (rate-limited / no rows). Keep
        // the Hive seed if we already had one, otherwise fall back.
        _places = _places.isNotEmpty
            ? _places
            : (OfflineProvider.cachedFallback.isNotEmpty
                ? OfflineProvider.cachedFallback
                : List<PlaceModel>.from(fallbackPlaces));
        _error = null;
      } else {
        _places = list;
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
      // else: keep the existing _places as-is (offline first seed wins)
    } finally {
      _loading = false;
      // Inject the seed hotels so they appear as full places in the
      // Home list and Place Details flow.
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
    // Fallback to the offline Hive cache so a place page opened while
    // offline can still render (the user explicitly downloaded that pack).
    final cached = OfflineProvider.cachedFallback;
    for (final p in cached) {
      if (p.id == id) return p;
    }
    return null;
  }

  /// True when the provider has any places loaded (either from Supabase
  /// or the Hive fallback). The Offline Download UI uses this to avoid
  /// running a download while the place list is still empty.
  bool get hasPlaces => _places.isNotEmpty;

  /// Static seed hotels are treated as real places (Places list,
  /// save/check-in, Place Details) - merged into `_places` at load.
  /// Use [mergeSeedHotels] after [loadPlaces] to register them.
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
        final byCat = a.category.compareTo(b.category);
        if (byCat != 0) return byCat;
        return a.name.compareTo(b.name);
      });
    _places = List<PlaceModel>.unmodifiable(merged);
    notifyListeners();
    debugPrint(
      'PlaceProvider: merged ${additions.length} seed hotels into _places '
      '(total now ${_places.length})',
    );
  }

  PlaceModel _placeFromSupabase(Map<String, dynamic> json) =>
      placeModelFromSupabaseRow(json);

  Future<void> _loadSavedPlaces() async {
    final prefs = await SharedPreferences.getInstance();
    final savedData = prefs.getStringList('saved_places_data') ?? [];
    _savedPlaces = savedData
        .map((jsonStr) => PlaceModel.fromJson(jsonDecode(jsonStr)))
        .toList();
    notifyListeners();
  }

  /// Pull the user's saved places from Supabase and merge them into
  /// the local cache. Returns true if the merge produced any change.
  /// Call this right after sign-in or on app start.
  Future<bool> bootstrapForUser(String userId) async {
    if (userId.isEmpty) return false;
    debugPrint(
      'PlaceProvider.bootstrapForUser: counting DB rows for $userId',
    );
    // Fire an explicit COUNT for saved_places + place_checkins so any
    // silent failure (RLS, missing table, network) is visible in
    // logcat and the Profile counters can show the real numbers
    // instead of 0. Errors are non-fatal - we still continue with the
    // pull below.
    final dbCounts = await SupabaseService.instance
        .countUserRows(userId);
    debugPrint(
      'PlaceProvider.bootstrapForUser: DB counts for $userId -> '
      'saved_places=${dbCounts.savedPlaces} '
      'place_checkins=${dbCounts.checkIns}',
    );
    final remote = await SupabaseService.instance.pullSavedPlaces(userId);
    final remoteIds = remote.map((p) => p.id).toSet();
    // Keep the local entries that aren't already on the server, so a
    // local toggle that hasn't synced yet is not silently dropped.
    final cleanLocal =
        _savedPlaces.where((p) => !remoteIds.contains(p.id)).toList();
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
    // v1.0.34: optimistic local bump so the Profile "Saved" counter
    // updates instantly, before the Supabase round-trip. If the
    // underlying write fails we undo the bump in the catch block below.
    if (wasSaved) {
      unbumpLocalSavedCount();
    } else {
      bumpLocalSavedCount();
    }
    notifyListeners();
    // Push the change to Supabase so the saved list survives a logout /
    // device switch / reinstall. SharedPreferences is only the local
    // cache. We AWAIT the call so any RLS / network failure is surfaced
    // (debugPrint'd in SupabaseService) and not silently dropped, then
    // notify listeners AGAIN once the DB write confirms the change so
    // UI / counters stay in sync with the source of truth.
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
          // Roll back the optimistic bump so the UI matches the DB.
          // fetchRemoteCounts will refresh from the server next.
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
        // Re-emit so any UI listening for the second-tick (counters,
        // saved badge) reflects the final DB state.
        notifyListeners();
      } catch (e, st) {
        debugPrint(
          'PlaceProvider.toggleSave: Supabase write threw for '
          'placeId=${place.id}: $e\n$st',
        );
        // Roll back the optimistic bump so the UI matches the DB.
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

  /// Set the maximum price level (Free, Cheap, Moderate, Expensive).
  /// Pass null to clear.
  void setMaxPriceLevel(PriceLevel? level) {
    _maxPriceLevel = level;
    _isFilterCheapest = level != null;
    notifyListeners();
  }

  /// Toggle "only free places" filter.
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

  /// Parses the openHours string (e.g. "9:00 AM - 5:00 PM" or "Open 24 hours")
  /// and returns true if the current time falls within the range.
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

  /// Returns total minutes since midnight for strings like "9:00 AM", "5:30 PM", "17:00"
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

/// Top-level helper: build a [PlaceModel] from a Supabase `places` row.
/// Snugly tolerant of missing/extra columns and accepts both snake_case
/// and camelCase keys so any caller (PlaceProvider, OfflineProvider,
/// admin import scripts) sees the same result.
///
/// This was extracted from `PlaceProvider._placeFromSupabase` after the
/// offline download bug where [PlaceModel.fromJson] was being used
/// instead, throwing on every row because Supabase returns snake_case.
PlaceModel placeModelFromSupabaseRow(Map<String, dynamic> json) {
  return PlaceModel(
    id: (json['id'] ?? '').toString(),
    name: (json['name'] ?? '').toString(),
    nameAr: json['name_ar']?.toString(),
    description: (json['description'] ?? '').toString(),
    descriptionAr: json['description_ar']?.toString(),
    imageUrl: (json['image_url'] ?? '').toString(),
    rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
    category: (json['category'] ?? 'General').toString(),
    categoryAr: json['category_ar']?.toString(),
    lat: (json['lat'] as num?)?.toDouble() ?? 0.0,
    lng: (json['lng'] as num?)?.toDouble() ?? 0.0,
    address: (json['address'] ?? 'Alexandria, Egypt').toString(),
    addressAr: json['address_ar']?.toString(),
    openHours: (json['open_hours'] ?? '9:00 AM - 6:00 PM').toString(),
    reviewCount: (json['review_count'] as int?) ?? 0,
    priceLevel: _priceLevelFromStringShared(json['price_level']?.toString()),
    priceNote: (json['price_note'] ?? '').toString(),
    priceNoteAr: json['price_note_ar']?.toString(),
    isHiddenGem: (json['is_hidden_gem'] as bool?) ?? false,
    priceLocalEgp: json['price_local_egp'] as int?,
    priceForeignerEgp: json['price_foreigner_egp'] as int?,
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
