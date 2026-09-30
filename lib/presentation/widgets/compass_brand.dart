import 'dart:math' as math;

import 'package:flutter/material.dart';

class CompassBrandIntro extends StatefulWidget {
  final double size;

  /// Total intro length. The orbit phase takes ~70% and the slide-down
  /// to assemble horizontally takes the remaining 30%.
  final Duration totalDuration;

  /// If true the intro restarts at the end. Splash uses one-shot;
  /// login screen keeps it looping so the logo animates every visit.
  final bool loop;

  /// If true, also keeps the compass rotating continuously.
  final bool spinCompass;

  /// Speed of the continuous compass rotation when [spinCompass] is true.
  final Duration compassSpinDuration;

  const CompassBrandIntro({
    super.key,
    this.size = 280,
    this.totalDuration = const Duration(milliseconds: 4200),
    this.loop = false,
    this.spinCompass = true,
    this.compassSpinDuration = const Duration(seconds: 18),
  });

  @override
  State<CompassBrandIntro> createState() => _CompassBrandIntroState();
}

class _CompassBrandIntroState extends State<CompassBrandIntro>
    with TickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final AnimationController _compassSpinCtrl;
  late final Animation<double> _orbitPhase;
  late final Animation<double> _slidePhase;
  late final Animation<double> _fadeIn;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: widget.totalDuration);
    if (widget.loop) {
      _ctrl.repeat();
    } else {
      _ctrl.forward();
    }
    _compassSpinCtrl = AnimationController(
      vsync: this,
      duration: widget.compassSpinDuration,
    );
    if (widget.spinCompass) _compassSpinCtrl.repeat();

    // 0 .. 0.70 = orbit phase
    // 0.70 .. 1.00 = slide + assemble horizontally
    _orbitPhase = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _ctrl,
        curve: const Interval(0.0, 0.7, curve: Curves.linear),
      ),
    );
    _slidePhase = CurvedAnimation(
      parent: _ctrl,
      curve: const Interval(0.7, 1.0, curve: Curves.easeOutCubic),
    );
    _fadeIn = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _ctrl, curve: const Interval(0.0, 0.25)),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _compassSpinCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_ctrl, _compassSpinCtrl]),
      builder: (context, _) {
        return SizedBox(
          width: widget.size,
          height: widget.size + 96,
          child: Stack(
            alignment: Alignment.topCenter,
            children: [
              // Compass with continuous spin
              Positioned(
                top: 0,
                child: SizedBox(
                  width: widget.size,
                  height: widget.size,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      if (widget.spinCompass)
                        RotationTransition(
                          turns: _compassSpinCtrl,
                          child: Image.asset(
                            'assets/images/compass_only.png',
                            width: widget.size,
                            height: widget.size,
                            fit: BoxFit.contain,
                          ),
                        )
                      else
                        Image.asset(
                          'assets/images/compass_only.png',
                          width: widget.size,
                          height: widget.size,
                          fit: BoxFit.contain,
                        ),
                      CustomPaint(
                        size: Size(widget.size, widget.size),
                        painter: _OrbitingLettersPainter(
                          orbitProgress: _orbitPhase.value,
                          fadeIn: _fadeIn.value,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Assembled word below the compass
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: AnimatedBuilder(
                  animation: _slidePhase,
                  builder: (context, _) {
                    final t = _slidePhase.value;
                    return Opacity(
                      opacity: t,
                      child: Transform.translate(
                        offset: Offset(0, (1 - t) * 24),
                        child: const Center(
                          child: Text(
                            'STREETLORE',
                            style: TextStyle(
                              color: Color(0xFF1F3A5F),
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 6,
                              fontFamily: 'serif',
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _OrbitingLettersPainter extends CustomPainter {
  final double orbitProgress;
  final double fadeIn;
  _OrbitingLettersPainter({required this.orbitProgress, required this.fadeIn});

  static const String _text = 'STREETLORE';
  static const Color _color = Color(0xFF1F3A5F);

  @override
  void paint(Canvas canvas, Size size) {
    if (fadeIn <= 0) return;
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 14;

    final n = _text.length;
    final angleStep = 2 * math.pi / n;
    final baseAngle = orbitProgress * 2 * math.pi * 1.2;

    for (int i = 0; i < n; i++) {
      final phase = i * 0.6;
      final letterAngle =
          -math.pi / 2 + i * angleStep + baseAngle + phase * 0.05;

      final x = center.dx + radius * math.cos(letterAngle);
      final y = center.dy + radius * math.sin(letterAngle);

      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(letterAngle + math.pi / 2);

      final tp = TextPainter(
        text: TextSpan(
          text: _text[i],
          style: TextStyle(
            color: _color.withValues(alpha: fadeIn),
            fontSize: 22,
            fontWeight: FontWeight.w700,
            letterSpacing: 2.2,
            fontFamily: 'serif',
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      tp.layout();
      tp.paint(canvas, Offset(-tp.width / 2, -tp.height / 2));
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _OrbitingLettersPainter old) =>
      old.orbitProgress != orbitProgress || old.fadeIn != fadeIn;
}
