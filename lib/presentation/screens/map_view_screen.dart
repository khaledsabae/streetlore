import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../data/models/map_poi.dart';
import '../../data/models/map_seed.dart';
import '../../data/models/place_model.dart';
import '../../l10n/app_strings.dart';
import '../../logic/place_provider.dart';
import '_atm_sheet.dart';
import 'place_details_screen.dart';

String _catLabel(BuildContext context, String cat) {
  switch (cat) {
    case 'All':
      return context.tr('cat_all');
    case 'Historical':
      return context.tr('cat_historical');
    case 'Culture':
      return context.tr('cat_culture');
    case 'Nature':
      return context.tr('cat_nature');
    case 'Food':
      return context.tr('cat_food');
    case 'Shopping':
      return context.tr('cat_shopping');
    case 'Mosques':
      return context.tr('cat_mosques');
    case 'Churches':
      return context.tr('cat_churches');
    case 'Hotels':
      return context.tr('cat_hotels');
    default:
      return cat;
  }
}

class MapViewScreen extends StatefulWidget {
  const MapViewScreen({super.key});

  @override
  State<MapViewScreen> createState() => _MapViewScreenState();
}

class _MapViewScreenState extends State<MapViewScreen> {
  final MapController _mapController = MapController();
  
  
  
  
  String? _selectedCategory;
  PlaceModel? _selectedPlace;
  LatLng? _userLocation;
  bool _initialCentered = false;
  
  
  bool _showAtms = false;
  
  final Set<String> _extraLayers = <String>{};

  static const _alexCenter = LatLng(31.2001, 29.9187);
  static const _hotelsCategory = 'Hotels';
  static const String _allOffSentinel = '__none__';

  bool get _allOff => _selectedCategory == _allOffSentinel;

  Future<void> _locateUser({bool move = false}) async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return;
      }
      final pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.medium,
      );
      if (!mounted) return;
      final here = LatLng(pos.latitude, pos.longitude);
      setState(() => _userLocation = here);
      if (move || !_initialCentered) {
        _initialCentered = true;
        _mapController.move(here, 13.5);
      }
    } catch (_) {}
  }

  
  void _showAtmSheet(BuildContext context, MapPoi atm) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: context.cardColor,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (ctx) => AtmSheet(atm: atm),
    );
  }

  IconData _iconForCategory(String category) {
    switch (category) {
      case 'Historical':
        return Icons.account_balance_rounded;
      case 'Culture':
        return Icons.museum_rounded;
      case 'Nature':
        return Icons.park_rounded;
      case 'Food':
        return Icons.restaurant_rounded;
      case 'Shopping':
        return Icons.shopping_bag_rounded;
      case 'Mosques':
        return Icons.mosque_rounded;
      case 'Churches':
        return Icons.church_rounded;
      case 'Hotels':
        
        
        return Icons.bed_rounded;
      default:
        return Icons.location_on_rounded;
    }
  }

  Color _colorForCategory(String category) {
    switch (category) {
      case 'Historical':
        return const Color(0xFF8B5CF6);
      case 'Culture':
        return const Color(0xFFEC4899);
      case 'Nature':
        return const Color(0xFF10B981);
      case 'Food':
        return const Color(0xFFF59E0B);
      case 'Shopping':
        return const Color(0xFF3B82F6);
      case 'Mosques':
        return const Color(0xFF14B8A6);
      case 'Churches':
        return const Color(0xFFF97316);
      case 'Hotels':
        return const Color(0xFF6A1B9A); 
      default:
        return AppColors.primary;
    }
  }

  
  
  
  
  List<PlaceModel> _filtered(List<PlaceModel> all) {
    
    
    if (_showAtms) return const <PlaceModel>[];
    if (_showHotels) {
      return all.where((p) => p.category == 'Hotels').toList();
    }
    if (_allOff) return const <PlaceModel>[];
    if (_selectedCategory == null) return all;
    return all.where((p) => p.category == _selectedCategory).toList();
  }

  bool get _showHotels => _extraLayers.contains(_hotelsCategory);

  @override
  Widget build(BuildContext context) {
    final places = context.watch<PlaceProvider>().places;
    final visible = _filtered(places);

    return Scaffold(
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _alexCenter,
              initialZoom: 12,
              minZoom: 5,
              maxZoom: 18,
              onMapReady: () => _locateUser(),
              onTap: (_, __) => setState(() => _selectedPlace = null),
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.streetlore.app',
                maxZoom: 19,
              ),
              MarkerLayer(
                markers: [
                  if (_userLocation != null)
                    Marker(
                      point: _userLocation!,
                      width: 26,
                      height: 26,
                      child: Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFF3B82F6),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 3),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(
                                0xFF3B82F6,
                              ).withValues(alpha: 0.5),
                              blurRadius: 10,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                      ),
                    ),
                  for (final p in visible)
                    Marker(
                      point: LatLng(p.lat, p.lng),
                      width: 44,
                      height: 44,
                      child: GestureDetector(
                        onTap: () {
                          setState(() => _selectedPlace = p);
                          _mapController.move(LatLng(p.lat, p.lng), 14);
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: _colorForCategory(p.category),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: _colorForCategory(
                                  p.category,
                                ).withValues(alpha: 0.5),
                                blurRadius: 8,
                                spreadRadius: 2,
                              ),
                            ],
                            border: Border.all(color: Colors.white, width: 3),
                          ),
                          child: Icon(
                            _iconForCategory(p.category),
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                  if (_showAtms)
                    for (final atm in getSeedAtms())
                      Marker(
                        point: LatLng(atm.lat, atm.lng),
                        width: 40,
                        height: 40,
                        child: GestureDetector(
                          onTap: () {
                            setState(() => _selectedPlace = null);
                            _showAtmSheet(context, atm);
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: atm.color,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: atm.color.withValues(alpha: 0.5),
                                  blurRadius: 8,
                                ),
                              ],
                              border: Border.all(
                                color: Colors.white,
                                width: 2.5,
                              ),
                            ),
                            child: Icon(
                              atm.icon,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                      ),
                  if (_showHotels)
                    for (final hotel in getSeedHotels())
                      Marker(
                        point: LatLng(hotel.lat, hotel.lng),
                        width: 44,
                        height: 44,
                        child: GestureDetector(
                          
                          
                          
                          
                          
                          
                          onTap: () {
                            final match = places.firstWhere(
                              (p) => p.id == hotel.id,
                              orElse: () => PlaceModel(
                                id: hotel.id,
                                name: hotel.name,
                                description: hotel.address,
                                imageUrl: '',
                                rating: 5.0,
                                category: 'Hotels',
                                lat: hotel.lat,
                                lng: hotel.lng,
                                address: hotel.address,
                                openHours: '',
                              ),
                            );
                            setState(() {
                              _selectedPlace = match;
                            });
                            _mapController.move(
                              LatLng(hotel.lat, hotel.lng),
                              14,
                            );
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: hotel.color,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: hotel.color.withValues(alpha: 0.5),
                                  blurRadius: 8,
                                ),
                              ],
                              border: Border.all(
                                color: Colors.white,
                                width: 3,
                              ),
                            ),
                            child: Icon(
                              hotel.icon,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                      ),
                ],
              ),
            ],
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Row(
                children: [
                  IconButton.filled(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back_ios_rounded, size: 18),
                    style: IconButton.styleFrom(
                      backgroundColor: context.cardColor,
                      foregroundColor: context.textPri,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: context.cardColor,
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Text(
                        context.tr('map_title', {'n': '${visible.length}'}),
                        style: TextStyle(
                          color: context.textPri,
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (_selectedPlace != null)
            Positioned(
              left: 16,
              right: 16,
              bottom: 16,
              child: _SelectedPlaceCard(
                place: _selectedPlace!,
                color: _colorForCategory(_selectedPlace!.category),
                icon: _iconForCategory(_selectedPlace!.category),
                onClose: () => setState(() => _selectedPlace = null),
                onOpen: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          PlaceDetailsScreen(place: _selectedPlace!),
                    ),
                  );
                },
              ),
            ),
          Positioned(
            right: 16,
            bottom: _selectedPlace != null ? 170 : 72,
            child: FloatingActionButton.small(
              heroTag: 'locate-fab',
              tooltip: context.tr('map_my_location'),
              onPressed: () => _locateUser(move: true),
              backgroundColor: Theme.of(context).cardColor,
              child: Icon(
                Icons.my_location_rounded,
                size: 20,
                color: context.textPri,
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: _selectedPlace != null ? 110 : 16,
            child: _CategoryFilter(
              selected: _selectedCategory,
              onSelect: (cat) => setState(() => _selectedCategory = cat),
              colorOf: _colorForCategory,
              iconOf: _iconForCategory,
              extraLayers: const {'Hotels'},
              activeLayers: _extraLayers,
              onToggleExtraLayer: (layer) {
                setState(() {
                  if (_extraLayers.contains(layer)) {
                    _extraLayers.remove(layer);
                    
                    
                    
                    if (layer == _hotelsCategory &&
                        _selectedCategory == _hotelsCategory) {
                      _selectedCategory = null;
                    }
                  } else {
                    _extraLayers.add(layer);
                    
                    
                    
                    
                    
                    
                    
                    
                    
                  }
                });
              },
              showAtms: _showAtms,
              onToggleAtms: () =>
                  setState(() => _showAtms = !_showAtms),
            ),
          ),
        ],
      ),
    );
  }
}

class _SelectedPlaceCard extends StatelessWidget {
  final PlaceModel place;
  final Color color;
  final IconData icon;
  final VoidCallback onClose;
  final VoidCallback onOpen;

  const _SelectedPlaceCard({
    required this.place,
    required this.color,
    required this.icon,
    required this.onClose,
    required this.onOpen,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  place.name,
                  style: TextStyle(
                    color: context.textPri,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Text(
                      _catLabel(context, place.category),
                      style: TextStyle(
                        color: color,
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(
                      Icons.star_rounded,
                      size: 12,
                      color: Color(0xFFFBBF24),
                    ),
                    const SizedBox(width: 2),
                    Text(
                      place.rating.toString(),
                      style: TextStyle(
                        color: context.textPri,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: onOpen,
            icon: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
            color: color,
            tooltip: context.tr('map_open_details'),
          ),
          IconButton(
            onPressed: onClose,
            icon: const Icon(Icons.close_rounded, size: 18),
            color: context.hintColor,
            tooltip: context.tr('map_close'),
          ),
        ],
      ),
    );
  }
}

class _CategoryFilter extends StatelessWidget {
  final String? selected;
  final ValueChanged<String?> onSelect;
  final Color Function(String) colorOf;
  final IconData Function(String) iconOf;
  
  final Set<String> extraLayers;
  final Set<String> activeLayers;
  final ValueChanged<String> onToggleExtraLayer;
  final bool showAtms;
  final VoidCallback onToggleAtms;

  const _CategoryFilter({
    required this.selected,
    required this.onSelect,
    required this.colorOf,
    required this.iconOf,
    required this.extraLayers,
    required this.activeLayers,
    required this.onToggleExtraLayer,
    required this.showAtms,
    required this.onToggleAtms,
  });

  @override
  Widget build(BuildContext context) {
    
    const cats = [
      'All',
      'Historical',
      'Culture',
      'Nature',
      'Food',
      'Mosques',
      'Churches',
    ];
    final children = <Widget>[];

    for (final cat in cats) {
      final isAll = cat == 'All';
      
      
      
      final allOn = selected == null;
      final isSel = isAll ? allOn : cat == selected;
      final color = isAll ? AppColors.primary : colorOf(cat);
      children.add(
        Padding(
          padding: const EdgeInsets.only(right: 8),
          child: FilterChip(
            selected: isSel,
            onSelected: (_) {
              if (isAll) {
                
                
                
                
                final currentlyAll = selected == null;
                onSelect(currentlyAll ? '__none__' : null);
              } else {
                
                
                if (cat == selected) {
                  onSelect('__none__');
                } else {
                  onSelect(cat);
                }
              }
            },
            avatar: Icon(
              isAll ? Icons.apps_rounded : iconOf(cat),
              size: 16,
              color: isSel ? Colors.white : color,
            ),
            label: Text(
              _catLabel(context, cat),
              style: TextStyle(
                color: isSel ? Colors.white : context.textPri,
                fontWeight: FontWeight.w800,
                fontSize: 12,
              ),
            ),
            backgroundColor: context.cardColor,
            selectedColor: color,
            checkmarkColor: Colors.white,
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: BorderSide(
                color: isSel ? color : context.cardColor,
                width: 1.5,
              ),
            ),
          ),
        ),
      );
    }

    
    children.add(
      Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        width: 1,
        color: context.hintColor.withValues(alpha: 0.3),
      ),
    );

    
    const hotelsey = 'Hotels';
    final isHotels = activeLayers.contains(hotelsey);
    children.add(
      Padding(
        padding: const EdgeInsets.only(right: 8),
        child: FilterChip(
          selected: isHotels,
          onSelected: (_) => onToggleExtraLayer(hotelsey),
          avatar: Icon(
            Icons.hotel_rounded,
            size: 16,
            color: isHotels ? Colors.white : const Color(0xFF6A1B9A),
          ),
          label: Text(
            'Hotels',
            style: TextStyle(
              color: isHotels ? Colors.white : context.textPri,
              fontWeight: FontWeight.w800,
              fontSize: 12,
            ),
          ),
          backgroundColor: context.cardColor,
          selectedColor: const Color(0xFF6A1B9A),
          checkmarkColor: Colors.white,
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(
              color: isHotels
                  ? const Color(0xFF6A1B9A)
                  : context.cardColor,
              width: 1.5,
            ),
          ),
        ),
      ),
    );

    
    children.add(
      Padding(
        padding: const EdgeInsets.only(right: 8),
        child: FilterChip(
          selected: showAtms,
          onSelected: (_) => onToggleAtms(),
          avatar: Icon(
            Icons.atm_rounded,
            size: 16,
            color: showAtms ? Colors.white : const Color(0xFF10B981),
          ),
          label: Text(
            'ATMs',
            style: TextStyle(
              color: showAtms ? Colors.white : context.textPri,
              fontWeight: FontWeight.w800,
              fontSize: 12,
            ),
          ),
          backgroundColor: context.cardColor,
          selectedColor: const Color(0xFF10B981),
          checkmarkColor: Colors.white,
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(
              color: showAtms
                  ? const Color(0xFF10B981)
                  : context.cardColor,
              width: 1.5,
            ),
          ),
        ),
      ),
    );

    return SizedBox(
      height: 44,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        physics: const BouncingScrollPhysics(),
        children: children,
      ),
    );
  }
}
