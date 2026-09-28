import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/animations/app_animations.dart';
import '../../core/constants/app_colors.dart';
import '../../core/widgets/app_image.dart';
import '../../core/widgets/confetti_overlay.dart';
import '../../core/widgets/shimmer_image.dart';
import '../../data/mock_data.dart';
import '../../data/models/place_model.dart';
import '../../logic/auth_provider.dart';
import '../../logic/place_provider.dart';
import '../../logic/review_provider.dart';
import '../../logic/streak_provider.dart';
import '../../logic/locale_provider.dart';
import '../../logic/offline_provider.dart';
import '../../data/models/review_model.dart';
import '../../l10n/app_strings.dart';
import '../widgets/add_review_sheet.dart';
import '../widgets/place_photos_section.dart';
import 'ai_tour_guide_screen.dart';
import 'live_chat_screen.dart';
import 'map_screen.dart';

class PlaceDetailsScreen extends StatefulWidget {
  final PlaceModel place;
  const PlaceDetailsScreen({super.key, required this.place});

  @override
  State<PlaceDetailsScreen> createState() => _PlaceDetailsScreenState();
}

class _PlaceDetailsScreenState extends State<PlaceDetailsScreen>
    with TickerProviderStateMixin {
  late final AnimationController _contentCtrl;
  late final Animation<double> _contentFade;
  late final Animation<Offset> _contentSlide;
  final ConfettiController _confetti = ConfettiController();

  bool _isVisited = false;
  final List<PlaceModel> _nearby = [];

  @override
  void initState() {
    super.initState();
    _contentCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..forward();
    _contentFade = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _contentCtrl, curve: Curves.easeIn));
    _contentSlide =
        Tween<Offset>(begin: const Offset(0, 0.12), end: Offset.zero).animate(
          CurvedAnimation(parent: _contentCtrl, curve: Curves.easeOutCubic),
        );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refreshNearby();
      
      
      
      
      _loadCheckinState();
    });
  }

  
  
  
  
  
  
  Future<void> _loadCheckinState() async {
    if (!mounted) return;
    final userId =
        Supabase.instance.client.auth.currentUser?.id ?? '';
    if (userId.isEmpty) return;
    try {
      final res = await Supabase.instance.client
          .from('place_checkins')
          .select('place_id')
          .eq('user_id', userId)
          .eq('place_id', widget.place.id)
          .limit(1);
      if (!mounted) return;
      final checked = res.isNotEmpty;
      if (checked && !_isVisited) {
        setState(() => _isVisited = true);
        debugPrint(
          'place_details _loadCheckinState: place ${widget.place.id} '
          'already checked in for user $userId - _isVisited=true',
        );
      } else if (!checked && _isVisited) {
        
        
        setState(() => _isVisited = false);
      }
    } catch (e) {
      debugPrint(
        'place_details _loadCheckinState: '
        'failed to query place_checkins: $e',
      );
    }
  }

  void _refreshNearby() {
    if (!mounted) return;
    final allPlaces = context.read<PlaceProvider>().places;
    final current = widget.place;
    setState(() {
      _nearby
        ..clear()
        ..addAll(
          allPlaces
              .where(
                (p) =>
                    p.id != current.id &&
                    (p.lat - current.lat).abs() < 0.05 &&
                    (p.lng - current.lng).abs() < 0.05,
              )
              .take(4),
        );
    });
  }

  @override
  void dispose() {
    _contentCtrl.dispose();
    super.dispose();
  }

  bool get _isOpen => MockData.isOpenNow(widget.place.openHours);

  void _openMaps() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MapScreen(
          destinationLat: widget.place.lat,
          destinationLng: widget.place.lng,
          placeName: widget.place.localizedName(
            context.read<LocaleProvider>().locale.languageCode,
          ),
        ),
      ),
    );
  }

  void _showShareSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _ShareSheet(place: widget.place),
    );
  }

  @override
  Widget build(BuildContext context) {
    final place = widget.place;
    final theme = Theme.of(context);
    final scaffoldBgColor = theme.scaffoldBackgroundColor;
    final textPri = theme.textTheme.bodyLarge?.color ?? Colors.black;
    final textSec = theme.textTheme.bodyMedium?.color ?? Colors.grey;

    return Scaffold(
      backgroundColor: scaffoldBgColor,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(8),
          child: _GlassBtn(
            icon: Icons.arrow_back_ios_new_rounded,
            onTap: () => Navigator.pop(context),
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Consumer<PlaceProvider>(
              builder: (context, pp, _) {
                final saved = pp.isSaved(place.id);
                return _GlassBtn(
                  icon: saved
                      ? Icons.bookmark_rounded
                      : Icons.bookmark_border_rounded,
                  iconColor: saved ? AppColors.ratingGold : Colors.white,
                  onTap: () {
                    HapticFeedback.mediumImpact();
                    pp.toggleSave(place);
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 14),
            child: _GlassBtn(icon: Icons.share_rounded, onTap: _showShareSheet),
          ),
        ],
      ),
      body: Stack(
        children: [
          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverAppBar(
                automaticallyImplyLeading: false,
                expandedHeight: 320,
                pinned: false,
                backgroundColor: AppColors.primary,
                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      Hero(
                        tag: 'place-image-${place.id}',
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
                        child: ShimmerImage(
                          imageUrl: place.imageUrl,
                          fit: BoxFit.cover,
                          fallbackIcon: Icons.broken_image_rounded,
                          fallbackColor: Colors.white38,
                          fallbackIconSize: 60,
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
                        top: 100,
                        right: 16,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.5),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: _isOpen
                                  ? AppColors.success.withValues(alpha: 0.6)
                                  : AppColors.error.withValues(alpha: 0.6),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 7,
                                height: 7,
                                decoration: BoxDecoration(
                                  color: _isOpen
                                      ? AppColors.success
                                      : AppColors.error,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 5),
                              Text(
                                _isOpen
                                    ? context.tr('open_now')
                                    : context.tr('closed'),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 20,
                        left: 20,
                        right: 80,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Hero(
                              tag: 'place-category-${place.id}',
                              flightShuttleBuilder:
                                  (
                                    BuildContext flightContext,
                                    Animation<double> animation,
                                    HeroFlightDirection flightDirection,
                                    BuildContext fromHeroContext,
                                    BuildContext toHeroContext,
                                  ) {
                                    return Material(
                                      type: MaterialType.transparency,
                                      child:
                                          (toHeroContext.widget as Hero).child,
                                    );
                                  },
                              child: Material(
                                type: MaterialType.transparency,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.accent.withValues(
                                      alpha: 0.9,
                                    ),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    place
                                        .localizedCategory(
                                          context
                                              .read<LocaleProvider>()
                                              .locale
                                              .languageCode,
                                        )
                                        .toUpperCase(),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: 1,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Hero(
                              tag: 'place-name-${place.id}',
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
                                      child:
                                          (toHeroContext.widget as Hero).child,
                                    );
                                  },
                              child: Material(
                                type: MaterialType.transparency,
                                child: Text(
                                  place.localizedName(
                                    context
                                        .read<LocaleProvider>()
                                        .locale
                                        .languageCode,
                                  ),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 26,
                                    fontWeight: FontWeight.w800,
                                    height: 1.1,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Positioned(
                        bottom: 20,
                        right: 20,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.3),
                            ),
                          ),
                          child: Column(
                            children: [
                              const Icon(
                                Icons.star_rounded,
                                color: AppColors.ratingGold,
                                size: 20,
                              ),
                              Text(
                                place.rating.toStringAsFixed(1),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 16,
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
              SliverToBoxAdapter(
                child: FadeTransition(
                  opacity: _contentFade,
                  child: SlideTransition(
                    position: _contentSlide,
                    child: Container(
                      decoration: BoxDecoration(
                        color: scaffoldBgColor,
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(28),
                        ),
                      ),
                      transform: Matrix4.translationValues(0, -28, 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.fromLTRB(24, 40, 24, 0),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Consumer<PlaceProvider>(
                                    builder: (context, pp, _) {
                                      final saved = pp.isSaved(place.id);
                                      return _QuickAction(
                                        icon: saved
                                            ? Icons.bookmark_rounded
                                            : Icons.bookmark_border_rounded,
                                        label: saved
                                            ? context.tr('saved')
                                            : context.tr('save'),
                                        color: saved
                                            ? AppColors.ratingGold
                                            : AppColors.primary,
                                        onTap: () {
                                          HapticFeedback.lightImpact();
                                          pp.toggleSave(place);
                                        },
                                      );
                                    },
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: _QuickAction(
                                    icon: _isVisited
                                        ? Icons.check_circle_rounded
                                        : Icons.flag_outlined,
                                    label: _isVisited
                                        ? context.tr('visited')
                                        : context.tr('checkin'),
                                    color: AppColors.success,
                                    onTap: () async {
                                      HapticFeedback.mediumImpact();
                                      final wasVisited = _isVisited;
                                      if (!wasVisited) {
                                        
                                        
                                        
                                        
                                        
                                        
                                        
                                        
                                        
                                        
                                        
                                        
                                        
                                        
                                        
                                        
                                        
                                        
                                        
                                        final streak = context
                                            .read<StreakProvider>();
                                        final placeProvider = context
                                            .read<PlaceProvider>();
                                        final messenger = ScaffoldMessenger.of(
                                          context,
                                        );
                                        final userId = Supabase.instance
                                            .client.auth
                                            .currentUser
                                            ?.id;
                                        if (userId == null ||
                                            userId.isEmpty) {
                                          if (!context.mounted) return;
                                          messenger.showSnackBar(
                                            SnackBar(
                                              content: const Text(
                                                'Please sign in to '
                                                'check in.',
                                              ),
                                              backgroundColor: Colors.red,
                                            ),
                                          );
                                          return;
                                        }
                                        
                                        
                                        
                                        final newStreak = await streak
                                            .registerVisit();
                                        setState(
                                          () => _isVisited = true,
                                        );
                                        try {
                                          
                                          
                                          
                                          
                                          
                                          
                                          
                                          
                                          
                                          
                                          
                                          
                                          
                                          
                                          
                                          
                                          
                                          await Supabase.instance.client
                                              .from('place_checkins')
                                              .upsert({
                                            'user_id': userId,
                                            'place_id': place.id,
                                          }, onConflict: 'user_id, place_id')
                                              .select();
                                          
                                          
                                          
                                          
                                          
                                          
                                          
                                          
                                          
                                          placeProvider
                                              .fetchRemoteCounts(userId);
                                          if (!context.mounted) return;
                                          messenger.showSnackBar(
                                            SnackBar(
                                              content: Row(
                                                children: [
                                                  const Icon(
                                                    Icons
                                                        .local_fire_department_rounded,
                                                    color: Colors.white,
                                                    size: 18,
                                                  ),
                                                  const SizedBox(width: 8),
                                                  Expanded(
                                                    child: Text(
                                                      context.tr(
                                                        'checked_in_streak',
                                                        {'n': '$newStreak'},
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              backgroundColor:
                                                  AppColors.success,
                                              duration: const Duration(
                                                seconds: 3,
                                              ),
                                            ),
                                          );
                                          return;
                                        } on PostgrestException catch (e) {
                                          
                                          
                                          
                                          
                                          
                                          if (!context.mounted) return;
                                          setState(
                                            () => _isVisited = false,
                                          );
                                          messenger.showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                'Check-in failed: '
                                                '[${e.code ?? ""}] '
                                                '${e.message}',
                                              ),
                                              backgroundColor: Colors.red,
                                              duration: const Duration(
                                                seconds: 6,
                                              ),
                                            ),
                                          );
                                          return;
                                        } catch (e) {
                                          
                                          
                                          if (!context.mounted) return;
                                          setState(
                                            () => _isVisited = false,
                                          );
                                          messenger.showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                'Check-in failed: '
                                                '$e',
                                              ),
                                              backgroundColor: Colors.red,
                                              duration: const Duration(
                                                seconds: 6,
                                              ),
                                            ),
                                          );
                                          return;
                                        }
                                      } else {
                                        
                                        
                                        
                                        
                                        
                                        
                                        
                                        
                                        
                                        
                                        
                                        
                                        
                                        
                                        final placeProvider = context
                                            .read<PlaceProvider>();
                                        final messenger = ScaffoldMessenger.of(
                                          context,
                                        );
                                        final userId = Supabase.instance
                                            .client.auth
                                            .currentUser
                                            ?.id;
                                        if (userId == null ||
                                            userId.isEmpty) {
                                          if (!context.mounted) return;
                                          messenger.showSnackBar(
                                            SnackBar(
                                              content: const Text(
                                                'Please sign in to '
                                                'remove check-in.',
                                              ),
                                              backgroundColor: Colors.red,
                                            ),
                                          );
                                          return;
                                        }
                                        
                                        
                                        setState(
                                          () => _isVisited = false,
                                        );
                                        try {
                                          await Supabase.instance.client
                                              .from('place_checkins')
                                              .delete()
                                              .eq('user_id', userId)
                                              .eq('place_id', place.id);
                                          
                                          
                                          
                                          
                                          
                                          
                                          placeProvider
                                              .fetchRemoteCounts(userId);
                                          if (!context.mounted) return;
                                          messenger.showSnackBar(
                                            SnackBar(
                                              content: Row(
                                                children: [
                                                  const Icon(
                                                    Icons
                                                        .cancel_rounded,
                                                    color: Colors.white,
                                                    size: 18,
                                                  ),
                                                  const SizedBox(width: 8),
                                                  Text(
                                                    context.tr(
                                                      'checkin_removed',
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              backgroundColor:
                                                  AppColors.success,
                                              duration: const Duration(
                                                seconds: 2,
                                              ),
                                            ),
                                          );
                                        } on PostgrestException catch (e) {
                                          
                                          
                                          
                                          if (!context.mounted) return;
                                          setState(
                                            () => _isVisited = true,
                                          );
                                          messenger.showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                'Could not remove '
                                                'check-in: '
                                                '[${e.code ?? ""}] '
                                                '${e.message}',
                                              ),
                                              backgroundColor: Colors.red,
                                              duration: const Duration(
                                                seconds: 6,
                                              ),
                                            ),
                                          );
                                        } catch (e) {
                                          if (!context.mounted) return;
                                          setState(
                                            () => _isVisited = true,
                                          );
                                          messenger.showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                'Could not remove '
                                                'check-in: $e',
                                              ),
                                              backgroundColor: Colors.red,
                                              duration: const Duration(
                                                seconds: 6,
                                              ),
                                            ),
                                          );
                                        }
                                      }
                                    },
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: _QuickAction(
                                    icon: Icons.directions_rounded,
                                    label: context.tr('go'),
                                    color: AppColors.primary,
                                    onTap: _openMaps,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Consumer<OfflineProvider>(
                                    builder: (context, offline, _) {
                                      final cached = offline.isCached(
                                        place.id,
                                      );
                                      return _QuickAction(
                                        icon: cached
                                            ? Icons.cloud_done_rounded
                                            : Icons.cloud_download_outlined,
                                        label: cached
                                            ? context.tr(
                                                'downloaded',
                                              )
                                            : context.tr('download_offline'),
                                        color: cached
                                            ? const Color(0xFF10B981)
                                            : const Color(0xFF7C3AED),
                                        onTap: () async {
                                          HapticFeedback.lightImpact();
                                          if (cached) {
                                            await offline
                                                .removeCachedPlace(place.id);
                                            if (!context.mounted) return;
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                                  SnackBar(
                                                    content: Text(
                                                      context.tr(
                                                        'removed_offline',
                                                      ),
                                                    ),
                                                  ),
                                                );
                                          } else {
                                            final result =
                                                await offline.downloadSinglePlace(
                                              place,
                                            );
                                            if (!context.mounted) return;
                                            final ok =
                                                result is DownloadOk;
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                                  SnackBar(
                                                    content: Text(
                                                      ok
                                                          ? context.tr(
                                                              'downloaded',
                                                            )
                                                          : 'Offline '
                                                                'download '
                                                                'failed',
                                                    ),
                                                  ),
                                                );
                                          }
                                        },
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),

                          if ((place.bestTimeToVisit ?? '').trim().isNotEmpty)
                            Padding(
                              padding:
                                  const EdgeInsets.fromLTRB(24, 18, 24, 0),
                              child: _BestTimeBadge(place: place),
                            ),

                          Padding(
                            padding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: () {
                                  HapticFeedback.lightImpact();
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          AITourGuideScreen(place: place),
                                    ),
                                  );
                                },
                                borderRadius: BorderRadius.circular(16),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 14,
                                  ),
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [
                                        Color(0xFF6366F1),
                                        Color(0xFF8B5CF6),
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(16),
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color(
                                          0xFF6366F1,
                                        ).withValues(alpha: 0.3),
                                        blurRadius: 12,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: Colors.white.withValues(
                                            alpha: 0.2,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                        ),
                                        child: const Icon(
                                          Icons.smart_toy_rounded,
                                          color: Colors.white,
                                          size: 20,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'AI Tour Guide',
                                              style: TextStyle(
                                                color: Colors.white.withValues(
                                                  alpha: 0.85,
                                                ),
                                                fontSize: 11,
                                                fontWeight: FontWeight.w800,
                                                letterSpacing: 0.6,
                                              ),
                                            ),
                                            const Text(
                                              'Ask me anything about this place',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 14,
                                                fontWeight: FontWeight.w700,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const Icon(
                                        Icons.arrow_forward_ios_rounded,
                                        color: Colors.white,
                                        size: 16,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),

                          Padding(
                            padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _PriceBanner(place: place),
                                const SizedBox(height: 22),
                                Row(
                                  children: [
                                    Text(
                                      context.tr('about_place'),
                                      style: TextStyle(
                                        color: textPri,
                                        fontSize: 18,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  place.localizedDescription(
                                    context
                                        .read<LocaleProvider>()
                                        .locale
                                        .languageCode,
                                  ),
                                  style: TextStyle(
                                    color: textSec,
                                    fontSize: 15,
                                    height: 1.6,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          PlacePhotosSection(place: place),
                          const SizedBox(height: 24),
                          _ChatEntryCard(place: place),
                          _ReviewsSection(place: place),

                          if (_nearby.isNotEmpty)
                            _NearbySection(places: _nearby),

                          const SizedBox(height: 32),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          ConfettiOverlay(controller: _confetti),
        ],
      ),
    );
  }
}

class _GlassBtn extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final VoidCallback onTap;
  const _GlassBtn({
    required this.icon,
    this.iconColor = Colors.white,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return PressScale(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      pressedScale: 0.88,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.3),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
        ),
        child: Icon(icon, color: iconColor, size: 20),
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _QuickAction({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

class _ChatEntryCard extends StatelessWidget {
  final PlaceModel place;
  const _ChatEntryCard({required this.place});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () {
          HapticFeedback.lightImpact();
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => LiveChatScreen(place: place)),
          );
        },
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: AppColors.primary.withValues(alpha: 0.15),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.chat_bubble_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.tr('community_chat'),
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      context.tr('community_chat_sub'),
                      style: TextStyle(
                        color: theme.textTheme.bodyMedium?.color,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios_rounded,
                size: 14,
                color: AppColors.primary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ReviewsSection extends StatelessWidget {
  final PlaceModel place;
  const _ReviewsSection({required this.place});

  @override
  Widget build(BuildContext context) {
    final reviewProvider = Provider.of<ReviewProvider>(context);
    final reviews = reviewProvider.getReviewsForPlace(place.id);
    final theme = Theme.of(context);
    final textPri = theme.textTheme.bodyLarge?.color ?? Colors.black;
    final textSec = theme.textTheme.bodyMedium?.color ?? Colors.grey;

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 32, 24, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                context.tr('community_reviews'),
                style: TextStyle(
                  color: textPri,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
              TextButton(
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (_) => AddReviewSheet(placeId: place.id),
                  );
                },
                child: Text(context.tr('write_review')),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (reviews.isEmpty)
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(
                child: Text(
                  context.tr('no_reviews'),
                  textAlign: TextAlign.center,
                  style: TextStyle(color: textSec, fontSize: 14),
                ),
              ),
            )
          else
            ...reviews.take(3).map((r) => _ReviewItem(review: r)),
        ],
      ),
    );
  }
}

class _ReviewItem extends StatelessWidget {
  final ReviewModel review;
  const _ReviewItem({required this.review});

  Future<void> _confirmDelete(BuildContext context) async {
    final provider = context.read<ReviewProvider>();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(ctx.tr('delete_review_q')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(ctx.tr('cancel')),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(
              ctx.tr('delete'),
              style: const TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await provider.removeReview(review.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textPri = theme.textTheme.bodyLarge?.color ?? Colors.black;
    final textSec = theme.textTheme.bodyMedium?.color ?? Colors.grey;
    final canDelete = context.read<AuthProvider>().owns(review.userId);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.dividerColor.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                child: Text(
                  review.userName[0].toUpperCase(),
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      review.userName,
                      style: TextStyle(
                        color: textPri,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    Row(
                      children: List.generate(
                        5,
                        (index) => Icon(
                          Icons.star_rounded,
                          size: 14,
                          color: index < review.rating
                              ? AppColors.ratingGold
                              : Colors.grey[300],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${review.date.day}/${review.date.month}/${review.date.year}',
                    style: TextStyle(color: textSec, fontSize: 12),
                  ),
                  if (canDelete)
                    GestureDetector(
                      onTap: () => _confirmDelete(context),
                      child: Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Icon(
                          Icons.delete_outline_rounded,
                          color: AppColors.error.withValues(alpha: 0.8),
                          size: 18,
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            review.comment,
            style: TextStyle(
              color: textPri.withValues(alpha: 0.8),
              fontSize: 14,
              height: 1.4,
            ),
          ),
          if (review.imagePath != null && review.imagePath!.isNotEmpty) ...[
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: AppImage(
                source: review.imagePath!,
                height: 170,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _NearbySection extends StatelessWidget {
  final List<PlaceModel> places;
  const _NearbySection({required this.places});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textPri = theme.textTheme.bodyLarge?.color ?? Colors.black;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 32, 24, 16),
          child: Text(
            context.tr('nearby_gems'),
            style: TextStyle(
              color: textPri,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        SizedBox(
          height: 180,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: places.length,
            itemBuilder: (context, i) => FadeInUp(
              delay: Duration(milliseconds: 80 * i + 200),
              offsetY: 30,
              child: _NearbyCard(place: places[i]),
            ),
          ),
        ),
      ],
    );
  }
}

class _NearbyCard extends StatelessWidget {
  final PlaceModel place;
  const _NearbyCard({required this.place});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (_, animation, __) => PlaceDetailsScreen(place: place),
          transitionDuration: const Duration(milliseconds: 450),
          transitionsBuilder: (_, animation, __, child) =>
              FadeTransition(opacity: animation, child: child),
        ),
      ),
      child: Container(
        width: 140,
        margin: const EdgeInsets.symmetric(horizontal: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Hero(
              tag: 'place-image-${place.id}',
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: SizedBox(
                  height: 110,
                  width: 140,
                  child: ShimmerImage(
                    imageUrl: place.imageUrl,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              place.localizedName(
                context.read<LocaleProvider>().locale.languageCode,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }
}

class _ShareSheet extends StatelessWidget {
  final PlaceModel place;
  const _ShareSheet({required this.place});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: context.bgColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            context.tr('share_app'),
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _ShareIcon(icon: Icons.link, label: context.tr('copy_link')),
              _ShareIcon(icon: Icons.message, label: context.tr('message')),
              _ShareIcon(icon: Icons.email, label: context.tr('email')),
            ],
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _ShareIcon extends StatelessWidget {
  final IconData icon;
  final String label;
  const _ShareIcon({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: context.bgAlt,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: context.textPri),
        ),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}

class _PriceBanner extends StatelessWidget {
  final PlaceModel place;
  const _PriceBanner({required this.place});

  Color get _accent {
    switch (place.priceLevel) {
      case PriceLevel.free:
        return const Color(0xFF10B981);
      case PriceLevel.cheap:
        return const Color(0xFF14B8A6);
      case PriceLevel.moderate:
        return const Color(0xFFF59E0B);
      case PriceLevel.expensive:
        return const Color(0xFFEF4444);
    }
  }

  IconData get _icon {
    switch (place.priceLevel) {
      case PriceLevel.free:
        return Icons.celebration_rounded;
      case PriceLevel.cheap:
        return Icons.local_offer_rounded;
      case PriceLevel.moderate:
        return Icons.payments_rounded;
      case PriceLevel.expensive:
        return Icons.diamond_rounded;
    }
  }

  String _titleFor(BuildContext context) {
    switch (place.priceLevel) {
      case PriceLevel.free:
        return context.tr('free_entry');
      case PriceLevel.cheap:
        return context.tr('budget_friendly');
      case PriceLevel.moderate:
        return context.tr('standard_ticket');
      case PriceLevel.expensive:
        return context.tr('premium_experience');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark
        ? _accent.withValues(alpha: 0.12)
        : _accent.withValues(alpha: 0.07);
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _accent.withValues(alpha: 0.25)),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: _accent.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(_icon, color: _accent, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _titleFor(context),
                  style: TextStyle(
                    color: _accent,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 2),
                if (place.hasDualPrice) ...[
                  Row(
                    children: [
                      _PricePill(
                        label: context.tr('egyptians'),
                        price: 'EGP ${place.priceLocalEgp}',
                        accent: _accent,
                        isDark: isDark,
                      ),
                      const SizedBox(width: 6),
                      _PricePill(
                        label: context.tr('foreigners'),
                        price: 'EGP ${place.priceForeignerEgp}',
                        accent: _accent,
                        isDark: isDark,
                      ),
                    ],
                  ),
                ] else
                  Builder(
                    builder: (context) {
                      final locale = context
                          .read<LocaleProvider>()
                          .locale
                          .languageCode;
                      final priceNote = place.localizedPriceNote(locale);
                      return Text(
                        priceNote.isEmpty
                            ? place.priceLevel.label
                            : priceNote,
                        style: TextStyle(
                          color: isDark
                              ? const Color(0xFFCBD5E1)
                              : const Color(0xFF475569),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      );
                    },
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BestTimeBadge extends StatelessWidget {
  final PlaceModel place;
  const _BestTimeBadge({required this.place});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textPri = theme.textTheme.bodyLarge?.color ?? Colors.black;
    final customLabel = (place.bestTimeToVisit ?? '').trim();
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFF59E0B), Color(0xFFEF4444)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFF59E0B).withValues(alpha: 0.35),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.22),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.35),
                width: 1.5,
              ),
            ),
            child: const Icon(
              Icons.access_time_filled_rounded,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        context.tr('quick_best_time'),
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.85),
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.22),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Text(
                        'CURATED',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  customLabel,
                  style: TextStyle(
                    color: textPri,
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    height: 1.15,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  context.tr('best_time_admin_hint'),
                  style: TextStyle(
                    color: textPri.withValues(alpha: 0.7),
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PricePill extends StatelessWidget {
  final String label;
  final String price;
  final Color accent;
  final bool isDark;
  const _PricePill({
    required this.label,
    required this.price,
    required this.accent,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: accent.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
              fontSize: 9,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.3,
            ),
          ),
          Text(
            price,
            style: TextStyle(
              color: accent,
              fontSize: 13,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}
