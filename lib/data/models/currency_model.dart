class CurrencyModel {
  final String code;
  final String name;
  final String symbol;
  final String flag;
  final String locale;

  CurrencyModel({
    required this.code,
    required this.name,
    required this.symbol,
    required this.flag,
    required this.locale,
  });

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'name': name,
      'symbol': symbol,
      'flag': flag,
      'locale': locale,
    };
  }

  // Create from JSON
  factory CurrencyModel.fromJson(Map<String, dynamic> json) {
    return CurrencyModel(
      code: json['code'],
      name: json['name'],
      symbol: json['symbol'],
      flag: json['flag'],
      locale: json['locale'] ?? 'en_US', // Default locale if missing
    );
  }

  @override
  String toString() {
    return 'CurrencyModel(code: $code, name: $name, symbol: $symbol)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CurrencyModel && other.code == code;
  }

  @override
  int get hashCode => code.hashCode;

  // Predefined currencies with proper formatting
  static List<CurrencyModel> get supportedCurrencies => [
    CurrencyModel(
      code: 'IDR', 
      name: 'Indonesian Rupiah', 
      symbol: 'Rp', 
      flag: '🇮🇩', 
      locale: 'id_ID'
    ),
    CurrencyModel(
      code: 'USD', 
      name: 'US Dollar', 
      symbol: '\$', 
      flag: '🇺🇸', 
      locale: 'en_US'
    ),
    CurrencyModel(
      code: 'EUR', 
      name: 'Euro', 
      symbol: '€', 
      flag: '🇪🇺', 
      locale: 'de_DE'
    ),
    CurrencyModel(
      code: 'GBP', 
      name: 'British Pound', 
      symbol: '£', 
      flag: '🇬🇧', 
      locale: 'en_GB'
    ),
    CurrencyModel(
      code: 'JPY', 
      name: 'Japanese Yen', 
      symbol: '¥', 
      flag: '🇯🇵', 
      locale: 'ja_JP'
    ),
    CurrencyModel(
      code: 'CAD', 
      name: 'Canadian Dollar', 
      symbol: 'C\$', 
      flag: '🇨🇦', 
      locale: 'en_CA'
    ),
    CurrencyModel(
      code: 'AUD', 
      name: 'Australian Dollar', 
      symbol: 'A\$', 
      flag: '🇦🇺', 
      locale: 'en_AU'
    ),
    CurrencyModel(
      code: 'CHF', 
      name: 'Swiss Franc', 
      symbol: 'CHF', 
      flag: '🇨🇭', 
      locale: 'de_CH'
    ),
    CurrencyModel(
      code: 'CNY', 
      name: 'Chinese Yuan', 
      symbol: '¥', 
      flag: '🇨🇳', 
      locale: 'zh_CN'
    ),
    CurrencyModel(
      code: 'SEK', 
      name: 'Swedish Krona', 
      symbol: 'kr', 
      flag: '🇸🇪', 
      locale: 'sv_SE'
    ),
    CurrencyModel(
      code: 'NOK', 
      name: 'Norwegian Krone', 
      symbol: 'kr', 
      flag: '🇳🇴', 
      locale: 'no_NO'
    ),
    CurrencyModel(
      code: 'MXN', 
      name: 'Mexican Peso', 
      symbol: '\$', 
      flag: '🇲🇽', 
      locale: 'es_MX'
    ),
    CurrencyModel(
      code: 'SGD', 
      name: 'Singapore Dollar', 
      symbol: 'S\$', 
      flag: '🇸🇬', 
      locale: 'en_SG'
    ),
    CurrencyModel(
      code: 'HKD', 
      name: 'Hong Kong Dollar', 
      symbol: 'HK\$', 
      flag: '🇭🇰', 
      locale: 'en_HK'
    ),
    CurrencyModel(
      code: 'NZD', 
      name: 'New Zealand Dollar', 
      symbol: 'NZ\$', 
      flag: '🇳🇿', 
      locale: 'en_NZ'
    ),
    CurrencyModel(
      code: 'INR', 
      name: 'Indian Rupee', 
      symbol: '₹', 
      flag: '🇮🇳', 
      locale: 'hi_IN'
    ),
    CurrencyModel(
      code: 'BRL', 
      name: 'Brazilian Real', 
      symbol: 'R\$', 
      flag: '🇧🇷', 
      locale: 'pt_BR'
    ),
    CurrencyModel(
      code: 'RUB', 
      name: 'Russian Ruble', 
      symbol: '₽', 
      flag: '🇷🇺', 
      locale: 'ru_RU'
    ),
    CurrencyModel(
      code: 'KRW', 
      name: 'South Korean Won', 
      symbol: '₩', 
      flag: '🇰🇷', 
      locale: 'ko_KR'
    ),
    CurrencyModel(
      code: 'THB', 
      name: 'Thai Baht', 
      symbol: '฿', 
      flag: '🇹🇭', 
      locale: 'th_TH'
    ),
  ];

  // Get currency by code
  static CurrencyModel? getCurrencyByCode(String code) {
    try {
      return supportedCurrencies.firstWhere((currency) => currency.code == code);
    } catch (e) {
      return null;
    }
  }
}