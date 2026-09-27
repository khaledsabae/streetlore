import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import '../core/services/geofencing_service.dart';
import '../data/models/geofence_alert.dart';

class GeofenceProvider extends ChangeNotifier {
  static const _kKey = 'geofence_alerts_v1';
  final List<GeofenceAlert> _alerts = [];
  bool _monitoring = false;

  List<GeofenceAlert> get alerts => List.unmodifiable(_alerts);
  bool get isMonitoring => _monitoring;

  GeofenceProvider() {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_kKey) ?? const [];
    _alerts
      ..clear()
      ..addAll(
        raw.map(
          (s) => GeofenceAlert.fromJson(
            Map<String, dynamic>.from(jsonDecode(s) as Map),
          ),
        ),
      );
    notifyListeners();
    // Re-arm the background tracking service with whatever alerts
    // persisted from the previous session. Without this, the position
    // stream would only resume when the user manually re-opens the
    // Geofencing settings screen.
    await _syncService();
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      _kKey,
      _alerts.map((a) => jsonEncode(a.toJson())).toList(),
    );
  }

  Future<void> toggle(GeofenceAlert alert) async {
    final i = _alerts.indexWhere((a) => a.placeId == alert.placeId);
    if (i == -1) {
      _alerts.add(alert);
    } else {
      _alerts[i] = _alerts[i].copyWith(enabled: !_alerts[i].enabled);
    }
    await _save();
    await _syncService();
    notifyListeners();
  }

  Future<void> remove(String placeId) async {
    _alerts.removeWhere((a) => a.placeId == placeId);
    await _save();
    await _syncService();
    notifyListeners();
  }

  Future<void> updateRadius(String placeId, int radius) async {
    final i = _alerts.indexWhere((a) => a.placeId == placeId);
    if (i == -1) return;
    _alerts[i] = _alerts[i].copyWith(radiusMeters: radius);
    await _save();
    await _syncService();
    notifyListeners();
  }

  Future<void> startMonitoring() async {
    // v1.0.39: when the master "Monitoring your location" toggle is
    // flipped ON, default-enable every persisted alert so the user
    // doesn't have to opt in to every place one by one. Without
    // this the master toggle could be ON while every individual
    // place remained OFF (the persisted `enabled` flag from a
    // previous session was preserved).
    for (var i = 0; i < _alerts.length; i++) {
      if (!_alerts[i].enabled) {
        _alerts[i] = _alerts[i].copyWith(enabled: true);
      }
    }
    await _save();
    await _syncService();
    _monitoring = true;
    notifyListeners();
  }

  Future<void> stopMonitoring() async {
    await GeofencingService.instance.stop();
    _monitoring = false;
    notifyListeners();
  }

  Future<void> _syncService() async {
    await GeofencingService.instance.setAlerts(_alerts);
    _monitoring = GeofencingService.instance.isMonitoring;
  }
}
