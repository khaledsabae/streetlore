import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/animations/app_animations.dart';
import '../../core/constants/app_colors.dart';
import '../../logic/auth_provider.dart';
import 'onboarding_screen.dart';
import 'login_screen.dart';
import 'main_navigation.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late final AnimationController _logoCtrl;
  late final AnimationController _pulseCtrl;
  late final AnimationController _orbitCtrl;
  late final AnimationController _exitCtrl;

  late final Animation<double> _logoScale;
  late final Animation<double> _logoFade;
  late final Animation<double> _pulse;
  late final Animation<double> _orbit;
  late final Animation<Offset> _taglineSlide;
  late final Animation<double> _taglineFade;

  @override
  void initState() {
    super.initState();

    _logoCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1300),
    )..forward();

    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _orbitCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();

    _exitCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _logoScale = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(
          begin: 0.4,
          end: 1.12,
        ).chain(CurveTween(curve: Curves.easeOut)),
        weight: 60,
      ),
      TweenSequenceItem(
        tween: Tween(
          begin: 1.12,
          end: 1.0,
        ).chain(CurveTween(curve: Curves.easeInOut)),
        weight: 40,
      ),
    ]).animate(_logoCtrl);

    _logoFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _logoCtrl,
        curve: const Interval(0.0, 0.45, curve: Curves.easeIn),
      ),
    );
    _pulse = Tween<double>(
      begin: 1.0,
      end: 1.18,
    ).animate(CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut));
    _orbit = Tween<double>(
      begin: 0,
      end: 2 * pi,
    ).animate(CurvedAnimation(parent: _orbitCtrl, curve: Curves.linear));
    _taglineSlide = Tween<Offset>(begin: const Offset(0, 0.7), end: Offset.zero)
        .animate(
          CurvedAnimation(
            parent: _logoCtrl,
            curve: const Interval(0.5, 1.0, curve: Curves.easeOutCubic),
          ),
        );
    _taglineFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _logoCtrl, curve: const Interval(0.55, 1.0)),
    );

    Future.delayed(const Duration(milliseconds: 2700), _exitThenNavigate);
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
            PageTransitions.fadeScale(ctx, animation, second, child),
      ),
    );
  }

  @override
  void dispose() {
    _logoCtrl.dispose();
    _pulseCtrl.dispose();
    _orbitCtrl.dispose();
    _exitCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedGradientBackground(
        colorSets: const [
          [Color(0xFF0F172A), Color(0xFF1E3A5F)],
          [Color(0xFF0A0F1E), Color(0xFF312E81)],
          [Color(0xFF1E1B4B), Color(0xFF0F172A)],
        ],
        child: Stack(
          children: [
            const Positioned.fill(
              child: IgnorePointer(
                child: ParticleField(count: 28, color: Colors.white),
              ),
            ),
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AnimatedBuilder(
                    animation: Listenable.merge([
                      _logoCtrl,
                      _pulseCtrl,
                      _orbitCtrl,
                      _exitCtrl,
                    ]),
                    builder: (context, _) {
                      final exitProgress = _exitCtrl.value;
                      final scale =
                          _logoScale.value *
                          _pulse.value *
                          (1 - exitProgress * 0.4);
                      return Stack(
                        alignment: Alignment.center,
                        children: [
                          ..._buildOrbitDots(),
                          FadeTransition(
                            opacity: _logoFade,
                            child: Transform.scale(
                              scale: scale,
                              child: Container(
                                
                                
                                
                                width: 200,
                                height: 200,
                                foregroundDecoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white.withValues(
                                      alpha: 0.12,
                                    ),
                                    width: 2,
                                  ),
                                ),
                                child: ClipOval(
                                  child: Image.asset(
                                    'assets/logo/streetlore_logo.png',
                                    fit: BoxFit.cover,
                                    width: 200,
                                    height: 200,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 36),
                  FadeTransition(
                    opacity: _taglineFade,
                    child: SlideTransition(
                      position: _taglineSlide,
                      child: Column(
                        children: [
                          ShaderMask(
                            shaderCallback: (bounds) => const LinearGradient(
                              colors: [Colors.white, Color(0xFFE0E7FF)],
                            ).createShader(bounds),
                            child: const Text(
                              'Streetlore',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 42,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 1.2,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Discover the unseen',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.6),
                              fontSize: 15,
                              fontWeight: FontWeight.w400,
                              letterSpacing: 0.6,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              bottom: 60,
              left: 0,
              right: 0,
              child: FadeTransition(
                opacity: _taglineFade,
                child: Center(
                  child: SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white.withValues(alpha: 0.45),
                    ),
                  ),
                ),
              ),
            ),
            if (_exitCtrl.value > 0)
              Positioned.fill(
                child: IgnorePointer(
                  child: Container(
                    color: AppColors.primary.withValues(
                      alpha: _exitCtrl.value * 0.85,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildOrbitDots() {
    final dots = <Widget>[];
    const count = 6;
    final angle = _orbit.value;
    for (var i = 0; i < count; i++) {
      final a = angle + (i * 2 * pi / count);
      final r = 90.0;
      dots.add(
        Positioned(
          left: 130 / 2 + cos(a) * r - 4,
          top: 130 / 2 + sin(a) * r - 4,
          child: FadeTransition(
            opacity: _logoFade,
            child: Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.6),
                boxShadow: [
                  BoxShadow(
                    color: Colors.white.withValues(alpha: 0.4),
                    blurRadius: 6,
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }
    return dots;
  }
}
