import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';

/// Calculates the great-circle bearing from a user position to the
/// Kaaba in Mecca (21.4225° N, 39.8262° E) and exposes it as a
/// broadcast [Stream] so widgets can re-render as the user moves.
class QiblaService {
  QiblaService._();

  static final QiblaService instance = QiblaService._();

  /// Kaaba coordinates (Masjid al-Haram, Mecca).
  static const double _kaabaLatDeg = 21.4225;
  static const double _kaabaLngDeg = 39.8262;

  final _controller = StreamController<double>.broadcast();
  Stream<double> get bearingStream => _controller.stream;
  double _lastBearingDeg = 0;
  bool _hasBearing = false;

  double get lastBearingDeg => _lastBearingDeg;
  bool get hasBearing => _hasBearing;

  /// Compute the initial bearing (forward azimuth) from [userLatDeg]/
  /// [userLngDeg] to Mecca using the standard great-circle formula.
  /// Result is normalised to [0, 360).
  double bearingFrom({
    required double userLatDeg,
    required double userLngDeg,
  }) {
    final lat1 = _deg2rad(userLatDeg);
    final lat2 = _deg2rad(_kaabaLatDeg);
    final dLng = _deg2rad(_kaabaLngDeg - userLngDeg);

    final y = math.sin(dLng) * math.cos(lat2);
    final x = math.cos(lat1) * math.sin(lat2) -
        math.sin(lat1) * math.cos(lat2) * math.cos(dLng);
    final bearingRad = math.atan2(y, x);
    final bearingDeg = _rad2deg(bearingRad);
    final normalised = (bearingDeg + 360) % 360;
    _lastBearingDeg = normalised;
    _hasBearing = true;
    if (!_controller.isClosed) {
      _controller.add(normalised);
    }
    return normalised;
  }

  /// Resolve current location (with permission) and emit a fresh bearing.
  /// Falls back to the cached bearing if permission is denied or the
  /// location lookup fails.
  Future<double> refreshFromCurrentLocation() async {
    try {
      LocationPermission perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) {
        perm = await Geolocator.requestPermission();
      }
      if (perm == LocationPermission.denied ||
          perm == LocationPermission.deniedForever) {
        return _lastBearingDeg;
      }
      final pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.medium,
      ).timeout(const Duration(seconds: 8));
      return bearingFrom(
        userLatDeg: pos.latitude,
        userLngDeg: pos.longitude,
      );
    } catch (e) {
      debugPrint('QiblaService.refreshFromCurrentLocation failed: $e');
      return _lastBearingDeg;
    }
  }

  /// Distance to Mecca in kilometres (great-circle).
  double distanceFrom({
    required double userLatDeg,
    required double userLngDeg,
  }) {
    final dLat = _deg2rad(_kaabaLatDeg - userLatDeg);
    final dLng = _deg2rad(_kaabaLngDeg - userLngDeg);
    final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_deg2rad(userLatDeg)) *
            math.cos(_deg2rad(_kaabaLatDeg)) *
            math.sin(dLng / 2) *
            math.sin(dLng / 2);
    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return 6371.0 * c; // Earth radius in km
  }

  double _deg2rad(double d) => d * math.pi / 180.0;
  double _rad2deg(double r) => r * 180.0 / math.pi;
}