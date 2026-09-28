import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

/// One search hit returned by the Nominatim geocoder.
class GeocodingResult {
  final double lat;
  final double lng;
  final String displayName;
  final String? name;
  final String? type;

  const GeocodingResult({
    required this.lat,
    required this.lng,
    required this.displayName,
    this.name,
    this.type,
  });
}

/// v1.0.43: thin wrapper around the public Nominatim
/// (OpenStreetMap) Search API.
///
///   GET https://nominatim.openstreetmap.org/search?
///       q={query}&format=json&limit=5&countrycodes=eg&bounded=1
///
/// Nominatim blocks empty / browser-like User-Agents and (per the
/// OSM usage policy) requires an identifying User-Agent that
/// includes a contact channel. We send
///   `streetlore/1.0.43 (https://github.com/mohamedsabae50-prog/streetlore; admin@streetlore.app)`
/// which previously returned `[]` because the v1.0.42 UA lacked a
/// reachable contact and got 403'd by the public instance.
/// The viewbox is pinned to Alexandria so "Bank Misr ATM" returns
/// the Stanley / San Stefano branch and not the one in Cairo.
///
/// Free, no API key. ~1 req/sec per IP - we keep the UI debounced
/// to stay well under the cap.
class GeocodingService {
  GeocodingService._();

  static const String _endpoint =
      'https://nominatim.openstreetmap.org/search';
  static const String _userAgent =
      'streetlore/1.0.43 (https://github.com/mohamedsabae50-prog/streetlore; admin@streetlore.app)';
  static const Duration _timeout = Duration(seconds: 8);

  /// Alexandria bounding box - (minLon, minLat, maxLon, maxLat).
  /// Anything outside this box gets dropped client-side as a
  /// last-ditch filter even though we also send `bounded=1`.
  static const double _minLon = 29.0;
  static const double _maxLon = 30.5;
  static const double _minLat = 29.5;
  static const double _maxLat = 31.5;

  /// Returns up to 5 candidates for [query]. Returns [] on any
  /// failure (network, empty, parse) - the caller decides how to
  /// surface that.
  static Future<List<GeocodingResult>> search(String query) async {
    final q = query.trim();
    if (q.length < 3) return [];
    final uri = Uri.parse(_endpoint).replace(queryParameters: {
      'q': '$q Alexandria Egypt',
      'format': 'json',
      'addressdetails': '0',
      'countrycodes': 'eg',
      'viewbox':
          '$_minLon,$_maxLat,$_maxLon,$_minLat',
      'bounded': '1',
      'limit': '5',
    });
    try {
      final res = await http
          .get(uri, headers: {
            'User-Agent': _userAgent,
            'Accept': 'application/json',
            'Accept-Language': 'en',
          })
          .timeout(_timeout);
      if (res.statusCode != 200) {
        debugPrintGeocoding(
          'Nominatim returned status ${res.statusCode} for query=$q',
        );
        return [];
      }
      final List<dynamic> list;
      try {
        list = jsonDecode(res.body) as List<dynamic>;
      } catch (e) {
        debugPrintGeocoding('Nominatim: bad JSON: $e');
        return [];
      }
      final results = <GeocodingResult>[];
      for (final j in list) {
        if (j is! Map) continue;
        final lat = double.tryParse((j['lat'] ?? '').toString());
        final lng = double.tryParse((j['lon'] ?? '').toString());
        if (lat == null || lng == null) continue;
        // Defensive last-ditch filter - should be a no-op given
        // bounded=1 but Nominatim occasionally returns a slightly
        // out-of-bbox hit for places whose centroid touches the
        // bbox edge.
        if (lat < _minLat || lat > _maxLat) continue;
        if (lng < _minLon || lng > _maxLon) continue;
        results.add(GeocodingResult(
          lat: lat,
          lng: lng,
          displayName: (j['display_name'] ?? '').toString(),
          name: (j['name'] as String?)?.toString(),
          type: (j['type'] as String?)?.toString(),
        ));
      }
      return results;
    } on TimeoutException {
      debugPrintGeocoding('Nominatim: timeout for query=$q');
      return [];
    } catch (e) {
      debugPrintGeocoding('Nominatim: exception for query=$q: $e');
      return [];
    }
  }
}

void debugPrintGeocoding(String msg) {
  // ignore: avoid_print
  print('[GeocodingService] $msg');
}
