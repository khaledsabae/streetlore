import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/animated_icons.dart';
import '../../data/models/geofence_alert.dart';
import '../../data/models/place_model.dart';
import '../../l10n/app_strings.dart';
import '../../logic/geofence_provider.dart';
import '../../logic/place_provider.dart';

class GeofencingSettingsScreen extends StatelessWidget {
  const GeofencingSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.bgColor,
      appBar: AppBar(title: Text(context.tr('geo_title'))),
      body: Consumer<GeofenceProvider>(
        builder: (context, geo, _) {
          final places = context.watch<PlaceProvider>().places;
          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            physics: const BouncingScrollPhysics(),
            children: [
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFF59E0B), Color(0xFFFB923C)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    const SizedBox(
                      width: 56,
                      height: 56,
                      child: Padding(
                        padding: EdgeInsets.all(2),
                        child: AnimatedLottieIcon(
                          animation: LottieAnimations.radar,
                          size: 52,
                          color: Colors.white,
                          secondaryColor: Color(0xFFFCD34D),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            context.tr('geo_hero_title'),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            context.tr('geo_hero_sub'),
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              _MonitoringTile(
                isMonitoring: geo.isMonitoring,
                onChanged: (v) async {
                  if (v) {
                    
                    
                    
                    
                    
                    
                    
                    
                    await geo.startMonitoring();
                    for (final place in places) {
                      final existing = geo.alerts.firstWhere(
                        (a) => a.placeId == place.id,
                        orElse: () => GeofenceAlert(
                          placeId: place.id,
                          placeName: place.localizedName(
                            Localizations.localeOf(context).languageCode,
                          ),
                          lat: place.lat,
                          lng: place.lng,
                        ),
                      );
                      
                      
                      
                      
                      
                      
                      if (!existing.enabled) {
                        await geo.toggle(existing);
                      }
                    }
                  } else {
                    await geo.stopMonitoring();
                  }
                },
              ),
              const SizedBox(height: 20),
              Text(
                context.tr('geo_choose_places'),
                style: AppTextStyles.sectionTitle.copyWith(
                  color: context.textPri,
                ),
              ),
              const SizedBox(height: 8),
              for (final place in places)
                _PlaceToggle(
                  place: place,
                  enabled: geo.alerts.any(
                    (a) => a.placeId == place.id && a.enabled,
                  ),
                  onToggle: () {
                    final existing = geo.alerts.firstWhere(
                      (a) => a.placeId == place.id,
                      orElse: () => GeofenceAlert(
                        placeId: place.id,
                        placeName: place.localizedName(
                          Localizations.localeOf(context).languageCode,
                        ),
                        lat: place.lat,
                        lng: place.lng,
                      ),
                    );
                    geo.toggle(existing);
                  },
                ),
            ],
          );
        },
      ),
    );
  }
}

class _MonitoringTile extends StatelessWidget {
  final bool isMonitoring;
  final ValueChanged<bool> onChanged;
  const _MonitoringTile({required this.isMonitoring, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: context.hintColor.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(
            isMonitoring ? Icons.gps_fixed : Icons.gps_off,
            color: isMonitoring ? AppColors.success : context.textSec,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              isMonitoring
                  ? context.tr('geo_monitoring_on')
                  : context.tr('geo_monitoring_off'),
            ),
          ),
          Switch.adaptive(
            value: isMonitoring,
            onChanged: onChanged,
            activeThumbColor: AppColors.success,
          ),
        ],
      ),
    );
  }
}

class _PlaceToggle extends StatelessWidget {
  final PlaceModel place;
  final bool enabled;
  final VoidCallback onToggle;
  const _PlaceToggle({
    required this.place,
    required this.enabled,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: enabled
              ? AppColors.success.withValues(alpha: 0.4)
              : context.hintColor.withValues(alpha: 0.3),
        ),
      ),
      child: InkWell(
        onTap: onToggle,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: CachedNetworkImage(
                  imageUrl: place.imageUrl,
                  width: 50,
                  height: 50,
                  fit: BoxFit.cover,
                  memCacheWidth: 100,
                  memCacheHeight: 100,
                  httpHeaders: const {
                    'User-Agent':
                        'Mozilla/5.0 (iPhone; CPU iPhone OS 17_0 like Mac OS X) AppleWebKit/605.1.15',
                  },
                  placeholder: (_, __) =>
                      Container(width: 50, height: 50, color: context.bgAlt),
                  errorWidget: (context, url, error) => Container(
                    color: const Color(0xFF1C2433),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.image_rounded,
                          color: Colors.white30,
                          size: 36,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      place.localizedName(
                        Localizations.localeOf(context).languageCode,
                      ),
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      context.tr('geo_distance', {
                        'd': Geolocator.distanceBetween(
                          0,
                          0,
                          place.lat,
                          place.lng,
                        ).toStringAsFixed(0),
                      }),
                      style: TextStyle(color: context.textSec, fontSize: 11),
                    ),
                  ],
                ),
              ),
              Switch.adaptive(
                value: enabled,
                onChanged: (_) => onToggle(),
                activeThumbColor: AppColors.success,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
