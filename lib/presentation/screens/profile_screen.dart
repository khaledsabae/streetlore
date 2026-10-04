import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/config/app_config.dart';
import '../../core/animations/app_animations.dart';
import '../../core/constants/app_version.dart';
import '../../core/constants/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/animated_icons.dart';
import '../../core/widgets/confetti_overlay.dart';
import '../../logic/place_provider.dart';
import '../../logic/tour_provider.dart';
import '../../logic/theme_provider.dart';
import '../../logic/auth_provider.dart';
import '../../logic/gamification_provider.dart';
import 'package:flutter/scheduler.dart';
import '../../logic/achievement_provider.dart';
import '../../logic/locale_provider.dart';
import '../../logic/streak_provider.dart';
import '../../l10n/app_strings.dart';
import 'login_screen.dart';
import 'emergency_screen.dart';
import 'map_view_screen.dart';
import 'currency_converter_screen.dart';
import 'journal_screen.dart';
import 'prayer_times_screen.dart';
import 'achievements_screen.dart';
import 'admin_panel_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final ConfettiController _confetti = ConfettiController();
  bool _notificationsEnabled = true;
  bool _locationEnabled = true;

  @override
  void initState() {
    super.initState();
    _loadTogglePrefs();
    _refreshOnNextFrame();
  }

  void _refreshOnNextFrame() {
    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final auth = context.read<AuthProvider>();
      if (auth.userId.isNotEmpty) {
        context.read<PlaceProvider>().fetchRemoteCounts(auth.userId);
      }
      _maybeCelebrateStreakBadge();
    });
  }

  Future<void> _loadTogglePrefs() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        _notificationsEnabled = prefs.getBool('notifications_enabled') ?? true;
        _locationEnabled = prefs.getBool('location_enabled') ?? true;
      });
    }
  }

  Future<void> _editName(BuildContext context, AuthProvider auth) async {
    final ctrl = TextEditingController(text: auth.userName);
    final formKey = GlobalKey<FormState>();
    final newName = await showDialog<String>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: Theme.of(ctx).cardColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(
            context.tr('edit_name_dialog_title'),
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
          ),
          content: Form(
            key: formKey,
            child: TextFormField(
              controller: ctrl,
              autofocus: true,
              textCapitalization: TextCapitalization.words,
              maxLength: 24,
              decoration: InputDecoration(
                labelText: context.tr('login_full_name'),
                prefixIcon: const Icon(Icons.badge_outlined),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                counterText: '',
              ),
              validator: (v) {
                if (v == null || v.trim().isEmpty) {
                  return context.tr('login_err_name');
                }
                return null;
              },
              onFieldSubmitted: (_) {
                if (formKey.currentState!.validate()) {
                  Navigator.of(ctx).pop(ctrl.text);
                }
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: Text(
                context.tr('cancel'),
                style: TextStyle(color: context.textSec),
              ),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.accent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  Navigator.of(ctx).pop(ctrl.text);
                }
              },
              child: Text(
                context.tr('sign_in_continue'),
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          ],
        );
      },
    );
    if (newName == null || newName.trim().isEmpty) return;
    if (!mounted) return;
    await auth.updateGuestName(newName);
    if (!context.mounted) return;
    final gam = context.read<GamificationProvider>();
    gam.syncWithAuth(auth);
    HapticFeedback.lightImpact();
  }

  Future<void> _maybeCelebrateStreakBadge() async {
    final g = context.read<GamificationProvider>();
    final streakBadges = g.stats.badges.where(
      (b) => b.id.startsWith('b_streak_'),
    );
    if (streakBadges.isEmpty) return;
    final highest = streakBadges
        .map((b) => int.tryParse(b.id.replaceFirst('b_streak_', '')) ?? 0)
        .fold(0, (a, b) => a > b ? a : b);
    final prefs = await SharedPreferences.getInstance();
    const key = 'profile_celebrated_streak_badge';
    final celebrated = prefs.getInt(key) ?? 0;
    if (highest > celebrated) {
      if (!mounted) return;
      HapticFeedback.heavyImpact();
      _confetti.play();
      await prefs.setInt(key, highest);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final themeP = context.watch<ThemeProvider>();
    final placeP = context.watch<PlaceProvider>();
    final tourP = context.watch<TourProvider>();
    final gamification = context.watch<GamificationProvider>();

    return Scaffold(
      backgroundColor: context.bgColor,
      body: Stack(
        children: [
          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: const BorderRadius.vertical(
                      bottom: Radius.circular(32),
                    ),
                  ),
                  padding: EdgeInsets.only(
                    top: MediaQuery.of(context).padding.top + 20,
                    bottom: 32,
                    left: 24,
                    right: 24,
                  ),
                  child: Column(
                    children: [
                      Stack(
                        children: [
                          Container(
                            width: 90,
                            height: 90,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white.withValues(alpha: 0.2),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.4),
                                width: 3,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                auth.userName.isNotEmpty
                                    ? auth.userName[0].toUpperCase()
                                    : 'E',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 38,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Flexible(
                            child: Text(
                              auth.userName,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.w800,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 6),
                          GestureDetector(
                            onTap: () => _editName(context, auth),
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.2),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.edit_rounded,
                                color: Colors.white,
                                size: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),

                      const SizedBox(
                        width: 40,
                        height: 40,
                        child: AnimatedLottieIcon(
                          animation: LottieAnimations.trophy,
                          size: 40,
                          color: AppColors.warning,
                          secondaryColor: AppColors.goldLight,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        auth.userEmail,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.7),
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 20),

                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.15),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _Stat(
                              label: context.tr('prof_saved'),
                              numericValue:
                                  placeP.savedPlaces.length >
                                      placeP.remoteSavedCount
                                  ? placeP.savedPlaces.length
                                  : placeP.remoteSavedCount,
                              icon: Icons.bookmark_rounded,
                              delayMs: 200,
                            ),
                            Container(
                              width: 1,
                              height: 36,
                              color: Colors.white.withValues(alpha: 0.2),
                            ),

                            _Stat(
                              label: context.tr('prof_explored'),
                              numericValue: placeP.remoteCheckinCount,
                              icon: Icons.explore_rounded,
                              delayMs: 320,
                            ),
                            Container(
                              width: 1,
                              height: 36,
                              color: Colors.white.withValues(alpha: 0.2),
                            ),
                            _Stat(
                              label: context.tr('prof_tours'),
                              numericValue: tourP.visitedTourIds.length,
                              icon: Icons.map_rounded,
                              delayMs: 440,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                  child: Consumer<StreakProvider>(
                    builder: (context, streak, _) {
                      return Container(
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [Color(0xFFFB923C), Color(0xFFEF4444)],
                          ),
                          borderRadius: BorderRadius.circular(18),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(
                                0xFFEF4444,
                              ).withValues(alpha: 0.3),
                              blurRadius: 14,
                              offset: const Offset(0, 5),
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
                                Icons.local_fire_department_rounded,
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
                                    streak.currentStreak == 0
                                        ? context.tr('streak_start')
                                        : context.tr('streak_days', {
                                            'n': '${streak.currentStreak}',
                                            's': streak.currentStreak == 1
                                                ? ''
                                                : 's',
                                          }),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 17,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    streak.longestStreak > 0
                                        ? context.tr('streak_best', {
                                            'b': '${streak.longestStreak}',
                                            't': '${streak.totalVisitDays}',
                                            's': streak.totalVisitDays == 1
                                                ? ''
                                                : 's',
                                          })
                                        : context.tr('streak_begin'),
                                    style: TextStyle(
                                      color: Colors.white.withValues(
                                        alpha: 0.88,
                                      ),
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),

              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                  child: Consumer<GamificationProvider>(
                    builder: (context, g, _) {
                      final badges = g.stats.badges;
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            context.tr('badges_title'),
                            style: AppTextStyles.sectionTitle.copyWith(
                              color: context.textPri,
                            ),
                          ),
                          const SizedBox(height: 10),
                          if (badges.isEmpty)
                            Text(
                              context.tr('no_badges'),
                              style: TextStyle(
                                color: context.textSec,
                                fontSize: 13,
                              ),
                            )
                          else
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                for (var i = 0; i < badges.length; i++)
                                  FadeInUp(
                                    delay: Duration(milliseconds: 60 * i),
                                    offsetY: 12,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 8,
                                      ),
                                      decoration: BoxDecoration(
                                        gradient: AppColors.primaryGradient,
                                        borderRadius: BorderRadius.circular(14),
                                        boxShadow: [
                                          BoxShadow(
                                            color: AppColors.primary.withValues(
                                              alpha: 0.25,
                                            ),
                                            blurRadius: 10,
                                            offset: const Offset(0, 4),
                                          ),
                                        ],
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Icon(
                                            Icons.workspace_premium_rounded,
                                            color: Colors.white,
                                            size: 16,
                                          ),
                                          const SizedBox(width: 6),
                                          Text(
                                            context.tr(badges[i].name),
                                            style: const TextStyle(
                                              color: Colors.white,
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
                        ],
                      );
                    },
                  ),
                ),
              ),

              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
                  child: Consumer<AchievementProvider>(
                    builder: (context, ach, _) {
                      final recent = ach.recentUnlocked(limit: 3);
                      final ratio = ach.completionRatio;
                      // v1.0.56 fix: variables are explicitly
                      // unlocked_count / total_count. The displayed
                      // format is "{unlocked_count} / {total_count}".
                      final unlockedCount = ach.totalUnlocked;
                      final totalCount = ach.totalAvailable;
                      return GestureDetector(
                        onTap: () {
                          HapticFeedback.lightImpact();
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const AchievementsScreen(),
                            ),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [Color(0xFFFFB347), Color(0xFFFF7E5F)],
                            ),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(
                                  0xFFFF7E5F,
                                ).withValues(alpha: 0.3),
                                blurRadius: 14,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    width: 44,
                                    height: 44,
                                    decoration: BoxDecoration(
                                      color: Colors.white.withValues(
                                        alpha: 0.22,
                                      ),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Icon(
                                      Icons.emoji_events_rounded,
                                      color: Colors.white,
                                      size: 22,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Achievements',
                                          style: TextStyle(
                                            color: Colors.white.withValues(
                                              alpha: 0.85,
                                            ),
                                            fontSize: 11,
                                            fontWeight: FontWeight.w800,
                                            letterSpacing: 0.6,
                                          ),
                                        ),
                                        Text(
                                          '$unlockedCount / $totalCount unlocked',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 16,
                                            fontWeight: FontWeight.w900,
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
                              const SizedBox(height: 14),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(6),
                                child: LinearProgressIndicator(
                                  value: ratio,
                                  minHeight: 8,
                                  backgroundColor: Colors.white.withValues(
                                    alpha: 0.2,
                                  ),
                                  valueColor: const AlwaysStoppedAnimation(
                                    Colors.white,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 12),
                              if (recent.isEmpty)
                                Text(
                                  'Start your collection',
                                  style: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.85),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                )
                              else
                                Row(
                                  children: [
                                    for (final def in recent) ...[
                                      Container(
                                        width: 38,
                                        height: 38,
                                        decoration: BoxDecoration(
                                          color: Colors.white.withValues(
                                            alpha: 0.22,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                        ),
                                        child: Icon(
                                          def.icon,
                                          color: Colors.white,
                                          size: 20,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                    ],
                                    Expanded(
                                      child: Text(
                                        'View all',
                                        textAlign: TextAlign.end,
                                        style: TextStyle(
                                          color: Colors.white.withValues(
                                            alpha: 0.9,
                                          ),
                                          fontSize: 12,
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),

              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 24, 16, 4),
                  child: Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.35),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.favorite_rounded,
                          color: Colors.white,
                          size: 28,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                context.tr('passion_banner_title'),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                context.tr('passion_banner_sub'),
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.92),
                                  fontSize: 12,
                                  height: 1.4,
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

              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 20, 16, 4),
                  child: Text(
                    context.tr('section_app_settings'),
                    style: AppTextStyles.sectionTitle.copyWith(
                      color: context.textPri,
                    ),
                  ),
                ),
              ),

              SliverToBoxAdapter(
                child: FadeInUp(
                  delay: const Duration(milliseconds: 200),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: _Card(
                      children: [
                        _ToggleTile(
                          icon: Icons.dark_mode_rounded,
                          title: context.tr('dark_mode'),
                          subtitle: themeP.isDark
                              ? context.tr('dark_theme_on')
                              : context.tr('light_theme_on'),
                          color: const Color(0xFF6366F1),
                          value: themeP.isDark,
                          onChanged: (_) {
                            HapticFeedback.lightImpact();
                            context.read<ThemeProvider>().toggleTheme();
                          },
                        ),
                        _Div(),
                        _ToggleTile(
                          icon: Icons.notifications_rounded,
                          title: context.tr('push_notif'),
                          subtitle: context.tr('push_notif_sub'),
                          color: AppColors.accent,
                          value: _notificationsEnabled,
                          onChanged: (v) async {
                            HapticFeedback.lightImpact();
                            setState(() => _notificationsEnabled = v);
                            final prefs = await SharedPreferences.getInstance();
                            await prefs.setBool('notifications_enabled', v);
                          },
                        ),
                        _Div(),
                        _ToggleTile(
                          icon: Icons.location_on_rounded,
                          title: context.tr('location_services'),
                          subtitle: context.tr('location_services_sub'),
                          color: AppColors.success,
                          value: _locationEnabled,
                          onChanged: (v) async {
                            HapticFeedback.lightImpact();
                            setState(() => _locationEnabled = v);
                            final prefs = await SharedPreferences.getInstance();
                            await prefs.setBool('location_enabled', v);
                          },
                        ),
                        _Div(),
                        Consumer<LocaleProvider>(
                          builder: (context, lp, _) {
                            return _ToggleTile(
                              icon: Icons.translate_rounded,
                              title: context.tr('language'),
                              subtitle: lp.isArabic ? 'العربية' : 'English',
                              color: const Color(0xFF0EA5E9),
                              value: lp.isArabic,
                              onChanged: (_) async {
                                HapticFeedback.lightImpact();
                                await lp.toggle();
                              },
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 20, 16, 4),
                  child: Text(
                    context.tr('section_about'),
                    style: AppTextStyles.sectionTitle.copyWith(
                      color: context.textPri,
                    ),
                  ),
                ),
              ),

              SliverToBoxAdapter(
                child: FadeInUp(
                  delay: const Duration(milliseconds: 440),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: _Card(
                      children: [
                        _ActionTile(
                          icon: Icons.health_and_safety_rounded,
                          title: context.tr('emergency_info'),
                          subtitle: context.tr('emergency_info_sub'),
                          color: const Color(0xFFEF4444),
                          onTap: () {
                            HapticFeedback.lightImpact();
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const EmergencyScreen(),
                              ),
                            );
                          },
                        ),
                        _Div(),
                        _ActionTile(
                          icon: Icons.mosque_rounded,
                          title: context.tr('prayer_times'),
                          subtitle: context.tr('prayer_times_sub'),
                          color: const Color(0xFF14B8A6),
                          onTap: () {
                            HapticFeedback.lightImpact();
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const PrayerTimesScreen(),
                              ),
                            );
                          },
                        ),
                        _Div(),
                        _ActionTile(
                          icon: Icons.map_rounded,
                          title: context.tr('map_view'),
                          subtitle: context.tr('map_view_sub'),
                          color: const Color(0xFF3B82F6),
                          onTap: () {
                            HapticFeedback.lightImpact();
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const MapViewScreen(),
                              ),
                            );
                          },
                        ),
                        _Div(),
                        _ActionTile(
                          icon: Icons.attach_money_rounded,
                          title: context.tr('currency_converter'),
                          subtitle: context.tr('currency_converter_sub'),
                          color: const Color(0xFF14B8A6),
                          onTap: () {
                            HapticFeedback.lightImpact();
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const CurrencyConverterScreen(),
                              ),
                            );
                          },
                        ),
                        _Div(),

                        Consumer<AuthProvider>(
                          builder: (context, auth, _) {
                            if (!auth.isAdmin) return const SizedBox.shrink();
                            return _ActionTile(
                              icon: Icons.admin_panel_settings_rounded,
                              title: context.tr('admin_title'),
                              subtitle:
                                  '${context.tr('admin_field_category')}: '
                                  'ATM / Hotel / Cafe / ...',
                              color: const Color(0xFFEF4444),
                              onTap: () {
                                HapticFeedback.lightImpact();
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const AdminPanelScreen(),
                                  ),
                                );
                              },
                            );
                          },
                        ),
                        _Div(),
                        _ActionTile(
                          icon: Icons.menu_book_rounded,
                          title: context.tr('travel_journal'),
                          subtitle: context.tr('travel_journal_sub'),
                          color: const Color(0xFF8B5CF6),
                          onTap: () {
                            HapticFeedback.lightImpact();
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const JournalScreen(),
                              ),
                            );
                          },
                        ),
                        _Div(),
                        _ActionTile(
                          icon: Icons.help_outline_rounded,
                          title: context.tr('help_center'),
                          subtitle: context.tr('help_center_sub'),
                          color: const Color(0xFF0EA5E9),
                          onTap: () => _showHelp(context),
                        ),
                        _Div(),
                        _ActionTile(
                          icon: Icons.star_outline_rounded,
                          title: context.tr('rate_app'),
                          subtitle: context.tr('rate_app_sub'),
                          color: AppColors.ratingGold,
                          onTap: () =>
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(context.tr('rate_thanks')),
                                ),
                              ),
                        ),
                        _Div(),
                        _ActionTile(
                          icon: Icons.info_outline_rounded,
                          title: context.tr('about_app'),
                          subtitle: formatAppVersionLabel(),
                          color: context.textSec,
                          onTap: () => showAboutDialog(
                            context: context,
                            applicationName: 'Streetlore',
                            applicationVersion: kAppVersionFull,
                            applicationIcon: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                gradient: AppColors.primaryGradient,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.explore_rounded,
                                size: 28,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.error,
                      side: BorderSide(
                        color: AppColors.error.withValues(alpha: 0.4),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      minimumSize: const Size(double.infinity, 52),
                    ),
                    onPressed: () => _showSignOutDialog(context),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.logout_rounded,
                          size: 18,
                          color: AppColors.error,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          context.tr('sign_out'),
                          style: TextStyle(
                            color: AppColors.error,
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
                  child: Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 8,
                    children: [
                      TextButton(
                        onPressed: () => launchUrl(
                          Uri.parse(AppConfig.privacyPolicyUrl),
                          mode: LaunchMode.externalApplication,
                        ),
                        child: Text(
                          context.tr('privacy_policy'),
                          style: TextStyle(color: context.textSec),
                        ),
                      ),
                      if (auth.isLoggedIn && !auth.isGuest)
                        TextButton(
                          onPressed: () => _showDeleteAccountDialog(context),
                          child: Text(
                            context.tr('delete_account'),
                            style: TextStyle(color: AppColors.error),
                          ),
                        ),
                    ],
                  ),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 32)),
            ],
          ),
          Positioned.fill(child: ConfettiOverlay(controller: _confetti)),
        ],
      ),
    );
  }

  void _showSignOutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: context.cardColor,
        title: Text(
          context.tr('sign_out_q'),
          style: TextStyle(color: context.textPri, fontWeight: FontWeight.w800),
        ),
        content: Text(
          context.tr('sign_out_sub'),
          style: TextStyle(color: context.textSec, fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              context.tr('cancel'),
              style: TextStyle(color: context.textSec),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () async {
              Navigator.pop(ctx);
              await context.read<AuthProvider>().signOut();
              if (!context.mounted) return;
              Navigator.of(context).pushAndRemoveUntil(
                PageRouteBuilder(
                  pageBuilder: (_, a, __) => const LoginScreen(),
                  transitionDuration: const Duration(milliseconds: 500),
                  transitionsBuilder: (_, a, __, child) =>
                      FadeTransition(opacity: a, child: child),
                ),
                (route) => false,
              );
            },
            child: Text(
              context.tr('sign_out'),
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteAccountDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: context.cardColor,
        title: Text(
          context.tr('delete_account_q'),
          style: TextStyle(color: context.textPri, fontWeight: FontWeight.w800),
        ),
        content: Text(
          context.tr('delete_account_sub'),
          style: TextStyle(color: context.textSec, fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              context.tr('cancel'),
              style: TextStyle(color: context.textSec),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () async {
              Navigator.pop(ctx);
              final err = await context.read<AuthProvider>().deleteAccount();
              if (!context.mounted) return;
              if (err != null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(context.tr('delete_account_failed'))),
                );
                return;
              }
              Navigator.of(context).pushAndRemoveUntil(
                PageRouteBuilder(
                  pageBuilder: (_, a, __) => const LoginScreen(),
                  transitionDuration: const Duration(milliseconds: 500),
                  transitionsBuilder: (_, a, __, child) =>
                      FadeTransition(opacity: a, child: child),
                ),
                (route) => false,
              );
            },
            child: Text(
              context.tr('delete_account'),
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  void _showHelp(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: context.cardColor,
        title: Text(
          context.tr('help_center'),
          style: TextStyle(color: context.textPri, fontWeight: FontWeight.w800),
        ),
        content: Text(
          context.tr('help_contact'),
          style: TextStyle(color: context.textSec, fontSize: 14, height: 1.6),
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              context.tr('got_it'),
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final String label;
  final int? numericValue;
  final IconData icon;
  final int delayMs;
  const _Stat({
    required this.label,
    required this.icon,
    this.numericValue,
    this.delayMs = 0,
  });

  @override
  Widget build(BuildContext context) {
    return FadeInUp(
      delay: Duration(milliseconds: delayMs),
      child: Column(
        children: [
          Icon(icon, color: Colors.white70, size: 18),
          const SizedBox(height: 4),
          Text(
            (numericValue ?? 0).toString(),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.65),
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}

class _Card extends StatelessWidget {
  final List<Widget> children;
  const _Card({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: context.borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }
}

class _ToggleTile extends StatelessWidget {
  final IconData icon;
  final String title, subtitle;
  final Color color;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _ToggleTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    color: context.textPri,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(fontSize: 12, color: context.textSec),
                ),
              ],
            ),
          ),
          Switch.adaptive(
            value: value,
            onChanged: onChanged,
            activeThumbColor: color,
            activeTrackColor: color.withValues(alpha: 0.3),
          ),
        ],
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final String title, subtitle;
  final Color color;
  final VoidCallback onTap;

  const _ActionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                      color: context.textPri,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 12, color: context.textSec),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: context.hintColor,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}

class _Div extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Divider(
      height: 1,
      indent: 68,
      endIndent: 16,
      color: context.dividerColor,
    );
  }
}
