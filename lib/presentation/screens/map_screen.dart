import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

import '../../l10n/app_strings.dart';

class MapScreen extends StatefulWidget {
  final double destinationLat;
  final double destinationLng;
  final String placeName;

  const MapScreen({
    super.key,
    required this.destinationLat,
    required this.destinationLng,
    required this.placeName,
  });

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  static const double _reRouteMeters = 50.0;

  LatLng? _currentLocation;
  List<LatLng> _routePoints = [];
  bool _isLoading = true;
  String _errorMessage = '';

  StreamSubscription<Position>? _positionSub;
  final MapController _mapController = MapController();

  // Last fetched route origin so we can decide whether the user has moved
  // far enough to justify a new OSRM request.
  LatLng? _lastRouteOrigin;

  @override
  void initState() {
    super.initState();
    _initializeMap();
  }

  @override
  void dispose() {
    _positionSub?.cancel();
    _mapController.dispose();
    super.dispose();
  }

  Future<void> _initializeMap() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          if (!mounted) return;
          setState(() {
            _isLoading = false;
            _errorMessage = context.tr('map_err_location_denied');
          });
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        if (!mounted) return;
        setState(() {
          _isLoading = false;
          _errorMessage = context.tr('map_err_location_denied_forever');
        });
        return;
      }

      // Make sure location services are on at all.
      final serviceOn = await Geolocator.isLocationServiceEnabled();
      if (!serviceOn) {
        if (!mounted) return;
        setState(() {
          _isLoading = false;
          _errorMessage = context.tr('map_err_location');
        });
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      if (!mounted) return;
      _currentLocation = LatLng(position.latitude, position.longitude);
      _lastRouteOrigin = _currentLocation;

      await _getRoute();
      _centerOnUser(force: true);

      // Subscribe to subsequent updates so the blue dot walks with the user
      // and the route re-renders when they stray more than 50 m off path.
      _positionSub = Geolocator.getPositionStream(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 10,
        ),
      ).listen(_onPositionUpdate);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = context.tr('map_err_location');
      });
    }
  }

  void _onPositionUpdate(Position position) {
    if (!mounted) return;
    final newLoc = LatLng(position.latitude, position.longitude);
    setState(() => _currentLocation = newLoc);

    final driftedMeters = _lastRouteOrigin == null
        ? double.infinity
        : _distanceMeters(_lastRouteOrigin!, newLoc);
    if (driftedMeters >= _reRouteMeters) {
      _lastRouteOrigin = newLoc;
      _getRoute();
    }
    _centerOnUser();
  }

  void _centerOnUser({bool force = false}) {
    if (_currentLocation == null) return;
    try {
      _mapController.move(_currentLocation!, _mapController.camera.zoom);
    } catch (_) {
      // camera not ready yet — ignore
    }
  }

  double _distanceMeters(LatLng a, LatLng b) {
    const r = 6371000.0;
    final dLat = _deg2rad(b.latitude - a.latitude);
    final dLon = _deg2rad(b.longitude - a.longitude);
    final lat1 = _deg2rad(a.latitude);
    final lat2 = _deg2rad(b.latitude);
    final h = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(lat1) * math.cos(lat2) *
            math.sin(dLon / 2) * math.sin(dLon / 2);
    return 2 * r * math.atan2(math.sqrt(h), math.sqrt(1 - h));
  }

  double _deg2rad(double d) => d * math.pi / 180.0;

  Future<void> _getRoute() async {
    if (_currentLocation == null) return;

    final start =
        '${_currentLocation!.longitude},${_currentLocation!.latitude}';
    final end = '${widget.destinationLng},${widget.destinationLat}';

    final url = Uri.parse(
      'https://router.project-osrm.org/route/v1/driving/$start;$end?geometries=geojson&overview=full',
    );

    try {
      final response = await http
          .get(url, headers: const {'User-Agent': 'com.streetlore.app/1.0'})
          .timeout(const Duration(seconds: 12));
      if (!mounted) return;
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final routes = data['routes'] as List?;
        if (routes == null || routes.isEmpty) {
          setState(() {
            _isLoading = false;
            _errorMessage = context.tr('map_err_route');
          });
          return;
        }
        final List<dynamic> coords =
            routes[0]['geometry']['coordinates'] as List<dynamic>;
        setState(() {
          _routePoints = coords
              .map((c) => LatLng(c[1] as double, c[0] as double))
              .toList();
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
          _errorMessage = context.tr('map_err_route');
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = context.tr('map_err_offline');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Free public OSM tiles (no API key needed). Carto's basemaps.cartocdn.com
    // now requires a key, so we use the OSM standard tiles for both themes.
    // OSM attribution is rendered by FlutterMap automatically when the
    // userAgentPackageName is set on TileLayer (see below).
    final String mapTileUrl =
        'https://tile.openstreetmap.org/{z}/{x}/{y}.png';

    final destination = LatLng(widget.destinationLat, widget.destinationLng);

    return Scaffold(
      appBar: AppBar(title: Text(widget.placeName), centerTitle: true),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage.isNotEmpty && _routePoints.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      _errorMessage,
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                )
              : FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: _currentLocation ?? destination,
                    initialZoom: 14.0,
                    minZoom: 3.0,
                    maxZoom: 18.0,
                    onMapReady: () {
                      if (_currentLocation != null) {
                        _centerOnUser(force: true);
                      }
                    },
                  ),
                  children: [
                    TileLayer(
                      urlTemplate: mapTileUrl,
                      userAgentPackageName: 'com.streetlore.app',
                      subdomains: const ['a', 'b', 'c'],
                    ),

                    if (_routePoints.isNotEmpty)
                      PolylineLayer(
                        polylines: [
                          Polyline(
                            points: _routePoints,
                            color: Colors.blueAccent,
                            strokeWidth: 5.0,
                          ),
                        ],
                      ),

                    MarkerLayer(
                      markers: [
                        if (_currentLocation != null)
                          Marker(
                            point: _currentLocation!,
                            width: 32,
                            height: 32,
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.blueAccent,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white,
                                  width: 3,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.3),
                                    blurRadius: 6,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.navigation,
                                color: Colors.white,
                                size: 14,
                              ),
                            ),
                          ),
                        Marker(
                          point: destination,
                          width: 40,
                          height: 40,
                          child: const Icon(
                            Icons.location_on,
                            color: Colors.red,
                            size: 40,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
    );
  }
}