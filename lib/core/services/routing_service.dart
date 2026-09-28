import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';










class RoutingService {
  RoutingService._();
  static final RoutingService instance = RoutingService._();

  static const _endpoint =
      'https://router.project-osrm.org/route/v1/driving';

  
  
  Future<List<LatLng>?> getRoute(List<LatLng> points) async {
    if (points.length < 2) return null;
    final coords = points
        .map((p) => '${p.longitude},${p.latitude}')
        .join(';');
    final uri = Uri.parse(
      '$_endpoint/$coords?overview=full&geometries=geojson&steps=false',
    );
    try {
      final res = await http.get(uri).timeout(const Duration(seconds: 12));
      if (res.statusCode != 200) return null;
      final body = jsonDecode(res.body) as Map<String, dynamic>;
      final routes = body['routes'] as List?;
      if (routes == null || routes.isEmpty) return null;
      final coords2 =
          (routes.first as Map<String, dynamic>)['geometry']
              as Map<String, dynamic>;
      final coordinates = coords2['coordinates'] as List?;
      if (coordinates == null) return null;
      return coordinates
          .map((c) {
            final pair = c as List;
            
            return LatLng((pair[1] as num).toDouble(),
                (pair[0] as num).toDouble());
          })
          .toList(growable: false);
    } on TimeoutException {
      return null;
    } catch (_) {
      return null;
    }
  }

  
  
  Future<RouteMetrics?> getMetrics(List<LatLng> points) async {
    if (points.length < 2) return null;
    final coords = points
        .map((p) => '${p.longitude},${p.latitude}')
        .join(';');
    final uri = Uri.parse(
      '$_endpoint/$coords?overview=false&alternatives=false&steps=false',
    );
    try {
      final res = await http.get(uri).timeout(const Duration(seconds: 10));
      if (res.statusCode != 200) return null;
      final body = jsonDecode(res.body) as Map<String, dynamic>;
      final routes = body['routes'] as List?;
      if (routes == null || routes.isEmpty) return null;
      final r = routes.first as Map<String, dynamic>;
      return RouteMetrics(
        distanceMeters: (r['distance'] as num?)?.toDouble() ?? 0,
        durationSeconds: (r['duration'] as num?)?.toDouble() ?? 0,
      );
    } catch (_) {
      return null;
    }
  }
}

class RouteMetrics {
  final double distanceMeters;
  final double durationSeconds;
  const RouteMetrics({
    required this.distanceMeters,
    required this.durationSeconds,
  });

  String get distanceKm =>
      distanceMeters >= 1000
          ? '${(distanceMeters / 1000).toStringAsFixed(1)} km'
          : '${distanceMeters.round()} m';

  String get durationText {
    final totalMin = (durationSeconds / 60).round();
    if (totalMin < 60) return '$totalMin min';
    final h = totalMin ~/ 60;
    final m = totalMin % 60;
    return m == 0 ? '$h h' : '$h h $m min';
  }
}
