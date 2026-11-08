enum AppCurrency {
  nio(code: 'NIO', displayName: 'Córdoba nicaragüense', symbol: 'C\$'),
  usd(code: 'USD', displayName: 'Dólar estadounidense', symbol: 'US\$'),
  hnl(code: 'HNL', displayName: 'Lempira hondureña', symbol: 'L'),
  gtq(code: 'GTQ', displayName: 'Quetzal guatemalteco', symbol: 'Q'),
  crc(code: 'CRC', displayName: 'Colón costarricense', symbol: '₡'),
  cop(code: 'COP', displayName: 'Peso colombiano', symbol: 'COL\$'),
  mxn(code: 'MXN', displayName: 'Peso mexicano', symbol: 'MX\$'),
  eur(code: 'EUR', displayName: 'Euro', symbol: '€');

  const AppCurrency({
    required this.code,
    required this.displayName,
    required this.symbol,
  });

  final String code;
  final String displayName;
  final String symbol;

  static AppCurrency fromCode(
    String? code, {
    AppCurrency fallback = AppCurrency.nio,
  }) {
    final normalized = code?.toUpperCase();
    return AppCurrency.values.firstWhere(
      (currency) => currency.code == normalized,
      orElse: () => fallback,
    );
  }
}
