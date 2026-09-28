import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/animated_icons.dart';
import '../../data/models/offline_pack.dart';
import '../../l10n/app_strings.dart';
import '../../logic/offline_provider.dart';
import '../../logic/place_provider.dart';

class OfflineModeScreen extends StatefulWidget {
  const OfflineModeScreen({super.key});

  @override
  State<OfflineModeScreen> createState() => _OfflineModeScreenState();
}

class _OfflineModeScreenState extends State<OfflineModeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<OfflineProvider>().init();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.bgColor,
      appBar: AppBar(title: Text(context.tr('offline_title'))),
      body: Consumer<OfflineProvider>(
        builder: (context, off, _) {
          final downloaded = off.packs;
          final available = OfflineProvider.catalog
              .where((p) => !downloaded.any((d) => d.id == p.id))
              .toList();
          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            physics: const BouncingScrollPhysics(),
            children: [
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF1E293B), Color(0xFF334155)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Padding(
                        padding: EdgeInsets.all(2),
                        child: AnimatedLottieIcon(
                          animation: LottieAnimations.cloud,
                          size: 40,
                          color: Colors.white,
                          secondaryColor: Color(0xFFCBD5E1),
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            context.tr('offline_hero_title'),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            context.tr('offline_mb_downloaded', {
                              'n': '${off.totalDownloadedMb}',
                            }),
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              if (downloaded.isNotEmpty) ...[
                Text(
                  context.tr('offline_downloaded'),
                  style: AppTextStyles.sectionTitle.copyWith(
                    color: context.textPri,
                  ),
                ),
                const SizedBox(height: 8),
                for (final p in downloaded) _DownloadedTile(pack: p),
                const SizedBox(height: 20),
              ],
              if (available.isNotEmpty) ...[
                Text(
                  context.tr('offline_available'),
                  style: AppTextStyles.sectionTitle.copyWith(
                    color: context.textPri,
                  ),
                ),
                const SizedBox(height: 8),
                for (final p in available) _AvailableTile(pack: p),
              ],
            ],
          );
        },
      ),
    );
  }
}

class _DownloadedTile extends StatelessWidget {
  final OfflinePack pack;
  const _DownloadedTile({required this.pack});
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.success.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          _PackIcon(emoji: pack.coverEmoji, downloaded: true),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  pack.name,
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 2),
                Text(
                  context.tr('offline_pack_size', {
                    'mb': '${pack.sizeMb}',
                    'n': '${pack.placeIds.length}',
                  }),
                  style: TextStyle(color: context.textSec, fontSize: 12),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => context.read<OfflineProvider>().remove(pack),
            icon: const Icon(
              Icons.delete_outline_rounded,
              color: AppColors.error,
            ),
            tooltip: context.tr('delete'),
          ),
        ],
      ),
    );
  }
}

class _AvailableTile extends StatefulWidget {
  final OfflinePack pack;
  const _AvailableTile({required this.pack});

  @override
  State<_AvailableTile> createState() => _AvailableTileState();
}

class _AvailableTileState extends State<_AvailableTile> {
  bool _downloading = false;

  Future<void> _onDownload() async {
    if (_downloading) return;
    setState(() => _downloading = true);
    final messenger = ScaffoldMessenger.of(context);
    final provider = context.read<OfflineProvider>();
    final placeProvider = context.read<PlaceProvider>();
    try {
      
      
      if (placeProvider.loading) {
        await placeProvider.ensureLoaded();
      }

      
      
      
      var places = placeProvider.places;
      if (places.length < 5) {
        final fresh = await provider.pullAllPlacesFromSupabase();
        if (fresh.isNotEmpty) {
          places = fresh;
        }
      }

      
      
      
      final result = await provider.download(
        widget.pack,
        availablePlaces: places,
      );

      if (!mounted) return;
      switch (result) {
        case DownloadOk ok:
          messenger.showSnackBar(
            SnackBar(
              backgroundColor: AppColors.success,
              duration: const Duration(seconds: 4),
              content: Text(
                ok.cachedCount == 1
                    ? 'Saved 1 place • ${ok.imagesOk} images cached offline'
                    : 'Saved ${ok.cachedCount} places • '
                        '${ok.imagesOk} images cached offline'
                        '${ok.imagesFailed > 0 ? ' • ${ok.imagesFailed} failed' : ''}',
              ),
            ),
          );
        case DownloadEmpty():
          messenger.showSnackBar(
            SnackBar(
              content: Text(context.tr('offline_no_places')),
              backgroundColor: AppColors.error,
            ),
          );
      }
    } catch (e) {
      if (!mounted) return;
      messenger.showSnackBar(
        SnackBar(
          content: Text('Download failed: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    } finally {
      if (mounted) setState(() => _downloading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final pack = widget.pack;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: context.hintColor.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          _PackIcon(emoji: pack.coverEmoji, downloaded: false),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  pack.name,
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 2),
                Text(
                  pack.description,
                  style: TextStyle(color: context.textSec, fontSize: 12),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  context.tr('offline_pack_size', {
                    'mb': '${pack.sizeMb}',
                    'n': '${pack.placeIds.length}',
                  }),
                  style: TextStyle(color: context.hintColor, fontSize: 11),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: _downloading ? null : _onDownload,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              disabledBackgroundColor: AppColors.primary.withValues(alpha: 0.5),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: _downloading
                ? const SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : Text(
                    context.tr('offline_download'),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 12,
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

class _PackIcon extends StatelessWidget {
  final String emoji;
  final bool downloaded;
  const _PackIcon({required this.emoji, required this.downloaded});
  @override
  Widget build(BuildContext context) {
    final icon = _iconFor(emoji);
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: (downloaded ? AppColors.success : AppColors.primary).withValues(
          alpha: 0.12,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(
        icon,
        color: downloaded ? AppColors.success : AppColors.primary,
        size: 24,
      ),
    );
  }

  IconData _iconFor(String e) {
    if (e.contains('book') || e.contains('read')) {
      return Icons.menu_book_rounded;
    }
    if (e.contains('museum') || e.contains('pillar') || e.contains('castle')) {
      return Icons.account_balance_rounded;
    }
    if (e.contains('food') || e.contains('restaurant') || e.contains('cafe')) {
      return Icons.restaurant_rounded;
    }
    if (e.contains('beach') || e.contains('sea') || e.contains('wave')) {
      return Icons.beach_access_rounded;
    }
    return Icons.location_on_rounded;
  }
}
