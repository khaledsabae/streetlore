import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../logic/locale_provider.dart';
import '../../core/animations/app_animations.dart';
import '../../core/constants/app_colors.dart';
import '../../core/services/best_time_service.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/animated_stars.dart';
import '../../core/widgets/shimmer_image.dart';
import '../../data/models/place_model.dart';
import '../../l10n/app_strings.dart';

class PlaceCard extends StatefulWidget {
  final PlaceModel place;
  final VoidCallback? onTap;

  const PlaceCard({super.key, required this.place, this.onTap});

  @override
  State<PlaceCard> createState() => _PlaceCardState();
}

class _PlaceCardState extends State<PlaceCard> {
  @override
  Widget build(BuildContext context) {
    return Consumer<LocaleProvider>(
      builder: (context, locale, _) {
        return PressScale(
          onTap: () {
            HapticFeedback.lightImpact();
            widget.onTap?.call();
          },
          pressedScale: 0.97,
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 7),
            decoration: BoxDecoration(
              color: context.cardColor,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.07),
                  blurRadius: 16,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildImage(),
                Expanded(child: _buildDetails(locale.locale.languageCode)),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildImage() {
    return Hero(
      tag: 'place-image-${widget.place.id}',
      flightShuttleBuilder: _imageFlight,
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          bottomLeft: Radius.circular(20),
        ),
        child: SizedBox(
          width: 115,
          height: 130,
          child: Stack(
            fit: StackFit.expand,
            children: [
              ShimmerImage(
                imageUrl: widget.place.imageUrl,
                fit: BoxFit.cover,
                fallbackIcon: Icons.broken_image_rounded,
                fallbackColor: AppColors.textHint,
                fallbackIconSize: 32,
              ),
              Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft,
                    colors: [Colors.transparent, Color(0x220F172A)],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _imageFlight(
    BuildContext flightContext,
    Animation<double> animation,
    HeroFlightDirection flightDirection,
    BuildContext fromHeroContext,
    BuildContext toHeroContext,
  ) {
    final toHero = toHeroContext.widget as Hero;
    return Material(color: Colors.transparent, child: toHero.child);
  }

  Widget _nameFlight(
    BuildContext flightContext,
    Animation<double> animation,
    HeroFlightDirection flightDirection,
    BuildContext fromHeroContext,
    BuildContext toHeroContext,
  ) {
    return DefaultTextStyle(
      style: DefaultTextStyle.of(toHeroContext).style,
      child: (toHeroContext.widget as Hero).child,
    );
  }

  Widget _categoryFlight(
    BuildContext flightContext,
    Animation<double> animation,
    HeroFlightDirection flightDirection,
    BuildContext fromHeroContext,
    BuildContext toHeroContext,
  ) {
    return Material(
      type: MaterialType.transparency,
      child: (toHeroContext.widget as Hero).child,
    );
  }

  Widget _buildDetails(String localeCode) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Hero(
                tag: 'place-category-${widget.place.id}',
                flightShuttleBuilder: _categoryFlight,
                child: Material(
                  type: MaterialType.transparency,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      widget.place
                          .localizedCategory(localeCode)
                          .toUpperCase(),
                      style: TextStyle(
                        color: AppColors.primary,
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 6),
              _PriceChip(
                level: widget.place.priceLevel,
                localEgp: widget.place.priceLocalEgp,
                foreignerEgp: widget.place.priceForeignerEgp,
              ),
            ],
          ),
          const SizedBox(height: 7),
          Hero(
            tag: 'place-name-${widget.place.id}',
            flightShuttleBuilder: _nameFlight,
            child: Material(
              type: MaterialType.transparency,
              child: Text(
                widget.place.localizedName(localeCode),
                style: AppTextStyles.placeName.copyWith(color: context.textPri),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
          const SizedBox(height: 5),

          Text(
            widget.place.localizedDescription(localeCode),
            style: AppTextStyles.placeDescription,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),
          _BestTimeHint(place: widget.place),
          const SizedBox(height: 8),

          Row(
            children: [
              AnimatedStars(
                rating: widget.place.rating,
                size: 13,
                color: AppColors.ratingGold,
              ),
              const SizedBox(width: 5),
              Text(
                widget.place.rating.toStringAsFixed(1),
                style: TextStyle(
                  color: context.textPri,
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                ),
              ),
              const Spacer(),
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: Colors.white,
                  size: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PriceChip extends StatelessWidget {
  final PriceLevel level;
  final int? localEgp;
  final int? foreignerEgp;
  const _PriceChip({required this.level, this.localEgp, this.foreignerEgp});

  Color get _bg {
    switch (level) {
      case PriceLevel.free:
        return const Color(0xFF10B981);
      case PriceLevel.cheap:
        return const Color(0xFF14B8A6);
      case PriceLevel.moderate:
        return const Color(0xFFF59E0B);
      case PriceLevel.expensive:
        return const Color(0xFFEF4444);
    }
  }

  String get _label {
    if (level == PriceLevel.free) return 'FREE';
    if (localEgp != null && foreignerEgp != null) {
      return 'EGP $localEgp / $foreignerEgp';
    }
    switch (level) {
      case PriceLevel.cheap:
        return 'EGP 25-50';
      case PriceLevel.moderate:
        return 'EGP 50-150';
      case PriceLevel.expensive:
        return 'EGP 150+';
      case PriceLevel.free:
        return 'FREE';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: _bg.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            level == PriceLevel.free
                ? Icons.local_offer_rounded
                : Icons.payments_rounded,
            color: _bg,
            size: 10,
          ),
          const SizedBox(width: 4),
          Text(
            _label,
            style: TextStyle(
              color: _bg,
              fontSize: 9,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.4,
            ),
          ),
        ],
      ),
    );
  }
}

class _BestTimeHint extends StatelessWidget {
  final PlaceModel place;
  const _BestTimeHint({required this.place});

  @override
  Widget build(BuildContext context) {
    final rec = BestTimeService.instance.recommend(place);
    return Row(
      children: [
        Icon(rec.icon, color: rec.color, size: 12),
        const SizedBox(width: 4),
        Flexible(
          child: Text(
            '${context.tr(rec.labelKey)} · ${context.tr(rec.hintKey)}',
            style: TextStyle(
              color: rec.color,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
