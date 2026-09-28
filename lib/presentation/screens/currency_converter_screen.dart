import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/constants/app_colors.dart';
import '../../core/services/currency_service.dart';
import '../../core/theme/app_text_styles.dart';
import '../../l10n/app_strings.dart';

class CurrencyConverterScreen extends StatefulWidget {
  const CurrencyConverterScreen({super.key});

  @override
  State<CurrencyConverterScreen> createState() =>
      _CurrencyConverterScreenState();
}

class _CurrencyConverterScreenState extends State<CurrencyConverterScreen> {
  final _egpController = TextEditingController(text: '100');
  String _fromCurrency = 'EGP';
  String _toCurrency = 'USD';
  double? _convertedAmount;
  double? _currentRate;
  String? _liveBadge;

  final List<String> _currencies = const [
    'EGP',
    'USD',
    'EUR',
    'GBP',
    'SAR',
    'AED',
    'KWD',
    'JPY',
    'CNY',
    'RUB',
  ];

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  @override
  void dispose() {
    _egpController.dispose();
    super.dispose();
  }

  Future<void> _refresh() async {
    final amount = double.tryParse(_egpController.text) ?? 0;
    final res = await CurrencyService.instance.convert(
      amount,
      _fromCurrency,
      _toCurrency,
    );
    if (!mounted) return;
    final inEgp = amount * (_fromCurrency == 'EGP'
        ? 1.0
        : (res != null ? amount / amount : 1.0));
    setState(() {
      _convertedAmount = res;
      _currentRate = amount == 0
          ? null
          : (res == null ? null : res / amount);
      _liveBadge = res != null ? 'live' : 'fallback';
      
      inEgp.toString();
    });
  }

  String _symbol(String code) {
    switch (code) {
      case 'EGP':
        return 'E£';
      case 'USD':
        return r'$';
      case 'EUR':
        return '€';
      case 'GBP':
        return '£';
      case 'SAR':
        return '﷼';
      case 'AED':
        return 'د.إ';
      case 'KWD':
        return 'د.ك';
      case 'JPY':
        return '¥';
      case 'CNY':
        return '¥';
      case 'RUB':
        return '₽';
      default:
        return '';
    }
  }

  String _flag(String code) {
    switch (code) {
      case 'EGP':
        return '🇪🇬';
      case 'USD':
        return '🇺🇸';
      case 'EUR':
        return '🇪🇺';
      case 'GBP':
        return '🇬🇧';
      case 'SAR':
        return '🇸🇦';
      case 'AED':
        return '🇦🇪';
      case 'KWD':
        return '🇰🇼';
      case 'JPY':
        return '🇯🇵';
      case 'CNY':
        return '🇨🇳';
      case 'RUB':
        return '🇷🇺';
      default:
        return '🌍';
    }
  }

  void _swap() {
    HapticFeedback.lightImpact();
    setState(() {
      final t = _fromCurrency;
      _fromCurrency = _toCurrency;
      _toCurrency = t;
    });
    _refresh();
  }

  @override
  Widget build(BuildContext context) {
    final amount = double.tryParse(_egpController.text) ?? 0;
    final result = _convertedAmount ?? 0;
    final rate = _currentRate ?? 0;

    return Scaffold(
      backgroundColor: context.bgColor,
      appBar: AppBar(
        title: Text(context.tr('currency_converter')),
        backgroundColor: context.bgColor,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        physics: const BouncingScrollPhysics(),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF14B8A6), Color(0xFF06B6D4)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF14B8A6).withValues(alpha: 0.3),
                  blurRadius: 18,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${_symbol(_fromCurrency)} ${amount.toStringAsFixed(2)}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '${_symbol(_toCurrency)} ${result.toStringAsFixed(2)}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 38,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Text(
                      '1 $_fromCurrency = ${rate.toStringAsFixed(4)} $_toCurrency',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.85),
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 8),
                    if (_liveBadge != null)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: _liveBadge == 'live'
                              ? Colors.green.withValues(alpha: 0.25)
                              : Colors.amber.withValues(alpha: 0.25),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          _liveBadge == 'live' ? 'LIVE' : 'OFFLINE',
                          style: TextStyle(
                            color: _liveBadge == 'live'
                                ? Colors.greenAccent.shade100
                                : Colors.amberAccent.shade100,
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text(
            context.tr('cur_amount'),
            style: AppTextStyles.sectionTitle.copyWith(color: context.textPri),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _egpController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            onChanged: (_) => _refresh(),
            decoration: InputDecoration(
              hintText: context.tr('cur_enter_amount'),
              filled: true,
              fillColor: context.cardColor,
              prefixIcon: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: Text(
                  _symbol(_fromCurrency),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              prefixIconConstraints: const BoxConstraints(minWidth: 50),
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
          Row(
            children: [
              Expanded(
                child: _CurrencyPicker(
                  label: context.tr('cur_from'),
                  code: _fromCurrency,
                  onChanged: (c) {
                    setState(() => _fromCurrency = c);
                    _refresh();
                  },
                  currencies: _currencies,
                  flag: _flag,
                  symbol: _symbol,
                ),
              ),
              IconButton(
                onPressed: _swap,
                icon: const Icon(Icons.swap_horiz_rounded, size: 28),
                color: context.textPri,
                style: IconButton.styleFrom(
                  backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                  shape: const CircleBorder(),
                ),
              ),
              Expanded(
                child: _CurrencyPicker(
                  label: context.tr('cur_to'),
                  code: _toCurrency,
                  onChanged: (c) {
                    setState(() => _toCurrency = c);
                    _refresh();
                  },
                  currencies: _currencies,
                  flag: _flag,
                  symbol: _symbol,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.warning.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.warning.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.info_outline_rounded,
                  color: AppColors.warning,
                  size: 20,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    context.tr('cur_disclaimer'),
                    style: const TextStyle(
                      color: AppColors.warning,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CurrencyPicker extends StatelessWidget {
  final String label;
  final String code;
  final ValueChanged<String> onChanged;
  final List<String> currencies;
  final String Function(String) flag;
  final String Function(String) symbol;

  const _CurrencyPicker({
    required this.label,
    required this.code,
    required this.onChanged,
    required this.currencies,
    required this.flag,
    required this.symbol,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: context.hintColor.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: context.textSec,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 2),
          DropdownButton<String>(
            value: code,
            isExpanded: true,
            underline: const SizedBox(),
            items: currencies
                .map(
                  (c) => DropdownMenuItem(
                    value: c,
                    child: Row(
                      children: [
                        Text(flag(c), style: const TextStyle(fontSize: 18)),
                        const SizedBox(width: 8),
                        Text(
                          symbol(c),
                          style: const TextStyle(fontWeight: FontWeight.w800),
                        ),
                        const SizedBox(width: 4),
                        Text(c),
                      ],
                    ),
                  ),
                )
                .toList(),
            onChanged: (v) {
              if (v != null) onChanged(v);
            },
          ),
        ],
      ),
    );
  }
}
