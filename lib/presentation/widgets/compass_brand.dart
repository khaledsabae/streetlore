import 'dart:math' as math;

import 'package:flutter/material.dart';

class CompassBrandIntro extends StatefulWidget {
  final double size;

  /// Total intro length. The orbit phase takes ~70% and the morph from
  /// orbit into a horizontal "STREETLORE" line takes the remaining 30%.
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

  // Aspect ratio of the cropped compass image (920 wide x 700 tall).
  static const double _imageAspect = 700 / 920;

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
    final imageWidth = widget.size;
    final imageHeight = imageWidth * _imageAspect;
    // Reserve vertical space below the image for the final assembled line.
    final bottomReserve = widget.size * 0.22;
    final totalHeight = imageHeight + bottomReserve;

    return AnimatedBuilder(
      animation: Listenable.merge([_ctrl, _compassSpinCtrl]),
      builder: (context, _) {
        return SizedBox(
          width: widget.size,
          height: totalHeight,
          child: Stack(
            alignment: Alignment.topCenter,
            children: [
              if (widget.spinCompass)
                Positioned(
                  top: 0,
                  child: RotationTransition(
                    turns: _compassSpinCtrl,
                    child: Image.asset(
                      'assets/images/compass_only.png',
                      width: imageWidth,
                      height: imageHeight,
                      fit: BoxFit.contain,
                    ),
                  ),
                )
              else
                Positioned(
                  top: 0,
                  child: Image.asset(
                    'assets/images/compass_only.png',
                    width: imageWidth,
                    height: imageHeight,
                    fit: BoxFit.contain,
                  ),
                ),
              CustomPaint(
                size: Size(widget.size, totalHeight),
                painter: _LettersPainter(
                  progress: _ctrl.value,
                  imageHeight: imageHeight,
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
  final double imageHeight;

  static const String _text = 'STREETLORE';
  static const Color _color = Color(0xFF1F3A5F);

  _LettersPainter({required this.progress, required this.imageHeight});

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

    // Fade letters in over the first 22% of the animation.
    final fadeIn = (progress / 0.22).clamp(0.0, 1.0);
    if (fadeIn <= 0) return;

    // Orbit center sits at the visual center of the compass image.
    final orbitCenter = Offset(size.width / 2, imageHeight / 2);
    final orbitRadius = size.width * 0.36;

    // Final assembled-line position (below the compass image).
    final finalY = imageHeight + size.width * 0.13;
    final letterSpacing = size.width * 0.92 / (n - 1);
    final firstX = (size.width - letterSpacing * (n - 1)) / 2;

    // Animation phase split: 0..0.70 orbit, 0.70..1.00 morph.
    const orbitEnd = 0.70;
    final isMorph = progress >= orbitEnd;
    final morphT = isMorph ? (progress - orbitEnd) / (1.0 - orbitEnd) : 0.0;

    // Live orbit base angle (only used during the orbit phase).
    final liveBaseAngle = progress * 2 * math.pi * 1.2;
    // Frozen orbit base angle at the moment the morph begins.
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
        // Pure orbit phase: letter keeps moving around the compass.
        final angle =
            -math.pi / 2 + i * (2 * math.pi / n) + liveBaseAngle + phaseOffset;
        x = orbitCenter.dx + orbitRadius * math.cos(angle);
        y = orbitCenter.dy + orbitRadius * math.sin(angle);
        // Letter radial outward (pointing away from orbit center).
        rotation = _normalizeAngle(angle + math.pi / 2);
      } else {
        // Morph phase: lerp position from orbit snapshot to final line.
        final eased = Curves.easeOutCubic.transform(morphT);
        x = morphStartX + (finalX - morphStartX) * eased;
        y = morphStartY + (finalY - morphStartY) * eased;
        // Rotation: from radial-outward to upright (shortest path).
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
  bool shouldRepaint(covariant _LettersPainter old) =>
      old.progress != progress || old.imageHeight != imageHeight;
}
