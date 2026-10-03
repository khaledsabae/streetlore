import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../logic/trip_provider.dart';
import '../../data/models/place_model.dart';
import '../../core/constants/app_colors.dart';
import '../../l10n/app_strings.dart';

class TripPlannerScreen extends StatelessWidget {
  const TripPlannerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.bgColor,
      appBar: AppBar(
        title: Text(
          context.tr('trip_title'),
          style: TextStyle(color: context.textPri, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: context.textPri),
      ),
      body: Consumer<TripProvider>(
        builder: (context, tripProvider, child) {
          final tripPlaces = tripProvider.tripPlaces;

          if (tripPlaces.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.map_outlined, size: 80, color: context.hintColor),
                  const SizedBox(height: 16),
                  Text(
                    context.tr('trip_empty'),
                    textAlign: TextAlign.center,
                    style: TextStyle(color: context.textSec, fontSize: 16),
                  ),
                ],
              ),
            );
          }

          final visited =
              tripPlaces.where((p) => tripProvider.isVisited(p.id)).toList();
          final planned = tripPlaces
              .where((p) => !tripProvider.isVisited(p.id))
              .toList();

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      context.tr('trip_places_planned', {
                        'n': '${tripPlaces.length}',
                      }),
                      style: TextStyle(
                        color: context.textPri,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextButton.icon(
                      onPressed: () => tripProvider.clearTrip(),
                      icon: const Icon(
                        Icons.delete_sweep,
                        color: AppColors.error,
                      ),
                      label: Text(
                        context.tr('trip_clear_all'),
                        style: const TextStyle(color: AppColors.error),
                      ),
                    ),
                  ],
                ),
              ),
              if (visited.isNotEmpty)
                _SectionHeader(
                  label: context.tr('trip_visited'),
                  count: visited.length,
                  color: AppColors.success,
                  icon: Icons.check_circle_rounded,
                ),
              if (planned.isNotEmpty)
                _SectionHeader(
                  label: context.tr('trip_planned'),
                  count: planned.length,
                  color: AppColors.primary,
                  icon: Icons.bookmark_outline_rounded,
                ),
              Expanded(
                child: ReorderableListView.builder(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                  itemCount: tripPlaces.length,
                  onReorderItem: (oldIndex, newIndex) {
                    tripProvider.reorderTrip(oldIndex, newIndex);
                  },
                  itemBuilder: (context, index) {
                    final place = tripPlaces[index];
                    final wasVisited = tripProvider.isVisited(place.id);
                    return _TripCard(
                      key: ValueKey(place.id),
                      place: place,
                      isVisited: wasVisited,
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String label;
  final int count;
  final Color color;
  final IconData icon;
  const _SectionHeader({
    required this.label,
    required this.count,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 4),
      child: Row(
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 6),
          Text(
            '$label ($count)',
            style: TextStyle(
              color: context.textPri,
              fontSize: 14,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _TripCard extends StatelessWidget {
  final PlaceModel place;
  final bool isVisited;
  const _TripCard({super.key, required this.place, required this.isVisited});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Card(
            color: context.cardColor,
            margin: EdgeInsets.zero,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: isVisited
                  ? const BorderSide(color: AppColors.success, width: 2)
                  : BorderSide.none,
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.all(12),
              leading: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Stack(
                  children: [
                    CachedNetworkImage(
                      imageUrl: place.imageUrl,
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                      memCacheWidth: 120,
                      memCacheHeight: 120,
                      httpHeaders: const {
                        'User-Agent':
                            'Mozilla/5.0 (iPhone; CPU iPhone OS 17_0 like Mac OS X) AppleWebKit/605.1.15',
                      },
                      placeholder: (_, __) => Container(
                        width: 60,
                        height: 60,
                        color: context.bgAlt,
                      ),
                      errorWidget: (context, url, error) => Container(
                        width: 60,
                        height: 60,
                        color: const Color(0xFF1C2433),
                        child: const Icon(
                          Icons.image_rounded,
                          color: Colors.white30,
                          size: 36,
                        ),
                      ),
                    ),
                    if (isVisited)
                      Positioned.fill(
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.45),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.check_rounded,
                            color: Colors.white,
                            size: 30,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              title: Text(
                place.localizedName(
                  Localizations.localeOf(context).languageCode,
                ),
                style: TextStyle(
                  color: context.textPri,
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Text(
                place.category,
                style: TextStyle(color: context.textSec, fontSize: 12),
              ),
              trailing: Icon(
                Icons.drag_handle_rounded,
                color: context.textSec,
              ),
            ),
          ),
          if (isVisited)
            Positioned(
              top: -8,
              right: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppColors.success,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  context.tr('trip_visited_badge'),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
