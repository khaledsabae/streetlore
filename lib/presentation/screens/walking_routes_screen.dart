import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/services/routing_service.dart';
import '../../data/models/place_model.dart';
import '../../logic/place_provider.dart';
import '../../l10n/app_strings.dart';

class WalkingRoutesScreen extends StatefulWidget {
  const WalkingRoutesScreen({super.key});

  @override
  State<WalkingRoutesScreen> createState() => _WalkingRoutesScreenState();
}

class _WalkingRoutesScreenState extends State<WalkingRoutesScreen> {
  final List<PlaceModel> _selected = [];
  static const _alexCenter = LatLng(31.2001, 29.9187);
  final MapController _mapController = MapController();

  
  List<LatLng> _routePoints = const [];
  
  RouteMetrics? _routeMetrics;
  bool _routeLoading = false;

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  
  
  Future<void> _refreshRoute() async {
    if (_selected.length < 2) {
      setState(() {
        _routePoints = const [];
        _routeMetrics = null;
      });
      return;
    }
    setState(() => _routeLoading = true);
    final coords = _selected.map((p) => LatLng(p.lat, p.lng)).toList();
    final route = await RoutingService.instance.getRoute(coords);
    final metrics = await RoutingService.instance.getMetrics(coords);
    if (!mounted) return;
    setState(() {
      _routeLoading = false;
      if (route == null) {
        _routePoints = const [];
      } else {
        _routePoints = route;
      }
      _routeMetrics = metrics;
    });
  }

  double _haversineKm(LatLng a, LatLng b) {
    const r = 6371.0;
    final dLat = _toRad(b.latitude - a.latitude);
    final dLng = _toRad(b.longitude - a.longitude);
    final h =
        sin(dLat / 2) * sin(dLat / 2) +
        cos(_toRad(a.latitude)) *
            cos(_toRad(b.latitude)) *
            sin(dLng / 2) *
            sin(dLng / 2);
    return 2 * r * asin(min(1, sqrt(h)));
  }

  double _toRad(double deg) => deg * (pi / 180.0);

  double get _totalDistanceKm {
    if (_selected.length < 2) return 0;
    double total = 0;
    for (var i = 0; i < _selected.length - 1; i++) {
      total += _haversineKm(
        LatLng(_selected[i].lat, _selected[i].lng),
        LatLng(_selected[i + 1].lat, _selected[i + 1].lng),
      );
    }
    return total;
  }

  int get _walkingMinutes {
    final km = _totalDistanceKm;
    return (km * 13).round();
  }

  void _togglePlace(PlaceModel p) {
    setState(() {
      final idx = _selected.indexWhere((s) => s.id == p.id);
      if (idx >= 0) {
        _selected.removeAt(idx);
      } else if (_selected.length < 5) {
        _selected.add(p);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(context.tr('max_route_places')),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    });
    _refreshRoute();
    if (_selected.isNotEmpty) {
      Future.delayed(const Duration(milliseconds: 200), () {
        if (!mounted) return;
        final last = _selected.last;
        _mapController.move(LatLng(last.lat, last.lng), 13);
      });
    }
  }

  void _autoSortByNearest() {
    if (_selected.length < 2) return;
    setState(() {
      final start = _selected.first;
      final remaining = _selected.sublist(1).toList();
      remaining.sort((a, b) {
        final da = _haversineKm(
          LatLng(start.lat, start.lng),
          LatLng(a.lat, a.lng),
        );
        final db = _haversineKm(
          LatLng(start.lat, start.lng),
          LatLng(b.lat, b.lng),
        );
        return da.compareTo(db);
      });
      _selected
        ..clear()
        ..add(start)
        ..addAll(remaining);
    });
  }

  void _clear() {
    setState(() => _selected.clear());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.bgColor,
      appBar: AppBar(
        title: const Text(
          'Walking Route',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        centerTitle: true,
        backgroundColor: context.bgColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: context.textPri),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          if (_selected.isNotEmpty)
            TextButton(
              onPressed: _clear,
              child: Text(
                'Clear',
                style: TextStyle(
                  color: context.textPri,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            flex: 5,
            child: Consumer<PlaceProvider>(
              builder: (context, placeP, _) {
                return Stack(
                  children: [
                    FlutterMap(
                      mapController: _mapController,
                      options: const MapOptions(
                        initialCenter: _alexCenter,
                        initialZoom: 12,
                      ),
                      children: [
                        TileLayer(
                          urlTemplate:
                              'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                          userAgentPackageName: 'com.streetlore.app',
                          maxZoom: 19,
                        ),
                        if (_selected.length >= 2)
                          PolylineLayer(
                            polylines: [
                              Polyline(
                                points: _routePoints.isNotEmpty
                                    ? _routePoints
                                    : _selected
                                        .map((p) => LatLng(p.lat, p.lng))
                                        .toList(),
                                color: _routePoints.isNotEmpty
                                    ? const Color(0xFF14B8A6)
                                    : const Color(0xFFEC4899),
                                strokeWidth: 4,
                                borderColor: Colors.white,
                                borderStrokeWidth: 2,
                              ),
                            ],
                          ),
                        MarkerLayer(
                          markers: [
                            for (var i = 0; i < _selected.length; i++)
                              Marker(
                                point: LatLng(
                                  _selected[i].lat,
                                  _selected[i].lng,
                                ),
                                width: 36,
                                height: 36,
                                child: Container(
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [
                                        Color(0xFFEC4899),
                                        Color(0xFF8B5CF6),
                                      ],
                                    ),
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Colors.white,
                                      width: 2.5,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color(
                                          0xFFEC4899,
                                        ).withValues(alpha: 0.4),
                                        blurRadius: 8,
                                        offset: const Offset(0, 3),
                                      ),
                                    ],
                                  ),
                                  child: Center(
                                    child: Text(
                                      '${i + 1}',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w900,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                    if (_selected.length >= 2)
                      Positioned(
                        left: 16,
                        right: 16,
                        top: 16,
                        child: _RouteSummary(
                          distanceKm: _totalDistanceKm,
                          minutes: _walkingMinutes,
                          stopCount: _selected.length,
                          onAutoSort: _autoSortByNearest,
                          realMetrics: _routeMetrics,
                          routeLoading: _routeLoading,
                        ),
                      ),
                  ],
                );
              },
            ),
          ),
          Expanded(
            flex: 4,
            child: _PlaceSelector(selected: _selected, onToggle: _togglePlace),
          ),
        ],
      ),
    );
  }
}

class _RouteSummary extends StatelessWidget {
  final double distanceKm;
  final int minutes;
  final int stopCount;
  final VoidCallback onAutoSort;
  final RouteMetrics? realMetrics;
  final bool routeLoading;

  const _RouteSummary({
    required this.distanceKm,
    required this.minutes,
    required this.stopCount,
    required this.onAutoSort,
    this.realMetrics,
    this.routeLoading = false,
  });

  String _formatTime(int mins) {
    if (mins < 60) return '$mins min';
    final h = mins ~/ 60;
    final m = mins % 60;
    return '${h}h ${m}m';
  }

  @override
  Widget build(BuildContext context) {
    final hasRealRoute = realMetrics != null;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: hasRealRoute
              ? const [Color(0xFF14B8A6), Color(0xFF0EA5E9)]
              : const [Color(0xFFEC4899), Color(0xFF8B5CF6)],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: (hasRealRoute
                    ? const Color(0xFF14B8A6)
                    : const Color(0xFFEC4899))
                .withValues(alpha: 0.35),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.22),
              borderRadius: BorderRadius.circular(12),
            ),
            child: routeLoading
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      valueColor:
                          AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Icon(
                    Icons.directions_walk_rounded,
                    color: Colors.white,
                    size: 22,
                  ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '$stopCount stops',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.85),
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
                  ),
                ),
                Text(
                  hasRealRoute
                      ? '${realMetrics!.distanceKm} · ${realMetrics!.durationText}'
                      : '${distanceKm.toStringAsFixed(1)} km · ${_formatTime(minutes)}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.auto_fix_high_rounded, color: Colors.white),
            onPressed: onAutoSort,
            tooltip: 'Optimize order',
          ),
        ],
      ),
    );
  }
}

class _PlaceSelector extends StatelessWidget {
  final List<PlaceModel> selected;
  final ValueChanged<PlaceModel> onToggle;

  const _PlaceSelector({required this.selected, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    return Consumer<PlaceProvider>(
      builder: (context, placeP, _) {
        final all = placeP.places;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: Row(
                children: [
                  Text(
                    'Pick places',
                    style: TextStyle(
                      color: context.textPri,
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${selected.length} / 5',
                    style: TextStyle(
                      color: context.textSec,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: all.length,
                itemBuilder: (context, i) {
                  final p = all[i];
                  final isSelected = selected.any((s) => s.id == p.id);
                  final orderIdx = isSelected
                      ? selected.indexWhere((s) => s.id == p.id) + 1
                      : 0;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(14),
                        onTap: () => onToggle(p),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.primary.withValues(alpha: 0.12)
                                : context.cardColor,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: isSelected
                                  ? AppColors.primary
                                  : context.textSec.withValues(alpha: 0.12),
                              width: isSelected ? 1.5 : 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(
                                  gradient: isSelected
                                      ? const LinearGradient(
                                          colors: [
                                            Color(0xFFEC4899),
                                            Color(0xFF8B5CF6),
                                          ],
                                        )
                                      : null,
                                  color: isSelected ? null : context.bgAlt,
                                  shape: BoxShape.circle,
                                ),
                                child: Center(
                                  child: isSelected
                                      ? Text(
                                          '$orderIdx',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 14,
                                            fontWeight: FontWeight.w900,
                                          ),
                                        )
                                      : Icon(
                                          Icons.add_rounded,
                                          color: context.textSec,
                                          size: 18,
                                        ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      p.localizedName(
                                        Localizations.localeOf(context)
                                            .languageCode,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        color: context.textPri,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    Text(
                                      p.category,
                                      style: TextStyle(
                                        color: context.textSec,
                                        fontSize: 11,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Icon(
                                isSelected
                                    ? Icons.check_circle_rounded
                                    : Icons.radio_button_unchecked_rounded,
                                color: isSelected
                                    ? AppColors.primary
                                    : context.textSec,
                                size: 20,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}
