import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;


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


















class GeocodingService {
  GeocodingService._();

  static const String _endpoint =
      'https://nominatim.openstreetmap.org/search';
  static const String _userAgent =
      'streetlore/1.0.43 (https://github.com/mohamedsabae50-prog/streetlore; admin@streetlore.app)';
  static const Duration _timeout = Duration(seconds: 8);

  
  
  
  static const double _minLon = 29.0;
  static const double _maxLon = 30.5;
  static const double _minLat = 29.5;
  static const double _maxLat = 31.5;

  
  
  
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
  
  print('[GeocodingService] $msg');
}
