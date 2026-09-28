import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import 'robust_image.dart';



class ShimmerImage extends StatelessWidget {
  final String imageUrl;
  final BoxFit fit;
  final BorderRadius? borderRadius;
  final IconData fallbackIcon;
  final Color? fallbackColor;
  final double fallbackIconSize;

  const ShimmerImage({
    super.key,
    required this.imageUrl,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.fallbackIcon = Icons.image_outlined,
    this.fallbackColor,
    this.fallbackIconSize = 40,
  });

  @override
  Widget build(BuildContext context) {
    return RobustImage(
      imageUrl: imageUrl,
      fit: fit,
      borderRadius: borderRadius,
      fallbackIcon: fallbackIcon,
      fallbackColor: fallbackColor,
      fallbackIconSize: fallbackIconSize,
      memCacheWidth: 720,
      memCacheHeight: 720,
    );
  }
}

class ShimmerCardPlaceholder extends StatelessWidget {
  final double height;
  final double imageHeight;
  final bool dark;

  const ShimmerCardPlaceholder({
    super.key,
    this.height = 220,
    this.imageHeight = 130,
    this.dark = false,
  });

  @override
  Widget build(BuildContext context) {
    final base = dark ? const Color(0xFF2D3748) : const Color(0xFFE2E8F0);
    final highlight = dark ? const Color(0xFF4A5568) : const Color(0xFFF8FAFC);
    return Shimmer.fromColors(
      baseColor: base,
      highlightColor: highlight,
      period: const Duration(milliseconds: 1400),
      child: Container(
        height: height,
        decoration: BoxDecoration(
          color: base,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: imageHeight,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(18),
                  topRight: Radius.circular(18),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 180,
                      height: 14,
                      color: Colors.white,
                      margin: const EdgeInsets.only(bottom: 8),
                    ),
                    Container(
                      width: double.infinity,
                      height: 10,
                      color: Colors.white,
                      margin: const EdgeInsets.only(bottom: 6),
                    ),
                    Container(
                      width: 220,
                      height: 10,
                      color: Colors.white,
                      margin: const EdgeInsets.only(bottom: 12),
                    ),
                    Row(
                      children: [
                        Container(
                          width: 60,
                          height: 22,
                          color: Colors.white,
                          margin: const EdgeInsets.only(right: 6),
                        ),
                        Container(width: 70, height: 22, color: Colors.white),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
