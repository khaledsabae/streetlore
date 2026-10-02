import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../data/models/itinerary_model.dart';
import '../../l10n/app_strings.dart';
import '../../logic/auth_provider.dart';
import '../../logic/tour_provider.dart';
import '../widgets/place_card.dart';
import 'map_screen.dart';
import 'place_details_screen.dart';

class TourDetailsScreen extends StatefulWidget {
  final ItineraryModel tour;

  const TourDetailsScreen({super.key, required this.tour});

  @override
  State<TourDetailsScreen> createState() => _TourDetailsScreenState();
}

class _TourDetailsScreenState extends State<TourDetailsScreen>
    with TickerProviderStateMixin {
  late final AnimationController _contentController;
  late final Animation<double> _contentFade;
  late final Animation<Offset> _contentSlide;

  @override
  void initState() {
    super.initState();
    _contentController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..forward();
    _contentFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _contentController, curve: Curves.easeIn),
    );
    _contentSlide =
        Tween<Offset>(begin: const Offset(0, 0.12), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _contentController,
            curve: Curves.easeOutCubic,
          ),
        );
  }

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _startNavigation() async {
    final tour = widget.tour;
    if (tour.places.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.tr('tour_no_locations'))),
        );
      }
      return;
    }
    final firstPlace = tour.places.first;
    if (!mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MapScreen(
          destinationLat: firstPlace.lat,
          destinationLng: firstPlace.lng,
          placeName: firstPlace.localizedName(
            Localizations.localeOf(context).languageCode,
          ),
        ),
      ),
    );
  }

  Future<void> _toggleVisited() async {
    final tour = widget.tour;
    final tourProvider = context.read<TourProvider>();
    final userId = context.read<AuthProvider>().userId;
    final wasVisited = tourProvider.isTourVisited(tour.id);

    HapticFeedback.mediumImpact();
    if (wasVisited) {
      await tourProvider.unmarkTourVisited(tour.id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.tr('tour_visit_unmarked'))),
      );
      return;
    }

    final messenger = ScaffoldMessenger.of(context);
    final ok = await tourProvider.markTourVisited(tour, userId);
    if (!mounted) return;
    if (ok.ok) {
      messenger.showSnackBar(
        SnackBar(content: Text(context.tr('tour_visit_recorded'))),
      );
    } else {
      messenger.showSnackBar(
        SnackBar(content: Text(context.tr('tour_visit_offline'))),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final tour = widget.tour;

    return Scaffold(
      backgroundColor: context.bgColor,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: _GlassButton(
            icon: Icons.arrow_back_ios_new_rounded,
            onTap: () => Navigator.pop(context),
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Consumer<TourProvider>(
              builder: (context, tourProvider, child) {
                final isSaved = tourProvider.isSaved(tour.id);
                return _GlassButton(
                  icon: isSaved
                      ? Icons.offline_pin_rounded
                      : Icons.download_for_offline_outlined,
                  iconColor: isSaved ? AppColors.ratingGold : Colors.white,
                  onTap: () {
                    HapticFeedback.mediumImpact();
                    tourProvider.toggleTourSaved(tour);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          isSaved
                              ? context.tr('tour_removed_offline')
                              : context.tr('tour_saved_offline'),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            automaticallyImplyLeading: false,
            expandedHeight: 300,
            pinned: false,
            backgroundColor: AppColors.primary,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Hero(
                    tag: 'tour-image-${tour.id}',
                    flightShuttleBuilder:
                        (
                          BuildContext flightContext,
                          Animation<double> animation,
                          HeroFlightDirection flightDirection,
                          BuildContext fromHeroContext,
                          BuildContext toHeroContext,
                        ) {
                          return Material(
                            color: Colors.transparent,
                            child: (toHeroContext.widget as Hero).child,
                          );
                        },
                    child: CachedNetworkImage(
                      imageUrl: tour.imageUrl,
                      fit: BoxFit.cover,
                      memCacheWidth: 1080,
                      memCacheHeight: 1080,
                      httpHeaders: const {
                        'User-Agent':
                            'Mozilla/5.0 (iPhone; CPU iPhone OS 17_0 like Mac OS X) AppleWebKit/605.1.15',
                      },
                      placeholder: (_, __) =>
                          Container(color: AppColors.primaryLight),
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
                  Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Color(0x880F172A),
                          Color(0xEE0F172A),
                        ],
                        stops: [0.4, 0.7, 1.0],
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 20,
                    left: 20,
                    right: 20,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.3),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.access_time_rounded,
                                    color: Colors.white,
                                    size: 11,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    tour.duration,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Hero(
                          tag: 'tour-title-${tour.id}',
                          flightShuttleBuilder:
                              (
                                BuildContext flightContext,
                                Animation<double> animation,
                                HeroFlightDirection flightDirection,
                                BuildContext fromHeroContext,
                                BuildContext toHeroContext,
                              ) {
                                return DefaultTextStyle(
                                  style: DefaultTextStyle.of(
                                    toHeroContext,
                                  ).style,
                                  child: (toHeroContext.widget as Hero).child,
                                );
                              },
                          child: Material(
                            type: MaterialType.transparency,
                            child: Text(
                              tour.title,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 26,
                                fontWeight: FontWeight.w800,
                                height: 1.1,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(
                              Icons.location_on_rounded,
                              color: Colors.white60,
                              size: 14,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              context.tr('tour_stops_along', {
                                'n': '${tour.places.length}',
                              }),
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: FadeTransition(
              opacity: _contentFade,
              child: SlideTransition(
                position: _contentSlide,
                child: Container(
                  decoration: BoxDecoration(
                    color: context.bgColor,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(28),
                    ),
                  ),
                  transform: Matrix4.translationValues(0, -28, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(24, 28, 24, 0),
                        child: Row(
                          children: [
                            Expanded(
                              child: _StatCard(
                                icon: Icons.access_time_rounded,
                                label: context.tr('tour_duration'),
                                value: tour.duration,
                                color: AppColors.primary,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _StatCard(
                                icon: Icons.location_on_rounded,
                                label: context.tr('tour_stops'),
                                value: '${tour.places.length}',
                                color: AppColors.accent,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _StatCard(
                                icon: Icons.lock_open_rounded,
                                label: context.tr('tour_access'),
                                value: context.tr('tour_free'),
                                color: AppColors.success,
                              ),
                            ),
                          ],
                        ),
                      ),

                      Padding(
                        padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              context.tr('tour_about'),
                              style: AppTextStyles.sectionTitle.copyWith(
                                color: context.textPri,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              tour.description,
                              style: AppTextStyles.bodyMedium,
                            ),
                          ],
                        ),
                      ),

                      if (tour.places.isNotEmpty) ...[
                        Padding(
                          padding: const EdgeInsets.fromLTRB(24, 28, 24, 12),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                context.tr('tour_itinerary'),
                                style: AppTextStyles.sectionTitle.copyWith(
                                  color: context.textPri,
                                ),
                              ),
                              Text(
                                context.tr('tour_stops_count', {
                                  'n': '${tour.places.length}',
                                }),
                                style: TextStyle(
                                  color: context.textSec,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                        ...tour.places.asMap().entries.map((entry) {
                          final index = entry.key;
                          final place = entry.value;
                          return Stack(
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(left: 28),
                                child: PlaceCard(
                                  place: place,
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            PlaceDetailsScreen(place: place),
                                      ),
                                    );
                                  },
                                ),
                              ),
                              Positioned(
                                left: 8,
                                top: 0,
                                bottom: 0,
                                child: Align(
                                  alignment: Alignment.centerLeft,
                                  child: Container(
                                    width: 24,
                                    height: 24,
                                    decoration: BoxDecoration(
                                      color: AppColors.primary,
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: Colors.white,
                                        width: 2,
                                      ),
                                    ),
                                    child: Center(
                                      child: Text(
                                        '${index + 1}',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 10,
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          );
                        }),
                      ],

                      Padding(
                        padding: const EdgeInsets.fromLTRB(24, 28, 24, 16),
                        child: _buildStartButton(),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
                        child: _buildVisitedButton(),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStartButton() {
    return GestureDetector(
      onTap: _startNavigation,
      child: Container(
        width: double.infinity,
        height: 56,
        decoration: BoxDecoration(
          gradient: AppColors.primaryGradient,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.4),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.navigation_rounded, color: Colors.white, size: 22),
            const SizedBox(width: 10),
            Text(context.tr('tour_start_nav'), style: AppTextStyles.buttonText),
          ],
        ),
      ),
    );
  }

  Widget _buildVisitedButton() {
    return Consumer<TourProvider>(
      builder: (context, tourProvider, _) {
        final visited = tourProvider.isTourVisited(widget.tour.id);
        final color = visited
            ? AppColors.success
            : AppColors.primary.withValues(alpha: 0.6);
        final iconData = visited
            ? Icons.check_circle_rounded
            : Icons.radio_button_unchecked_rounded;
        final label = visited
            ? context.tr('tour_visited')
            : context.tr('tour_mark_visited');

        return GestureDetector(
          onTap: _toggleVisited,
          child: Container(
            width: double.infinity,
            height: 52,
            decoration: BoxDecoration(
              color: visited
                  ? color.withValues(alpha: 0.18)
                  : Colors.white.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: visited
                    ? color
                    : Colors.white.withValues(alpha: 0.18),
                width: visited ? 1.5 : 1.0,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(iconData, color: color, size: 22),
                const SizedBox(width: 10),
                Text(
                  label,
                  style: AppTextStyles.buttonText.copyWith(
                    color: color,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _GlassButton extends StatelessWidget {
  final IconData icon;
  final Color? iconColor;
  final VoidCallback onTap;

  const _GlassButton({required this.icon, this.iconColor, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.35),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
        ),
        child: Icon(icon, color: iconColor ?? Colors.white, size: 20),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: context.textPri,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: context.textSec,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
