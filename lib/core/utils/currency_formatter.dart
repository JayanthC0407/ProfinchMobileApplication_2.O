import 'package:intl/intl.dart';

/// Small helper for rendering money consistently across the app.
///
/// The OBDX `demandDeposit` response gives currency as an ISO 4217 code
/// (e.g. `GBP`, `AED`, `INR`) rather than a symbol, so we map the common
/// ones to their symbol and fall back to showing the code itself for
/// anything we don't recognise (safer than guessing a symbol for a
/// currency we've never tested against).
class CurrencyFormatter {
  CurrencyFormatter._();

  static const Map<String, String> _symbols = {
    'INR': '\u20b9',
    'USD': '\u0024',
    'GBP': 'GBP',
    'EUR': '\u20ac',
    'AED': 'AED',
    'SAR': 'SAR',
  };

  /// e.g. `format(1640000, 'GBP')` -> `\u00a3 1,640,000.00`
  static String format(double amount, String currencyCode, {bool hideValue = false}) {
    if (hideValue) return '${_prefix(currencyCode)}••••••';
    final formatted = NumberFormat('#,##0.00').format(amount);
    return '${_prefix(currencyCode)} $formatted';   // ← space added here
  }

  static String symbolFor(String currencyCode) => _prefix(currencyCode);
  static String _prefix(String currencyCode) {
    final code = currencyCode.trim().toUpperCase();
    if (code.isEmpty) return '';
    return _symbols[code] ?? code;   // no trailing space here either
  }
}
