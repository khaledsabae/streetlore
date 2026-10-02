import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../core/constants/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../data/models/journal_entry.dart';
import '../../data/models/place_model.dart';
import '../../l10n/app_strings.dart';
import '../../logic/journal_provider.dart';
import '../../logic/place_provider.dart';
import 'place_details_screen.dart';

class JournalScreen extends StatelessWidget {
  const JournalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.bgColor,
      appBar: AppBar(
        title: Text(context.tr('travel_journal')),
        backgroundColor: context.bgColor,
        elevation: 0,
      ),
      body: Consumer<JournalProvider>(
        builder: (context, journal, _) {
          if (journal.entries.isEmpty) {
            return _EmptyState(
              onPick: () => _showPlacePicker(context, journal),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
            physics: const BouncingScrollPhysics(),
            itemCount: journal.entries.length,
            itemBuilder: (context, i) {
              final e = journal.entries[i];
              return _JournalCard(
                entry: e,
                onTap: () {
                  final p = context.read<PlaceProvider>().findById(e.placeId);
                  if (p != null) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => PlaceDetailsScreen(place: p),
                      ),
                    );
                  }
                },
                onEdit: () => _showEditor(context, journal, e),
                onDelete: () => journal.remove(e.id),
              );
            },
          );
        },
      ),
      floatingActionButton: Consumer<JournalProvider>(
        builder: (context, journal, _) {
          return FloatingActionButton.extended(
            onPressed: () => _showPlacePicker(context, journal),
            backgroundColor: AppColors.primary,
            icon: const Icon(Icons.add_rounded, color: Colors.white),
            label: Text(
              context.tr('journal_add_memory'),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
              ),
            ),
          );
        },
      ),
    );
  }

  static Future<void> _showPlacePicker(
    BuildContext context,
    JournalProvider journal,
  ) async {
    final places = context.read<PlaceProvider>().places;
    final picked = await showModalBottomSheet<PlaceModel>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return _PlacePickerSheet(places: places);
      },
    );
    if (picked != null && context.mounted) {
      _showEditor(context, journal, null, place: picked);
    }
  }

  static Future<void> _showEditor(
    BuildContext context,
    JournalProvider journal,
    JournalEntry? existing, {
    PlaceModel? place,
  }) async {
    final place0 =
        place ??
        context.read<PlaceProvider>().findById(existing?.placeId ?? '');
    if (place0 == null) return;
    final result = await showModalBottomSheet<JournalEntry>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _JournalEditorSheet(place: place0, existing: existing),
    );
    if (result != null) {
      if (existing == null) {
        await journal.add(result);
      } else {
        await journal.update(result);
      }
    }
  }
}

class _EmptyState extends StatelessWidget {
  final VoidCallback onPick;
  const _EmptyState({required this.onPick});
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.menu_book_rounded,
                size: 40,
                color: context.textPri,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              context.tr('journal_empty_title'),
              style: TextStyle(
                color: context.textPri,
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              context.tr('journal_empty_sub'),
              textAlign: TextAlign.center,
              style: TextStyle(
                color: context.textSec,
                fontSize: 13,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onPick,
              icon: const Icon(Icons.add_rounded),
              label: Text(context.tr('journal_add_first')),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 14,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _JournalCard extends StatelessWidget {
  final JournalEntry entry;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _JournalCard({
    required this.entry,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  String _dateLabel(BuildContext context, DateTime d) {
    final now = DateTime.now();
    final diff = now.difference(d);
    if (diff.inDays == 0) return context.tr('journal_today');
    if (diff.inDays == 1) return context.tr('journal_yesterday');
    if (diff.inDays < 7) {
      return context.tr('journal_days_ago', {'n': '${diff.inDays}'});
    }
    return '${d.day}/${d.month}/${d.year}';
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: context.cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: context.hintColor.withValues(alpha: 0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        entry.placeName,
                        style: TextStyle(
                          color: context.textPri,
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _dateLabel(context, entry.visitedAt),
                        style: TextStyle(
                          color: context.textSec,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                Row(
                  children: List.generate(5, (i) {
                    return Icon(
                      i < entry.rating
                          ? Icons.star_rounded
                          : Icons.star_outline_rounded,
                      size: 16,
                      color: const Color(0xFFFBBF24),
                    );
                  }),
                ),
                PopupMenuButton<String>(
                  icon: Icon(Icons.more_vert_rounded, color: context.hintColor),
                  onSelected: (v) {
                    if (v == 'edit') onEdit();
                    if (v == 'delete') onDelete();
                  },
                  itemBuilder: (_) => [
                    PopupMenuItem(
                      value: 'edit',
                      child: Text(context.tr('edit')),
                    ),
                    PopupMenuItem(
                      value: 'delete',
                      child: Text(context.tr('delete')),
                    ),
                  ],
                ),
              ],
            ),
            if (entry.note != null && entry.note!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                entry.note!,
                style: TextStyle(
                  color: context.textPri,
                  fontSize: 13,
                  height: 1.5,
                ),
                maxLines: 4,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _PlacePickerSheet extends StatefulWidget {
  final List<PlaceModel> places;
  const _PlacePickerSheet({required this.places});
  @override
  State<_PlacePickerSheet> createState() => _PlacePickerSheetState();
}

class _PlacePickerSheetState extends State<_PlacePickerSheet> {
  final _search = TextEditingController();

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final term = _search.text.toLowerCase().trim();
    bool matches(String? s) =>
        s != null && s.toLowerCase().contains(term);
    final filtered = term.isEmpty
        ? widget.places
        : widget.places
              .where(
                (p) =>
                    matches(p.nameEn) ||
                    matches(p.nameAr) ||
                    matches(p.descriptionEn) ||
                    matches(p.descriptionAr),
              )
              .toList();
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.85,
      maxChildSize: 0.95,
      builder: (context, scroll) {
        return Container(
          decoration: BoxDecoration(
            color: context.bgColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              const SizedBox(height: 10),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: context.hintColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 14),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        context.tr('journal_pick_place'),
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close_rounded),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: TextField(
                  controller: _search,
                  onChanged: (_) => setState(() {}),
                  decoration: InputDecoration(
                    hintText: context.tr('journal_search_hint'),
                    prefixIcon: const Icon(Icons.search_rounded),
                    filled: true,
                    fillColor: context.cardColor,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              const SizedBox(height: 12),
              Expanded(
                child: ListView.builder(
                  controller: scroll,
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                  itemCount: filtered.length,
                  itemBuilder: (context, i) {
                    final p = filtered[i];
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: CachedNetworkImage(
                          imageUrl: p.imageUrl,
                          width: 48,
                          height: 48,
                          fit: BoxFit.cover,
                          memCacheWidth: 96,
                          memCacheHeight: 96,
                          httpHeaders: const {
                            'User-Agent':
                                'Mozilla/5.0 (iPhone; CPU iPhone OS 17_0 like Mac OS X) AppleWebKit/605.1.15',
                          },
                          placeholder: (_, __) => Container(
                            width: 48,
                            height: 48,
                            color: context.bgAlt,
                          ),
                          errorWidget: (context, url, error) => Container(
                            color: const Color(0xFF1C2433),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.image_rounded,
                                  color: Colors.white30,
                                  size: 36,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      title: Text(
                        p.localizedName(
                          Localizations.localeOf(context).languageCode,
                        ),
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                      subtitle: Text(
                        p.localizedCategory(
                          Localizations.localeOf(context).languageCode,
                        ),
                      ),
                      onTap: () {
                        HapticFeedback.lightImpact();
                        Navigator.pop(context, p);
                      },
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

class _JournalEditorSheet extends StatefulWidget {
  final PlaceModel place;
  final JournalEntry? existing;
  const _JournalEditorSheet({required this.place, this.existing});

  @override
  State<_JournalEditorSheet> createState() => _JournalEditorSheetState();
}

class _JournalEditorSheetState extends State<_JournalEditorSheet> {
  late TextEditingController _noteCtrl;
  late int _rating;
  late DateTime _visitedAt;

  @override
  void initState() {
    super.initState();
    _noteCtrl = TextEditingController(text: widget.existing?.note ?? '');
    _rating = widget.existing?.rating ?? 5;
    _visitedAt = widget.existing?.visitedAt ?? DateTime.now();
  }

  @override
  void dispose() {
    _noteCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.7,
        maxChildSize: 0.95,
        builder: (context, scroll) {
          return Container(
            decoration: BoxDecoration(
              color: context.bgColor,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(24),
              ),
            ),
            child: ListView(
              controller: scroll,
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 24),
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: context.hintColor,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  widget.existing == null
                      ? context.tr('journal_new_memory')
                      : context.tr('journal_edit_memory'),
                  style: AppTextStyles.screenTitle.copyWith(
                    color: context.textPri,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.place.localizedName(
                    Localizations.localeOf(context).languageCode,
                  ),
                  style: TextStyle(
                    color: context.textSec,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  context.tr('rating_label'),
                  style: AppTextStyles.sectionTitle.copyWith(
                    color: context.textPri,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: List.generate(5, (i) {
                    return IconButton(
                      onPressed: () => setState(() => _rating = i + 1),
                      icon: Icon(
                        i < _rating
                            ? Icons.star_rounded
                            : Icons.star_outline_rounded,
                        size: 32,
                        color: const Color(0xFFFBBF24),
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 12),
                Text(
                  context.tr('journal_notes'),
                  style: AppTextStyles.sectionTitle.copyWith(
                    color: context.textPri,
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _noteCtrl,
                  maxLines: 6,
                  decoration: InputDecoration(
                    hintText: context.tr('journal_note_hint'),
                    filled: true,
                    fillColor: context.cardColor,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(color: context.hintColor),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(
                        color: context.hintColor.withValues(alpha: 0.3),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  height: 52,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      final entry = JournalEntry(
                        id: widget.existing?.id ?? const Uuid().v4(),
                        placeId: widget.place.id,
                        placeName: widget.place.localizedName(
                          Localizations.localeOf(context).languageCode,
                        ),
                        note: _noteCtrl.text.trim().isEmpty
                            ? null
                            : _noteCtrl.text.trim(),
                        visitedAt: _visitedAt,
                        rating: _rating,
                      );
                      Navigator.pop(context, entry);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    icon: const Icon(Icons.check_rounded, color: Colors.white),
                    label: Text(
                      widget.existing == null
                          ? context.tr('journal_save_memory')
                          : context.tr('journal_update_memory'),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
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
