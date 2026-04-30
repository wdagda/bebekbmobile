import 'package:dio/dio.dart';

class CurrencyService {
  static const _baseUrl = 'https://api.exchangerate-api.com/v4/latest';

  final Dio _dio;
  Map<String, double> _rates = {};

  CurrencyService(this._dio);

  Future<void> fetchRates() async {
    final res = await _dio.get('$_baseUrl/IDR');
    _rates = Map<String, double>.from(res.data['rates']);
  }

  /// Convert IDR to target currency
  double convert(double amountIDR, String targetCurrency) {
    if (_rates.isEmpty) return amountIDR;
    return amountIDR * (_rates[targetCurrency] ?? 1.0);
  }

  String format(double amount, String currency) {
    final symbols = {'IDR': 'Rp', 'USD': '\$', 'JPY': '¥'};
    final symbol = symbols[currency] ?? currency;
    return '$symbol ${amount.toStringAsFixed(2)}';
  }
}
