import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/constants/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../l10n/app_strings.dart';
import '../../logic/auth_provider.dart';
import '../../logic/place_provider.dart';

/// Admin Panel for Streetlore.
///
/// v1.0.41 Phase 2. Lets the admin (gated by
/// [AuthProvider.isAdmin]) dynamically add new places to the
/// `places` table with a free-text `category` column (so 'ATM',
/// 'Hotel', 'Cafe', 'Restaurant' or anything else are all
/// supported without a database enum migration). The list view
/// shows the latest 50 places ordered by id so the admin can
/// confirm a row landed.
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
  final _latCtrl = TextEditingController();
  final _lngCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _imageUrlCtrl = TextEditingController();
  final _openHoursCtrl = TextEditingController(text: '9:00 AM - 9:00 PM');
  final _ratingCtrl = TextEditingController(text: '4.5');
  bool _submitting = false;

  // Common preset categories the user can tap to pre-fill the
  // category field. Anything else can still be typed free-form.
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

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _submitting = true);
    HapticFeedback.mediumImpact();

    final name = _nameCtrl.text.trim();
    final lat = double.parse(_latCtrl.text.trim());
    final lng = double.parse(_lngCtrl.text.trim());
    final category = _categoryCtrl.text.trim();
    final rating = double.tryParse(_ratingCtrl.text.trim()) ?? 4.5;

    final payload = {
      'id': 'admin-${DateTime.now().millisecondsSinceEpoch}',
      'name': name,
      if (_nameArCtrl.text.trim().isNotEmpty)
        'name_ar': _nameArCtrl.text.trim(),
      'description': _descriptionCtrl.text.trim(),
      if (_descriptionCtrl.text.trim().isNotEmpty)
        'description': _descriptionCtrl.text.trim(),
      'category': category,
      'category_ar': category,
      'lat': lat,
      'lng': lng,
      'address': _addressCtrl.text.trim(),
      'address_ar': _addressCtrl.text.trim(),
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
      // Refresh the in-memory cache so the admin list + map show
      // the new row immediately.
      await context.read<PlaceProvider>().refresh();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${context.tr('admin_added')}: $name'),
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
      _latCtrl.clear();
      _lngCtrl.clear();
      _addressCtrl.clear();
      _imageUrlCtrl.clear();
      _openHoursCtrl.text = '9:00 AM - 9:00 PM';
      _ratingCtrl.text = '4.5';
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
    _latCtrl.dispose();
    _lngCtrl.dispose();
    _addressCtrl.dispose();
    _imageUrlCtrl.dispose();
    _openHoursCtrl.dispose();
    _ratingCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Category preset chips
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
          const SizedBox(height: 12),
          _Field(
            controller: _latCtrl,
            label: 'Latitude (29.5 - 31.5)',
            hint: 'e.g. 31.2001',
            icon: Icons.north_rounded,
            keyboardType: const TextInputType.numberWithOptions(
              decimal: true, signed: true,
            ),
            validator: (v) {
              if (v == null || v.trim().isEmpty) return 'required';
              final d = double.tryParse(v.trim());
              if (d == null) return 'invalid number';
              if (d < 29.5 || d > 31.5) {
                return 'must be in Alexandria range 29.5 - 31.5';
              }
              return null;
            },
          ),
          const SizedBox(height: 12),
          _Field(
            controller: _lngCtrl,
            label: 'Longitude (29.0 - 30.5)',
            hint: 'e.g. 29.9187',
            icon: Icons.east_rounded,
            keyboardType: const TextInputType.numberWithOptions(
              decimal: true, signed: true,
            ),
            validator: (v) {
              if (v == null || v.trim().isEmpty) return 'required';
              final d = double.tryParse(v.trim());
              if (d == null) return 'invalid number';
              if (d < 29.0 || d > 30.5) {
                return 'must be in Alexandria range 29.0 - 30.5';
              }
              return null;
            },
          ),
          const SizedBox(height: 12),
          _Field(
            controller: _addressCtrl,
            label: context.tr('admin_field_address'),
            hint: 'e.g. San Stefano, Alexandria',
            icon: Icons.place_outlined,
            validator: (v) => (v == null || v.trim().isEmpty)
                ? context.tr('admin_err_address')
                : null,
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
