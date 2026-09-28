import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/constants/app_colors.dart';
import '../../core/services/geocoding_service.dart';
import '../../core/theme/app_text_styles.dart';
import '../../l10n/app_strings.dart';
import '../../logic/auth_provider.dart';
import '../../logic/place_provider.dart';















class AdminPanelScreen extends StatefulWidget {
  const AdminPanelScreen({super.key});

  @override
  State<AdminPanelScreen> createState() => _AdminPanelScreenState();
}

class _AdminPanelScreenState extends State<AdminPanelScreen> {
  bool _showForm = false;

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    if (!auth.isAdmin) {
      return Scaffold(
        backgroundColor: context.bgColor,
        appBar: AppBar(title: Text(context.tr('admin_title'))),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.lock_outline_rounded,
                  size: 56,
                  color: context.textSec,
                ),
                const SizedBox(height: 12),
                Text(
                  context.tr('admin_forbidden'),
                  textAlign: TextAlign.center,
                  style: AppTextStyles.sectionTitle,
                ),
                const SizedBox(height: 8),
                Text(
                  context.tr('admin_forbidden_sub'),
                  textAlign: TextAlign.center,
                  style: TextStyle(color: context.textSec, fontSize: 13),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: context.bgColor,
      appBar: AppBar(
        title: Text(context.tr('admin_title')),
        actions: [
          IconButton(
            icon: Icon(_showForm ? Icons.list_rounded : Icons.add_rounded),
            tooltip: _showForm
                ? context.tr('admin_view_list')
                : context.tr('admin_add_new'),
            onPressed: () => setState(() => _showForm = !_showForm),
          ),
        ],
      ),
      body: _showForm ? const _AddPlaceForm() : const _PlacesList(),
    );
  }
}

class _PlacesList extends StatelessWidget {
  const _PlacesList();

  @override
  Widget build(BuildContext context) {
    final places = context.watch<PlaceProvider>().places;
    return RefreshIndicator(
      onRefresh: () async {
        await context.read<PlaceProvider>().refresh();
      },
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        itemCount: places.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (context, i) {
          final p = places[i];
          return Container(
            decoration: BoxDecoration(
              color: context.cardColor,
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: _categoryColor(p.category).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    _categoryEmoji(p.category),
                    style: const TextStyle(fontSize: 20),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        p.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${p.category} • ${p.address}',
                        style: TextStyle(
                          color: context.textSec,
                          fontSize: 11,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        'id=${p.id} lat=${p.lat.toStringAsFixed(4)} '
                        'lng=${p.lng.toStringAsFixed(4)}',
                        style: TextStyle(
                          color: context.hintColor,
                          fontSize: 10,
                          fontFamily: 'monospace',
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Color _categoryColor(String c) {
    final cc = c.toLowerCase();
    if (cc.contains('atm')) return Colors.green;
    if (cc.contains('hotel')) return Colors.purple;
    if (cc.contains('restaurant') || cc.contains('food') || cc.contains('cafe')) {
      return Colors.orange;
    }
    if (cc.contains('museum') || cc.contains('historical')) return Colors.brown;
    return AppColors.primary;
  }

  String _categoryEmoji(String c) {
    final cc = c.toLowerCase();
    if (cc.contains('atm')) return '🏧';
    if (cc.contains('hotel')) return '🏨';
    if (cc.contains('restaurant') || cc.contains('food')) return '🍴';
    if (cc.contains('cafe')) return '☕';
    if (cc.contains('museum')) return '🏛️';
    if (cc.contains('park')) return '🌳';
    if (cc.contains('beach')) return '🏖️';
    if (cc.contains('mosque')) return '🕌';
    if (cc.contains('church')) return '⛪';
    if (cc.contains('market') || cc.contains('souk') || cc.contains('bazaar')) {
      return '🛍️';
    }
    return '📍';
  }
}

class _AddPlaceForm extends StatefulWidget {
  const _AddPlaceForm();

  @override
  State<_AddPlaceForm> createState() => _AddPlaceFormState();
}

class _AddPlaceFormState extends State<_AddPlaceForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _nameArCtrl = TextEditingController();
  final _descriptionCtrl = TextEditingController();
  final _categoryCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _imageUrlCtrl = TextEditingController();
  final _openHoursCtrl = TextEditingController(text: '9:00 AM - 9:00 PM');
  final _ratingCtrl = TextEditingController(text: '4.5');
  final _searchCtrl = TextEditingController();
  final _searchFocus = FocusNode();
  bool _submitting = false;

  
  GeocodingResult? _picked;
  List<GeocodingResult> _searchResults = const [];
  bool _searching = false;
  Timer? _searchDebounce;

  
  
  static const List<MapEntry<String, String>> _categoryPresets = [
    MapEntry('ATM', '🏧'),
    MapEntry('Hotel', '🏨'),
    MapEntry('Restaurant', '🍴'),
    MapEntry('Cafe', '☕'),
    MapEntry('Museum', '🏛️'),
    MapEntry('Park', '🌳'),
    MapEntry('Beach', '🏖️'),
    MapEntry('Mosque', '🕌'),
    MapEntry('Market', '🛍️'),
    MapEntry('Historical', '🏛️'),
  ];

  
  
  
  void _onSearchChanged(String q) {
    _searchDebounce?.cancel();
    if (q.trim().length < 3) {
      setState(() {
        _searchResults = const [];
        _searching = false;
      });
      return;
    }
    _searchDebounce = Timer(const Duration(milliseconds: 400), () async {
      setState(() => _searching = true);
      final results = await GeocodingService.search(q);
      if (!mounted) return;
      setState(() {
        _searchResults = results;
        _searching = false;
      });
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_picked == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.tr('admin_err_location')),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    setState(() => _submitting = true);
    HapticFeedback.mediumImpact();

    final name = _nameCtrl.text.trim();
    final lat = _picked!.lat;
    final lng = _picked!.lng;
    final category = _categoryCtrl.text.trim();
    final rating = double.tryParse(_ratingCtrl.text.trim()) ?? 4.5;
    
    
    
    final address = _addressCtrl.text.trim().isNotEmpty
        ? _addressCtrl.text.trim()
        : _picked!.displayName;

    final payload = {
      'id': 'admin-${DateTime.now().millisecondsSinceEpoch}',
      'name': name,
      if (_nameArCtrl.text.trim().isNotEmpty)
        'name_ar': _nameArCtrl.text.trim(),
      'description': _descriptionCtrl.text.trim(),
      'category': category,
      'category_ar': category,
      'lat': lat,
      'lng': lng,
      'address': address,
      'address_ar': address,
      'image_url': _imageUrlCtrl.text.trim().isEmpty
          ? 'https://images.unsplash.com/photo-1524813686514-40bbe9c2d3bf?w=800'
          : _imageUrlCtrl.text.trim(),
      'open_hours': _openHoursCtrl.text.trim().isEmpty
          ? '9:00 AM - 9:00 PM'
          : _openHoursCtrl.text.trim(),
      'rating': rating,
      'review_count': 0,
      'price_level': 'free',
      'price_note': '',
      'is_hidden_gem': false,
    };

    try {
      await Supabase.instance.client.from('places').insert(payload);
      if (!mounted) return;
      
      
      await context.read<PlaceProvider>().refresh();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${context.tr('admin_added')}: $name '
            '(lat=${lat.toStringAsFixed(4)}, '
            'lng=${lng.toStringAsFixed(4)})',
          ),
          backgroundColor: AppColors.success,
          duration: const Duration(seconds: 2),
        ),
      );
      // Reset form for next entry.
      _formKey.currentState!.reset();
      _nameCtrl.clear();
      _nameArCtrl.clear();
      _descriptionCtrl.clear();
      _categoryCtrl.clear();
      _addressCtrl.clear();
      _imageUrlCtrl.clear();
      _openHoursCtrl.text = '9:00 AM - 9:00 PM';
      _ratingCtrl.text = '4.5';
      _searchCtrl.clear();
      setState(() {
        _picked = null;
        _searchResults = const [];
      });
    } on PostgrestException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${context.tr('admin_failed')}: [${e.code ?? ""}] ${e.message}',
          ),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 6),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${context.tr('admin_failed')}: $e'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 6),
        ),
      );
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _nameArCtrl.dispose();
    _descriptionCtrl.dispose();
    _categoryCtrl.dispose();
    _addressCtrl.dispose();
    _imageUrlCtrl.dispose();
    _openHoursCtrl.dispose();
    _ratingCtrl.dispose();
    _searchCtrl.dispose();
    _searchFocus.dispose();
    _searchDebounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final preset in _categoryPresets)
                InputChip(
                  label: Text('${preset.value} ${preset.key}'),
                  onPressed: () {
                    _categoryCtrl.text = preset.key;
                    setState(() {});
                  },
                ),
            ],
          ),
          const SizedBox(height: 16),
          _Field(
            controller: _nameCtrl,
            label: context.tr('admin_field_name'),
            hint: 'e.g. Bank Misr ATM - San Stefano',
            icon: Icons.label_outline_rounded,
            validator: (v) => (v == null || v.trim().isEmpty)
                ? context.tr('admin_err_name')
                : null,
          ),
          const SizedBox(height: 12),
          _Field(
            controller: _nameArCtrl,
            label: '${context.tr('admin_field_name')} (AR)',
            hint: 'اختياري - الاسم بالعربي',
            icon: Icons.translate_rounded,
          ),
          const SizedBox(height: 12),
          _Field(
            controller: _categoryCtrl,
            label: context.tr('admin_field_category'),
            hint: 'ATM / Hotel / Cafe / ...',
            icon: Icons.category_outlined,
            validator: (v) => (v == null || v.trim().isEmpty)
                ? context.tr('admin_err_category')
                : null,
          ),
          const SizedBox(height: 20),
          _LocationSearchField(
            controller: _searchCtrl,
            focusNode: _searchFocus,
            onChanged: _onSearchChanged,
            searching: _searching,
            results: _searchResults,
            picked: _picked,
            onPick: (r) {
              setState(() {
                _picked = r;
                _searchResults = const [];
                _searchCtrl.text = r.displayName;
              });
              _searchFocus.unfocus();
            },
            onClear: () {
              setState(() {
                _picked = null;
                _searchCtrl.clear();
                _searchResults = const [];
              });
            },
          ),
          if (_picked != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.success.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: AppColors.success.withValues(alpha: 0.4),
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.check_circle_outline,
                    color: AppColors.success,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'lat=${_picked!.lat.toStringAsFixed(5)}, '
                      'lng=${_picked!.lng.toStringAsFixed(5)}',
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 12),
          _Field(
            controller: _addressCtrl,
            label: context.tr('admin_field_address'),
            hint: 'auto-filled from the search above; edit if needed',
            icon: Icons.place_outlined,
            validator: (v) => null, 
            
          ),
          const SizedBox(height: 12),
          _Field(
            controller: _descriptionCtrl,
            label: context.tr('admin_field_description'),
            hint: 'Short description (optional)',
            icon: Icons.description_outlined,
            maxLines: 3,
          ),
          const SizedBox(height: 12),
          _Field(
            controller: _imageUrlCtrl,
            label: '${context.tr('admin_field_image')} (URL)',
            hint: 'optional - placeholder if empty',
            icon: Icons.image_outlined,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _Field(
                  controller: _openHoursCtrl,
                  label: context.tr('admin_field_hours'),
                  icon: Icons.schedule_rounded,
                ),
              ),
              const SizedBox(width: 12),
              SizedBox(
                width: 100,
                child: _Field(
                  controller: _ratingCtrl,
                  label: context.tr('admin_field_rating'),
                  icon: Icons.star_outline_rounded,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: _submitting ? null : _submit,
            icon: _submitting
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.add_location_alt_outlined),
            label: Text(context.tr('admin_submit')),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primary,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ],
      ),
    );
  }
}





class _LocationSearchField extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;
  final bool searching;
  final List<GeocodingResult> results;
  final GeocodingResult? picked;
  final ValueChanged<GeocodingResult> onPick;

  const _LocationSearchField({
    required this.controller,
    required this.focusNode,
    required this.onChanged,
    required this.onClear,
    required this.searching,
    required this.results,
    required this.picked,
    required this.onPick,
  });

  @override
  Widget build(BuildContext context) {
    final showResults = picked == null && results.isNotEmpty;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.search_rounded, size: 18),
            const SizedBox(width: 8),
            Text(
              context.tr('admin_location_search'),
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 13,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          focusNode: focusNode,
          onChanged: onChanged,
          textInputAction: TextInputAction.search,
          decoration: InputDecoration(
            hintText: context.tr('admin_location_search_hint'),
            prefixIcon: const Icon(Icons.travel_explore_rounded),
            suffixIcon: controller.text.isEmpty
                ? (searching
                      ? const Padding(
                          padding: EdgeInsets.all(12),
                          child: SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        )
                      : null)
                : IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: onClear,
                  ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            isDense: true,
          ),
        ),
        if (showResults) ...[
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: context.cardColor,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: context.borderColor),
            ),
            child: Column(
              children: [
                for (var i = 0; i < results.length; i++) ...[
                  if (i > 0)
                    Divider(
                      height: 1,
                      color: context.borderColor.withValues(alpha: 0.4),
                    ),
                  InkWell(
                    onTap: () => onPick(results[i]),
                    borderRadius: BorderRadius.circular(10),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.location_on_outlined,
                            size: 18,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                Text(
                                  results[i].name ??
                                      results[i].displayName.split(',').first,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 13,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  results[i].displayName,
                                  style: TextStyle(
                                    color: context.textSec,
                                    fontSize: 11,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  'lat=${results[i].lat.toStringAsFixed(5)}, '
                                  'lng=${results[i].lng.toStringAsFixed(5)}',
                                  style: TextStyle(
                                    color: context.hintColor,
                                    fontSize: 10,
                                    fontFamily: 'monospace',
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Icon(
                            Icons.arrow_forward_ios_rounded,
                            size: 14,
                            color: context.hintColor,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
        if (!searching && results.isEmpty && picked == null
            && controller.text.trim().length >= 3) ...[
          const SizedBox(height: 6),
          Text(
            context.tr('admin_location_no_results'),
            style: TextStyle(color: context.textSec, fontSize: 11),
          ),
        ],
      ],
    );
  }
}

class _Field extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String? hint;
  final IconData icon;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final int maxLines;

  const _Field({
    required this.controller,
    required this.label,
    this.hint,
    required this.icon,
    this.validator,
    this.keyboardType,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, size: 20),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        isDense: true,
      ),
      validator: validator,
      keyboardType: keyboardType,
      maxLines: maxLines,
    );
  }
}
