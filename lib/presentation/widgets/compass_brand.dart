import 'dart:math' as math;

import 'package:flutter/material.dart';

class CompassBrand extends StatefulWidget {
  final double size;
  final bool showOrbitingLetters;
  final bool spin;
  final Duration spinDuration;
  final Duration letterDuration;

  const CompassBrand({
    super.key,
    this.size = 200,
    this.showOrbitingLetters = true,
    this.spin = true,
    this.spinDuration = const Duration(seconds: 14),
    this.letterDuration = const Duration(seconds: 8),
  });

  @override
  State<CompassBrand> createState() => _CompassBrandState();
}

class _CompassBrandState extends State<CompassBrand>
    with TickerProviderStateMixin {
  late final AnimationController _spinCtrl;
  late final AnimationController _lettersCtrl;

  @override
  void initState() {
    super.initState();
    _spinCtrl = AnimationController(
      vsync: this,
      duration: widget.spinDuration,
    );
    _lettersCtrl = AnimationController(
      vsync: this,
      duration: widget.letterDuration,
    );
    if (widget.spin) _spinCtrl.repeat();
    if (widget.showOrbitingLetters) _lettersCtrl.repeat();
  }

  @override
  void dispose() {
    _spinCtrl.dispose();
    _lettersCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: AnimatedBuilder(
        animation: Listenable.merge([_spinCtrl, _lettersCtrl]),
        builder: (context, _) {
          return Stack(
            alignment: Alignment.center,
            children: [
              if (widget.spin)
                RotationTransition(
                  turns: _spinCtrl,
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
              if (widget.showOrbitingLetters)
                CustomPaint(
                  size: Size(widget.size, widget.size),
                  painter: _CircularLettersPainter(
                    angle: _lettersCtrl.value * 2 * math.pi,
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _CircularLettersPainter extends CustomPainter {
  final double angle;
  _CircularLettersPainter({required this.angle});

  static const String _text = 'STREETLORE';
  static const Color _color = Color(0xFF1F3A5F);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 14;

    final n = _text.length;
    final angleStep = 2 * math.pi / n;

    for (int i = 0; i < n; i++) {
      final phase = i * 0.6;
      final letterAngle =
          -math.pi / 2 + i * angleStep + angle + phase * 0.05;

      final x = center.dx + radius * math.cos(letterAngle);
      final y = center.dy + radius * math.sin(letterAngle);

      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(letterAngle + math.pi / 2);

      final tp = TextPainter(
        text: TextSpan(
          text: _text[i],
          style: const TextStyle(
            color: _color,
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
  bool shouldRepaint(covariant _CircularLettersPainter old) =>
      old.angle != angle;
}
