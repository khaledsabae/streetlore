import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../core/animations/app_animations.dart';
import '../../core/constants/app_colors.dart';
import '../../core/services/best_time_service.dart';
import '../../core/services/sun_times_service.dart';
import '../../data/models/place_model.dart';
import '../../l10n/app_strings.dart';
import '../../logic/place_provider.dart';
import 'place_details_screen.dart';

class BestTimeScreen extends StatefulWidget {
  const BestTimeScreen({super.key});

  @override
  State<BestTimeScreen> createState() => _BestTimeScreenState();
}

class _BestTimeScreenState extends State<BestTimeScreen> {
  late DateTime _now;

  @override
  void initState() {
    super.initState();
    _now = DateTime.now();
  }

  void _refreshNow() {
    setState(() => _now = DateTime.now());
  }

  @override
  Widget build(BuildContext context) {
    final places = context.watch<PlaceProvider>().places;
    final ranked = _ranked(places, _now);
    final great = ranked.where((r) => r.recommendation.isGoodNow).length;
    final okay = ranked.where((r) => r.recommendation.isOkayNow).length;
    final skip = ranked.where((r) => r.recommendation.isBadNow).length;

    return Scaffold(
      backgroundColor: context.bgColor,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            pinned: true,
            backgroundColor: context.bgColor,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_rounded, size: 20),
              color: context.textPri,
              onPressed: () => Navigator.pop(context),
            ),
            title: Text(
              context.tr('bt_title'),
              style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 20,
                color: context.textPri,
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh_rounded, size: 22),
                color: context.textPri,
                tooltip: context.tr('refresh'),
                onPressed: _refreshNow,
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
              child: FadeInUp(
                delay: const Duration(milliseconds: 80),
                child: Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                    ),
                    borderRadius: BorderRadius.circular(22),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF6366F1).withValues(alpha: 0.3),
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
                          color: Colors.white.withValues(alpha: 0.18),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(
                          Icons.wb_twilight_rounded,
                          color: Colors.white,
                          size: 32,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _nowLabel(context, _now),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 17,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _nowSubtitle(context, _now, great, okay, skip),
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.85),
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            sliver: SliverToBoxAdapter(child: _SunTimesCard()),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
            sliver: SliverToBoxAdapter(
              child: Row(
                children: [
                  Icon(Icons.bolt_rounded, color: AppColors.warning, size: 18),
                  const SizedBox(width: 6),
                  Text(
                    context.tr('bt_ranked_now'),
                    style: TextStyle(
                      color: context.textPri,
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(0, 12, 0, 24),
            sliver: SliverList.builder(
              itemCount: ranked.length,
              itemBuilder: (context, i) {
                final entry = ranked[i];
                return FadeInUp(
                  delay: Duration(milliseconds: 100 + (i * 35).clamp(0, 800)),
                  child: _BestTimeCard(
                    rank: i + 1,
                    place: entry.place,
                    recommendation: entry.recommendation,
                    onTap: () {
                      HapticFeedback.lightImpact();
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              PlaceDetailsScreen(place: entry.place),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  List<_RankedPlace> _ranked(List<PlaceModel> places, DateTime now) {
    final list = places
        .map(
          (p) => _RankedPlace(
            place: p,
            recommendation: BestTimeService.instance.recommend(p, now: now),
          ),
        )
        .toList();
    list.sort(
      (a, b) => b.recommendation.score.compareTo(a.recommendation.score),
    );
    return list;
  }

  String _nowLabel(BuildContext context, DateTime now) {
    final hour = now.hour;
    if (hour < 12) return context.tr('greet_morning');
    if (hour < 17) return context.tr('greet_afternoon');
    if (hour < 21) return context.tr('greet_evening');
    return context.tr('greet_night');
  }

  String _nowSubtitle(
    BuildContext context,
    DateTime now,
    int great,
    int okay,
    int skip,
  ) {
    final day = _dayName(context, now.weekday);
    if (great > 0) {
      return context.tr('bt_sub_great', {
        'day': day,
        'n': '$great',
        's': great == 1 ? '' : 's',
      });
    }
    if (okay > 0) {
      return context.tr('bt_sub_okay', {
        'day': day,
        'n': '$okay',
        's': okay == 1 ? '' : 's',
      });
    }
    return context.tr('bt_sub_quiet', {'day': day});
  }

  String _dayName(BuildContext context, int weekday) {
    return context.tr(
      [
        'day_mon',
        'day_tue',
        'day_wed',
        'day_thu',
        'day_fri',
        'day_sat',
        'day_sun',
      ][weekday - 1],
    );
  }
}

class _RankedPlace {
  final PlaceModel place;
  final BestTimeRecommendation recommendation;
  _RankedPlace({required this.place, required this.recommendation});
}

class _BestTimeCard extends StatelessWidget {
  final int rank;
  final PlaceModel place;
  final BestTimeRecommendation recommendation;
  final VoidCallback onTap;

  const _BestTimeCard({
    required this.rank,
    required this.place,
    required this.recommendation,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return PressScale(
      onTap: onTap,
      pressedScale: 0.98,
      child: Container(
        margin: const EdgeInsets.fromLTRB(20, 6, 20, 6),
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
        decoration: BoxDecoration(
          color: context.cardColor,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: recommendation.color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              alignment: Alignment.center,
              child: Text(
                '$rank',
                style: TextStyle(
                  color: recommendation.color,
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
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
                    style: TextStyle(
                      color: context.textPri,
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        recommendation.icon,
                        size: 13,
                        color: recommendation.color,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          recommendation.customLabel ??
                              context.tr(recommendation.labelKey),
                          style: TextStyle(
                            color: recommendation.color,
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '· ${context.tr(recommendation.hintKey)}',
                          style: TextStyle(
                            color: context.textSec,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            _ScoreRing(
              score: recommendation.score,
              color: recommendation.color,
            ),
          ],
        ),
      ),
    );
  }
}

class _ScoreRing extends StatelessWidget {
  final int score;
  final Color color;
  const _ScoreRing({required this.score, required this.color});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 44,
      height: 44,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: 44,
            height: 44,
            child: CircularProgressIndicator(
              value: score / 100,
              strokeWidth: 4,
              backgroundColor: color.withValues(alpha: 0.15),
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
          Text(
            '$score',
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _SunTimesCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final times = SunTimesService.instance.compute();
    final svc = SunTimesService.instance;
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFB923C), Color(0xFFF59E0B)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFB923C).withValues(alpha: 0.3),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          _SunPill(
            icon: Icons.wb_twilight_rounded,
            label: context.tr('bt_sunrise'),
            time: svc.formatTime(times.sunrise),
          ),
          Container(
            width: 1,
            height: 36,
            color: Colors.white.withValues(alpha: 0.3),
            margin: const EdgeInsets.symmetric(horizontal: 12),
          ),
          _SunPill(
            icon: Icons.wb_sunny_rounded,
            label: context.tr('bt_daylight'),
            time: svc.formatDuration(times.daylight),
          ),
          Container(
            width: 1,
            height: 36,
            color: Colors.white.withValues(alpha: 0.3),
            margin: const EdgeInsets.symmetric(horizontal: 12),
          ),
          _SunPill(
            icon: Icons.nights_stay_rounded,
            label: context.tr('bt_sunset'),
            time: svc.formatTime(times.sunset),
          ),
        ],
      ),
    );
  }
}

class _SunPill extends StatelessWidget {
  final IconData icon;
  final String label;
  final String time;
  const _SunPill({required this.icon, required this.label, required this.time});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 22),
          const SizedBox(height: 4),
          Text(
            time,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w900,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.85),
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
