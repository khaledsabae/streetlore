import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;








class CurrencyService {
  CurrencyService._();
  static final CurrencyService instance = CurrencyService._();

  static const _endpoint = 'https://open.er-api.com/v6/latest/EGP';
  static const _maxAge = Duration(hours: 6);

  
  
  Map<String, double>? _ratesPerEgp;
  DateTime? _fetchedAt;
  bool _fetching = false;

  Future<void> _ensureFresh() async {
    if (_ratesPerEgp != null &&
        _fetchedAt != null &&
        DateTime.now().difference(_fetchedAt!) < _maxAge) {
      return;
    }
    if (_fetching) return;
    _fetching = true;
    try {
      final res = await http
          .get(Uri.parse(_endpoint))
          .timeout(const Duration(seconds: 8));
      if (res.statusCode == 200) {
        final body = jsonDecode(res.body) as Map<String, dynamic>;
        final rates = body['rates'] as Map<String, dynamic>?;
        if (rates != null) {
          _ratesPerEgp = rates.map(
            (k, v) => MapEntry(k, (v as num).toDouble()),
          );
          _fetchedAt = DateTime.now();
          return;
        }
      }
      debugPrint(
        'CurrencyService: live fetch failed (${res.statusCode}) — using fallback',
      );
    } on TimeoutException {
      debugPrint('CurrencyService: timeout — using fallback');
    } catch (e) {
      debugPrint('CurrencyService: $e — using fallback');
    } finally {
      _fetching = false;
    }
    _ratesPerEgp ??= _fallback;
  }

  
  
  Future<double?> convert(
    double amount,
    String from,
    String to,
  ) async {
    if (from == to) return amount;
    await _ensureFresh();
    final table = _ratesPerEgp ?? _fallback;
    
    final fromRate = table[from];
    final toRate = table[to];
    if (fromRate == null || toRate == null) return null;
    final inEgp = amount * fromRate;
    return inEgp / toRate;
  }

  
  
  static const Map<String, double> _fallback = {
    'EGP': 1.0,
    'USD': 49.5,
    'EUR': 53.7,
    'GBP': 62.8,
    'SAR': 13.2,
    'AED': 13.5,
    'KWD': 161.0,
    'JPY': 0.33,
    'CNY': 6.85,
    'RUB': 0.54,
  };
}
