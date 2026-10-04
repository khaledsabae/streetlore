import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../data/models/geofence_alert.dart';

class GeofencingService {
  GeofencingService._();
  static final GeofencingService instance = GeofencingService._();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();
  StreamSubscription<Position>? _positionSub;
  final List<GeofenceAlert> _alerts = [];
  bool _initialised = false;

  bool get isMonitoring => _positionSub != null;

  Future<void> _ensureInit() async {
    if (_initialised) return;
    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidInit);
    try {
      await _notifications.initialize(initSettings);
      _initialised = true;
    } catch (e) {
      debugPrint('GeofencingService: notifications init failed: $e');
    }
  }

  Future<bool> _ensurePermission() async {
    if (kIsWeb) return false;
    final status = await Permission.locationWhenInUse.request();
    return status.isGranted;
  }

  Future<void> setAlerts(List<GeofenceAlert> alerts) async {
    _alerts
      ..clear()
      ..addAll(alerts.where((a) => a.enabled));
    if (_alerts.isEmpty) {
      await stop();
      return;
    }
    if (_positionSub != null) return;
    final granted = await _ensurePermission();
    if (!granted) {
      debugPrint('GeofencingService: location permission denied');
      return;
    }
    await _ensureInit();
    _positionSub =
        Geolocator.getPositionStream(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.high,
            distanceFilter: 50,
          ),
        ).listen(
          _onPosition,
          onError: (e) {
            debugPrint('GeofencingService: position error: $e');
          },
        );
  }

  Future<void> stop() async {
    await _positionSub?.cancel();
    _positionSub = null;
  }

  // Places the user is currently inside of, and when each last alerted.
  // An alert fires once per entry into a radius (and at most every 5 min
  // per place), so overlapping places no longer alternate-spam.
  final Set<String> _inside = {};
  final Map<String, DateTime> _lastFireByPlace = {};

  void _onPosition(Position pos) {
    for (final a in _alerts) {
      final distance = Geolocator.distanceBetween(
        pos.latitude,
        pos.longitude,
        a.lat,
        a.lng,
      );
      if (distance <= a.radiusMeters) {
        if (_inside.add(a.placeId)) _maybeFire(a, distance);
      } else {
        _inside.remove(a.placeId);
      }
    }
  }

  void _maybeFire(GeofenceAlert a, double distance) {
    final now = DateTime.now();
    final last = _lastFireByPlace[a.placeId];
    if (last != null && now.difference(last).inMinutes < 5) return;
    _lastFireByPlace[a.placeId] = now;
    _fireNotification(a, distance);
  }

  Future<void> _fireNotification(GeofenceAlert a, double distance) async {
    try {
      await _notifications.show(
        a.placeId.hashCode,
        'You\'re near ${a.placeName}',
        'Only ${distance.toStringAsFixed(0)}m away - tap to explore.',
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'streetlore_geofence',
            'Nearby places',
            channelDescription:
                'Alerts when you approach a saved or trending place',
            importance: Importance.high,
            priority: Priority.high,
          ),
        ),
      );
    } catch (e) {
      debugPrint('GeofencingService: notification fire failed: $e');
    }
  }
}
