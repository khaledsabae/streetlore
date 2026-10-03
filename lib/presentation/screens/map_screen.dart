import 'dart:convert';
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
  LatLng? _currentLocation;
  List<LatLng> _routePoints = [];
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _initializeMap();
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

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      _currentLocation = LatLng(position.latitude, position.longitude);

      await _getRoute();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = context.tr('map_err_location');
      });
    }
  }

  Future<void> _getRoute() async {
    if (_currentLocation == null) return;

    final start =
        '${_currentLocation!.longitude},${_currentLocation!.latitude}';
    final end = '${widget.destinationLng},${widget.destinationLat}';

    final url = Uri.parse(
      'https://router.project-osrm.org/route/v1/driving/$start;$end?geometries=geojson',
    );

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> coords =
            data['routes'][0]['geometry']['coordinates'];

        setState(() {
          _routePoints = coords
              .map((c) => LatLng(c[1] as double, c[0] as double))
              .toList();
          _isLoading = false;
        });
      } else {
        if (!mounted) return;
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
          : _errorMessage.isNotEmpty
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
              options: MapOptions(
                initialCenter: _currentLocation ?? destination,
                initialZoom: 14.0,
              ),
              children: [
                TileLayer(
                  urlTemplate: mapTileUrl,
                  userAgentPackageName: 'com.example.streetlore',

                  subdomains: const ['a', 'b', 'c', 'd'],
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
                        child: const Icon(
                          Icons.my_location,
                          color: Colors.blue,
                          size: 30,
                        ),
                      ),
                    Marker(
                      point: destination,
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
