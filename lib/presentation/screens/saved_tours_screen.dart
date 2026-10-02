import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/animations/app_animations.dart';
import '../../core/constants/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../logic/place_provider.dart';
import '../../logic/tour_provider.dart';
import '../../l10n/app_strings.dart';
import '../widgets/place_card.dart';
import '../widgets/tour_card.dart';
import 'place_details_screen.dart';
import 'tour_details_screen.dart';

class SavedToursScreen extends StatefulWidget {
  const SavedToursScreen({super.key});

  @override
  State<SavedToursScreen> createState() => _SavedToursScreenState();
}

class _SavedToursScreenState extends State<SavedToursScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabCtrl;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.bgColor,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        context.tr('saved_collection'),
                        style: TextStyle(fontSize: 12, color: context.textSec),
                      ),
                      Text(
                        context.tr('saved_title'),
                        style: AppTextStyles.screenTitle.copyWith(
                          color: context.textPri,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
              child: Container(
                height: 44,
                decoration: BoxDecoration(
                  color: context.cardColor,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(
                    color: context.textSec.withValues(alpha: 0.15),
                  ),
                ),
                child: TabBar(
                  controller: _tabCtrl,
                  indicator: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(22),
                  ),
                  indicatorPadding: const EdgeInsets.all(3),
                  indicatorSize: TabBarIndicatorSize.tab,
                  dividerColor: Colors.transparent,
                  labelColor: Colors.white,
                  unselectedLabelColor: context.textSec,
                  labelStyle: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                  unselectedLabelStyle: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 13,
                  ),
                  tabs: [
                    Tab(text: context.tr('tab_places')),
                    Tab(text: context.tr('tab_tours')),
                  ],
                ),
              ),
            ),
            Expanded(
              child: TabBarView(
                controller: _tabCtrl,
                physics: const BouncingScrollPhysics(),
                children: const [_SavedPlacesTab(), _SavedToursTab()],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SavedPlacesTab extends StatelessWidget {
  const _SavedPlacesTab();

  @override
  Widget build(BuildContext context) {
    return Consumer<PlaceProvider>(
      builder: (context, placeProvider, _) {
        final places = placeProvider.savedPlaces;

        if (places.isEmpty) {
          return _EmptyState(
            icon: Icons.bookmark_outline_rounded,
            title: context.tr('no_saved_places'),
            subtitle: context.tr('empty_saved_places_sub'),
            actionLabel: context.tr('discover_places'),
            onAction: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(context.tr('switch_explore'))),
              );
            },
          );
        }

        return CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        gradient: AppColors.primaryGradient,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        context.tr('saved_count', {'n': '${places.length}'}),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      context.tr('swipe_remove_hint'),
                      style: TextStyle(color: context.textSec, fontSize: 12),
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: () =>
                          _showClearPlacesDialog(context, placeProvider),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.error.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.delete_outline_rounded,
                              size: 14,
                              color: AppColors.error,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              context.tr('clear'),
                              style: TextStyle(
                                color: AppColors.error,
                                fontWeight: FontWeight.w700,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SliverList(
              delegate: SliverChildBuilderDelegate((context, index) {
                final place = places[index];
                return Dismissible(
                  key: Key('saved_place_${place.id}'),
                  direction: DismissDirection.endToStart,
                  background: _deleteBackground(context),
                  onDismissed: (_) {
                    placeProvider.toggleSave(place);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          context.tr('removed_from_saved', {
                            'name': place.localizedName(
                              Localizations.localeOf(context).languageCode,
                            ),
                          }),
                        ),
                        action: SnackBarAction(
                          label: context.tr('undo'),
                          textColor: AppColors.ratingGold,
                          onPressed: () => placeProvider.toggleSave(place),
                        ),
                      ),
                    );
                  },
                  child: PlaceCard(
                    place: place,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => PlaceDetailsScreen(place: place),
                        ),
                      );
                    },
                  ),
                );
              }, childCount: places.length),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 24)),
          ],
        );
      },
    );
  }

  void _showClearPlacesDialog(BuildContext context, PlaceProvider provider) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: ctx.cardColor,
        title: Text(
          context.tr('clear_all_title'),
          textAlign: TextAlign.center,
          style: TextStyle(
            fontWeight: FontWeight.w800,
            color: ctx.textPri,
            fontSize: 18,
          ),
        ),
        content: Text(
          context.tr('clear_all_warning'),
          textAlign: TextAlign.center,
          style: TextStyle(color: ctx.textSec, fontSize: 14, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(context.tr('cancel')),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () {
              provider.clearAllSaved();
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(context.tr('saved_cleared')),
                  backgroundColor: AppColors.error,
                ),
              );
            },
            child: Text(
              context.tr('clear'),
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}

class _SavedToursTab extends StatelessWidget {
  const _SavedToursTab();

  @override
  Widget build(BuildContext context) {
    return Consumer<TourProvider>(
      builder: (context, tourProvider, _) {
        final tours = tourProvider.savedTours;

        if (tours.isEmpty) {
          return _EmptyState(
            icon: Icons.map_outlined,
            title: context.tr('no_saved_tours'),
            subtitle: context.tr('empty_saved_tours_sub'),
            actionLabel: context.tr('browse_tours'),
            onAction: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(context.tr('switch_tours'))),
              );
            },
          );
        }

        return ListView.builder(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.only(top: 8),
          itemCount: tours.length,
          itemBuilder: (context, i) {
            final tour = tours[i];
            return FadeInUp(
              delay: Duration(milliseconds: 80 * i + 200),
              offsetY: 24,
              child: TourCard(
                tour: tour,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => TourDetailsScreen(tour: tour),
                    ),
                  );
                },
              ),
            );
          },
        );
      },
    );
  }
}

class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String actionLabel;
  final VoidCallback onAction;

  const _EmptyState({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.actionLabel,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.primary.withValues(alpha: 0.08),
                    AppColors.accent.withValues(alpha: 0.06),
                  ],
                ),
              ),
              child: Icon(icon, size: 54, color: context.textPri),
            ),
            const SizedBox(height: 28),
            Text(
              title,
              style: AppTextStyles.displayMedium.copyWith(
                fontSize: 22,
                color: context.textPri,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMedium,
            ),
            const SizedBox(height: 36),
            Container(
              width: double.infinity,
              height: 54,
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.35),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: onAction,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.explore_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(actionLabel, style: AppTextStyles.buttonText),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Widget _deleteBackground(BuildContext context) => Container(
  margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 7),
  decoration: BoxDecoration(
    gradient: const LinearGradient(
      colors: [Color(0xFFEF4444), Color(0xFFDC2626)],
    ),
    borderRadius: BorderRadius.circular(20),
  ),
  alignment: AlignmentDirectional.centerEnd,
  padding: const EdgeInsetsDirectional.only(end: 24),
  child: Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      const Icon(Icons.delete_rounded, color: Colors.white, size: 28),
      const SizedBox(height: 4),
      Text(
        context.tr('remove'),
        style: const TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    ],
  ),
);
