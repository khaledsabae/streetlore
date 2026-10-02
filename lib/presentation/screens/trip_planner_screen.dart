import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../logic/trip_provider.dart';
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

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(20.0),
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
              Expanded(
                child: ReorderableListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: tripPlaces.length,
                  onReorderItem: (oldIndex, newIndex) {
                    tripProvider.reorderTrip(oldIndex, newIndex);
                  },
                  itemBuilder: (context, index) {
                    final place = tripPlaces[index];
                    return Card(
                      key: ValueKey(place.id),
                      color: context.cardColor,
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(12),
                        leading: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: CachedNetworkImage(
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
                          style: TextStyle(
                            color: context.textSec,
                            fontSize: 12,
                          ),
                        ),
                        trailing: Icon(
                          Icons.drag_handle_rounded,
                          color: context.textSec,
                        ),
                      ),
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
