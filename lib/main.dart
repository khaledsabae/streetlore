import 'dart:async';
import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'core/constants/app_colors.dart';
import 'core/services/offline_storage_service.dart';
import 'core/services/supabase_service.dart';
import 'core/config/app_config.dart';
import 'l10n/generated/app_localizations.dart';
import 'logic/place_provider.dart';
import 'logic/tour_provider.dart';
import 'logic/theme_provider.dart';
import 'logic/auth_provider.dart';
import 'logic/locale_provider.dart';
import 'logic/place_photos_provider.dart';
import 'logic/streak_provider.dart';
import 'logic/journal_provider.dart';
import 'logic/achievement_provider.dart';
import 'presentation/screens/splash_screen.dart';
import 'logic/trip_provider.dart';
import 'logic/review_provider.dart';
import 'logic/ai_features_providers.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: AppConfig.supabaseUrl,
    publishableKey: AppConfig.supabaseAnonKey,
    authOptions: const FlutterAuthClientOptions(
      
      
      autoRefreshToken: true,
    ),
  );

  await OfflineStorageService.instance.init();
  await SupabaseService.instance.init();

  final auth = AuthProvider();
  await auth.bootstrap();
  unawaited(_bindAuthDeepLink(auth));

  // Load the offline cache BEFORE places so PlaceProvider's fallback
  // (OfflineProvider.cachedFallback) has the user's packs on a cold,
  // offline start instead of the bundled mock data.
  final offline = OfflineProvider();
  await offline.init();

  final placeProvider = PlaceProvider();
  final tourProvider = TourProvider();
  final tripProvider = TripProvider();
  unawaited(placeProvider.loadPlaces());
  unawaited(tourProvider.loadTours());

  final gamification = GamificationProvider();
  gamification.syncWithAuth(auth);

  final streak = StreakProvider();
  streak.setUserId(auth.userId);
  final achievements = AchievementProvider(
    auth: auth,
    gam: gamification,
    places: placeProvider,
    streak: streak,
  );
  // v1.0.56: wire gamification -> streak/achievements so a single
  // gamification.applyAction('check_in', ...) call updates the
  // streak and re-runs the catalog-based achievement re-evaluation
  // automatically (the missing piece that broke badge unlocks).
  gamification.bindHelpers(streak: streak, achievements: achievements);

  
  
  
  
  
  
  Future<void> bootstrapFromSupabase(String userId) async {
    await Future.wait([
      placeProvider.bootstrapForUser(userId),
      tourProvider.bootstrapForUser(userId),
      gamification.bootstrapForUser(userId),
      tripProvider.refreshVisited(),
    ]);
    achievements.refreshFromStats();
  }

  void authListener() {
    final id = auth.userId;
    if (id.isEmpty) return;
    
    
    if (id == _lastBootstrappedUserId) return;
    _lastBootstrappedUserId = id;
    unawaited(bootstrapFromSupabase(id));
  }

  auth.addListener(authListener);
  if (auth.userId.isNotEmpty) {
    _lastBootstrappedUserId = auth.userId;
    unawaited(bootstrapFromSupabase(auth.userId));
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthProvider>.value(value: auth),
        ChangeNotifierProvider(create: (_) => ReviewProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider<TripProvider>.value(value: tripProvider),
        ChangeNotifierProvider<PlaceProvider>.value(value: placeProvider),
        ChangeNotifierProvider<TourProvider>.value(value: tourProvider),
        ChangeNotifierProvider<GamificationProvider>.value(value: gamification),
        ChangeNotifierProvider(create: (_) => ChatProvider()),
        ChangeNotifierProvider(create: (_) => LeaderboardProvider()),
        ChangeNotifierProvider(create: (_) => GeofenceProvider()),
        ChangeNotifierProvider<OfflineProvider>.value(value: offline),
        ChangeNotifierProvider(create: (_) => PlacePhotosProvider()),
        ChangeNotifierProvider<StreakProvider>.value(value: streak),
        ChangeNotifierProvider(create: (_) => LocaleProvider()),
        ChangeNotifierProvider(create: (_) => JournalProvider()),
        ChangeNotifierProvider<AchievementProvider>.value(value: achievements),
      ],
      child: const StreetloreApp(),
    ),
  );
}

String? _lastBootstrappedUserId;

Future<void> _bindAuthDeepLink(AuthProvider auth) async {
  try {
    final links = AppLinks();
    final initial = await links.getInitialLink();
    if (initial != null) {
      await auth.handleAuthCallback(initial);
    }
    links.uriLinkStream.listen((uri) async {
      await auth.handleAuthCallback(uri);
    });
  } catch (e) {
    debugPrint('Deep link bind failed: $e');
  }
}

class StreetloreApp extends StatelessWidget {
  const StreetloreApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<ThemeProvider, LocaleProvider>(
      builder: (context, themeProvider, localeProvider, _) {
        return MaterialApp(
          title: 'Streetlore',
          debugShowCheckedModeBanner: false,
          locale: localeProvider.locale,
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          themeMode: themeProvider.themeMode,
          theme: _lightTheme(),
          darkTheme: _darkTheme(),
          home: const SplashScreen(),
        );
      },
    );
  }

  ThemeData _lightTheme() {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        brightness: Brightness.light,
      ),
      scaffoldBackgroundColor: const Color(0xFFF8FAFC),
      fontFamily: 'Cairo',
      textTheme: const TextTheme().apply(
        fontFamily: 'Cairo',
        bodyColor: const Color(0xFF0F172A),
        displayColor: const Color(0xFF0F172A),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFFF8FAFC),
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        iconTheme: IconThemeData(color: Color(0xFF0F172A)),
        titleTextStyle: TextStyle(
          fontFamily: 'Cairo',
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: Color(0xFF0F172A),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        backgroundColor: const Color(0xFF0F172A),
        contentTextStyle: const TextStyle(
          fontFamily: 'Cairo',
          color: Colors.white,
          fontWeight: FontWeight.w500,
          fontSize: 14,
        ),
      ),
      dialogTheme: DialogThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: Colors.white,
      ),
    );
  }

  ThemeData _darkTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF3B82F6),
        brightness: Brightness.dark,
      ),
      scaffoldBackgroundColor: const Color(0xFF0D1117),
      fontFamily: 'Cairo',
      textTheme: const TextTheme().apply(
        fontFamily: 'Cairo',
        bodyColor: const Color(0xFFF1F5F9),
        displayColor: const Color(0xFFF1F5F9),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF0D1117),
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        iconTheme: IconThemeData(color: Color(0xFFF1F5F9)),
        titleTextStyle: TextStyle(
          fontFamily: 'Cairo',
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: Color(0xFFF1F5F9),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        backgroundColor: const Color(0xFF1C2433),
        contentTextStyle: const TextStyle(
          fontFamily: 'Cairo',
          color: Colors.white,
          fontWeight: FontWeight.w500,
          fontSize: 14,
        ),
      ),
      dialogTheme: DialogThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: const Color(0xFF1C2433),
      ),
    );
  }
}
