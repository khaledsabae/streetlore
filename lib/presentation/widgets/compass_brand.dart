import 'dart:math' as math;

import 'package:flutter/material.dart';

class CompassBrandIntro extends StatefulWidget {
  final double size;
  final Duration totalDuration;
  final bool loop;
  final bool spinCompass;
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

  static const double _imageAspect = 486 / 660;
  static const double _compassScale = 0.58;

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
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _compassSpinCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final compassWidth = widget.size * _compassScale;
    final compassHeight = compassWidth * _imageAspect;

    // Diagonal of the compass image — the minimum square side needed so
    // a 360° rotation never clips any corner.
    final diagonal = math.sqrt(
      compassWidth * compassWidth + compassHeight * compassHeight,
    );
    // The spinning container is this square, centered on the compass center.
    final spinBoxSide = diagonal + 4; // +4 px safety margin

    final compassRadius = compassHeight / 2;
    final orbitRadius = compassRadius + 22;

    // Total widget height: enough for the spin box, orbit padding, and the
    // assembled-text strip at the bottom.
    final totalHeight = spinBoxSide + 2 * (orbitRadius - compassRadius) + 60;

    // Center of the compass inside the widget.
    final compassCenterY = totalHeight / 2;

    return AnimatedBuilder(
      animation: Listenable.merge([_ctrl, _compassSpinCtrl]),
      builder: (context, _) {
        return SizedBox(
          width: widget.size,
          height: totalHeight,
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              // ── Compass image (optionally spinning) ──
              Positioned(
                top: compassCenterY - spinBoxSide / 2,
                left: (widget.size - spinBoxSide) / 2,
                width: spinBoxSide,
                height: spinBoxSide,
                child: OverflowBox(
                  maxWidth: spinBoxSide,
                  maxHeight: spinBoxSide,
                  child: widget.spinCompass
                      ? Transform.rotate(
                          angle: _compassSpinCtrl.value * 2 * math.pi,
                          alignment: Alignment.center,
                          child: Center(
                            child: Image.asset(
                              'assets/images/compass_only.png',
                              width: compassWidth,
                              height: compassHeight,
                              fit: BoxFit.contain,
                            ),
                          ),
                        )
                      : Center(
                          child: Image.asset(
                            'assets/images/compass_only.png',
                            width: compassWidth,
                            height: compassHeight,
                            fit: BoxFit.contain,
                          ),
                        ),
                ),
              ),
              // ── Orbiting / morphing / fading letters ──
              Positioned.fill(
                child: CustomPaint(
                  painter: _LettersPainter(
                    progress: _ctrl.value,
                    orbitCenter: Offset(widget.size / 2, compassCenterY),
                    orbitRadius: orbitRadius,
                    totalHeight: totalHeight,
                    isLooping: widget.loop,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _LettersPainter extends CustomPainter {
  final double progress;
  final Offset orbitCenter;
  final double orbitRadius;
  final double totalHeight;
  final bool isLooping;

  static const String _text = 'STREETLORE';
  static const Color _color = Color(0xFF1F3A5F);
  static const double _letterFontSize = 22;

  _LettersPainter({
    required this.progress,
    required this.orbitCenter,
    required this.orbitRadius,
    required this.totalHeight,
    required this.isLooping,
  });

  static double _normalizeAngle(double a) {
    while (a > math.pi) {
      a -= 2 * math.pi;
    }
    while (a < -math.pi) {
      a += 2 * math.pi;
    }
    return a;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final n = _text.length;

    // ── Phase boundaries ──
    // When looping (login): orbit → morph → fade-out → (loop restarts)
    // When one-shot (splash): orbit → morph (letters stay visible)
    const orbitEnd = 0.55;
    const morphEnd = 0.80;
    // 0.80..1.00 = fade-out (only used when looping)

    final fadeIn = (progress / 0.18).clamp(0.0, 1.0);
    if (fadeIn <= 0) return;

    final isMorph = progress >= orbitEnd;
    final isFadeOut = isLooping && progress >= morphEnd;

    final morphT = isMorph && !isFadeOut
        ? ((progress - orbitEnd) / (morphEnd - orbitEnd)).clamp(0.0, 1.0)
        : isFadeOut
            ? 1.0
            : 0.0;

    // Fade-out alpha (only during Phase 3, only when looping)
    final fadeOutAlpha = isFadeOut
        ? 1.0 - ((progress - morphEnd) / (1.0 - morphEnd)).clamp(0.0, 1.0)
        : 1.0;

    // Combined alpha
    final alpha = fadeIn * fadeOutAlpha;
    if (alpha <= 0.001) return;

    final finalY = totalHeight - 32;
    final letterSpacing = size.width * 0.92 / (n - 1);
    final firstX = (size.width - letterSpacing * (n - 1)) / 2;

    final liveBaseAngle = progress * 2 * math.pi * 1.2;
    final morphBaseAngle = orbitEnd * 2 * math.pi * 1.2;

    for (int i = 0; i < n; i++) {
      final phaseOffset = i * 0.6 * 0.05;
      final morphStartAngle =
          -math.pi / 2 + i * (2 * math.pi / n) + morphBaseAngle + phaseOffset;
      final morphStartX =
          orbitCenter.dx + orbitRadius * math.cos(morphStartAngle);
      final morphStartY =
          orbitCenter.dy + orbitRadius * math.sin(morphStartAngle);

      final finalX = firstX + i * letterSpacing;

      double x;
      double y;
      double rotation;

      if (!isMorph) {
        final angle =
            -math.pi / 2 +
            i * (2 * math.pi / n) +
            liveBaseAngle +
            phaseOffset;
        x = orbitCenter.dx + orbitRadius * math.cos(angle);
        y = orbitCenter.dy + orbitRadius * math.sin(angle);
        rotation = _normalizeAngle(angle + math.pi / 2);
      } else {
        final eased = Curves.easeOutCubic.transform(morphT);
        x = morphStartX + (finalX - morphStartX) * eased;
        y = morphStartY + (finalY - morphStartY) * eased;
        final startRot = _normalizeAngle(morphStartAngle + math.pi / 2);
        rotation = startRot + (0.0 - startRot) * eased;
      }

      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(rotation);

      final tp = TextPainter(
        text: TextSpan(
          text: _text[i],
          style: TextStyle(
            color: _color.withValues(alpha: alpha),
            fontSize: _letterFontSize,
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
  bool shouldRepaint(covariant _LettersPainter old) =>
      old.progress != progress ||
      old.orbitCenter != orbitCenter ||
      old.orbitRadius != orbitRadius ||
      old.totalHeight != totalHeight ||
      old.isLooping != isLooping;
}
