import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../logic/auth_provider.dart';
import '../widgets/compass_brand.dart';
import 'login_screen.dart';
import 'main_navigation.dart';
import 'onboarding_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  static const Color _bg = Color(0xFFFAF5EB);
  static const Color _letterColor = Color(0xFF1F3A5F);

  late final AnimationController _exitCtrl;
  late final AnimationController _introCtrl;
  late final Animation<double> _logoFade;
  late final Animation<double> _taglineFade;
  late final Animation<Offset> _taglineSlide;

  @override
  void initState() {
    super.initState();

    _introCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1300),
    )..forward();

    _logoFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _introCtrl,
        curve: const Interval(0.0, 0.55, curve: Curves.easeIn),
      ),
    );

    _taglineFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _introCtrl,
        curve: const Interval(0.55, 1.0),
      ),
    );

    _taglineSlide =
        Tween<Offset>(begin: const Offset(0, 0.5), end: Offset.zero).animate(
      CurvedAnimation(
        parent: _introCtrl,
        curve: const Interval(0.55, 1.0, curve: Curves.easeOutCubic),
      ),
    );

    _exitCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    Future.delayed(const Duration(milliseconds: 5000), _exitThenNavigate);
  }

  @override
  void dispose() {
    _introCtrl.dispose();
    _exitCtrl.dispose();
    super.dispose();
  }

  Future<void> _exitThenNavigate() async {
    if (!mounted) return;
    final auth = context.read<AuthProvider>();

    const maxWait = Duration(seconds: 3);
    final started = DateTime.now();
    while (auth.isLoading && DateTime.now().difference(started) < maxWait) {
      await Future.delayed(const Duration(milliseconds: 100));
      if (!mounted) return;
    }

    await _exitCtrl.forward();
    if (!mounted) return;

    final Widget destination;
    if (!auth.hasSeenOnboarding) {
      destination = const OnboardingScreen();
    } else if (!auth.isLoggedIn) {
      destination = const LoginScreen();
    } else {
      destination = const MainNavigation();
    }

    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (ctx, animation, second) => destination,
        transitionDuration: const Duration(milliseconds: 500),
        reverseTransitionDuration: const Duration(milliseconds: 300),
        transitionsBuilder: (ctx, animation, second, child) =>
            FadeTransition(opacity: animation, child: child),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: AnimatedBuilder(
        animation: _exitCtrl,
        builder: (context, _) {
          return Container(
            color: _bg,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Center(
                  child: SingleChildScrollView(
                    clipBehavior: Clip.none,
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        FadeTransition(
                          opacity: _logoFade,
                          child: const CompassBrandIntro(
                            size: 260,
                            totalDuration: Duration(milliseconds: 4200),
                            loop: false,
                            spinCompass: true,
                            compassSpinDuration: Duration(seconds: 18),
                          ),
                        ),
                        const SizedBox(height: 24),
                        FadeTransition(
                          opacity: _taglineFade,
                          child: SlideTransition(
                            position: _taglineSlide,
                            child: const Column(
                              children: [
                                Text(
                                  'Discover the unseen',
                                  style: TextStyle(
                                    color: _letterColor,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    letterSpacing: 1.0,
                                  ),
                                ),
                                SizedBox(height: 6),
                                Text(
                                  'Stories of Alexandria',
                                  style: TextStyle(
                                    color: Color(0xFF8C7B5E),
                                    fontSize: 13,
                                    fontWeight: FontWeight.w400,
                                    letterSpacing: 0.8,
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
                Positioned(
                  bottom: 50,
                  left: 0,
                  right: 0,
                  child: FadeTransition(
                    opacity: _taglineFade,
                    child: Center(
                      child: SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: _letterColor.withValues(alpha: 0.4),
                        ),
                      ),
                    ),
                  ),
                ),
                if (_exitCtrl.value > 0)
                  Positioned.fill(
                    child: IgnorePointer(
                      child: Container(
                        color: _letterColor.withValues(
                          alpha: _exitCtrl.value * 0.85,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
