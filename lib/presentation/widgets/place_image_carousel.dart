import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

/// A swipable horizontal image carousel for places with multiple
/// official images. Falls back to a single static image when
/// [images] has only one entry (no carousel UI, no indicator).
class PlaceImageCarousel extends StatefulWidget {
  final List<String> images;
  final BoxFit fit;
  final double height;
  final BorderRadius? borderRadius;

  /// Tag for the [Hero] wrapper. When the carousel has multiple images
  /// the hero wraps the currently visible page only.
  final Object? heroTag;

  /// Optional fallback icon shown when an image fails to load.
  final Widget? errorWidget;

  const PlaceImageCarousel({
    super.key,
    required this.images,
    this.fit = BoxFit.cover,
    this.height = 320,
    this.borderRadius,
    this.heroTag,
    this.errorWidget,
  });

  @override
  State<PlaceImageCarousel> createState() => _PlaceImageCarouselState();
}

class _PlaceImageCarouselState extends State<PlaceImageCarousel> {
  late final PageController _controller;
  int _index = 0;

  @override
  void initState() {
    super.initState();
    _controller = PageController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final urls = widget.images
        .where((u) => u.isNotEmpty)
        .toList(growable: false);

    if (urls.isEmpty) {
      return _placeholder();
    }
    if (urls.length == 1) {
      return _wrap(
        child: _imageAt(urls.first, heroTag: widget.heroTag, useHero: true),
      );
    }

    return _wrap(
      child: Stack(
        children: [
          PageView.builder(
            controller: _controller,
            itemCount: urls.length,
            onPageChanged: (i) => setState(() => _index = i),
            itemBuilder: (context, i) {
              // Only the currently visible page keeps the hero tag so
              // the page-to-page swipe is smooth.
              return _imageAt(
                urls[i],
                heroTag: i == 0 ? widget.heroTag : null,
                useHero: i == 0,
              );
            },
          ),
          // Page indicator dots at the bottom
          Positioned(
            bottom: 14,
            left: 0,
            right: 0,
            child: Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(urls.length, (i) {
                  final active = i == _index;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 220),
                    curve: Curves.easeOut,
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    width: active ? 22 : 7,
                    height: 7,
                    decoration: BoxDecoration(
                      color: active
                          ? Colors.white
                          : Colors.white.withValues(alpha: 0.4),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  );
                }),
              ),
            ),
          ),
          // Counter chip (top-right)
          Positioned(
            top: 12,
            right: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 9,
                vertical: 4,
              ),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.55),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.2),
                ),
              ),
              child: Text(
                '${_index + 1} / ${urls.length}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _wrap({required Widget child}) {
    if (widget.borderRadius != null) {
      return ClipRRect(
        borderRadius: widget.borderRadius!,
        child: SizedBox(
          width: double.infinity,
          height: widget.height,
          child: child,
        ),
      );
    }
    return SizedBox(
      width: double.infinity,
      height: widget.height,
      child: child,
    );
  }

  Widget _imageAt(
    String url, {
    required Object? heroTag,
    required bool useHero,
  }) {
    Widget img = CachedNetworkImage(
      imageUrl: url,
      fit: widget.fit,
      placeholder: (_, __) => Container(color: Colors.black12),
      errorWidget: (_, __, ___) =>
          widget.errorWidget ??
          Container(
            color: Colors.black12,
            child: const Center(
              child: Icon(
                Icons.broken_image_rounded,
                color: Colors.white38,
                size: 60,
              ),
            ),
          ),
    );
    if (useHero && heroTag != null) {
      img = Hero(tag: heroTag, child: img);
    }
    return img;
  }

  Widget _placeholder() {
    return SizedBox(
      width: double.infinity,
      height: widget.height,
      child: Container(
        color: Colors.black12,
        child: const Center(
          child: Icon(
            Icons.image_not_supported_rounded,
            color: Colors.white38,
            size: 48,
          ),
        ),
      ),
    );
  }
}
