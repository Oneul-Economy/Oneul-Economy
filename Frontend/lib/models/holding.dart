/// 보유 종목 한 줄. 서버 `POST /portfolio/scan` 응답의 holdings 항목과 같은 모양.
///
/// 캡처에서 못 읽은 값은 null로 온다 (AI가 추측하지 않음).
class Holding {
  const Holding({
    required this.stockName,
    this.stockCode,
    this.quantity,
    this.avgPrice,
    this.marketValue,
    this.currency = 'KRW',
  });

  final String stockName;
  final String? stockCode;
  final double? quantity;
  final double? avgPrice;
  final double? marketValue;
  final String currency;

  /// 평가금액. 캡처에 없으면 수량 × 평균단가로 어림잡고, 그것도 없으면 null.
  double? get value =>
      marketValue ??
      (quantity != null && avgPrice != null ? quantity! * avgPrice! : null);

  factory Holding.fromJson(Map<String, dynamic> json) {
    double? num_(Object? v) => (v as num?)?.toDouble();
    return Holding(
      stockName: json['stock_name'] as String,
      stockCode: json['stock_code'] as String?,
      quantity: num_(json['quantity']),
      avgPrice: num_(json['avg_price']),
      marketValue: num_(json['market_value']),
      currency: (json['currency'] as String?) ?? 'KRW',
    );
  }

  Map<String, dynamic> toJson() => {
    'stock_name': stockName,
    'stock_code': stockCode,
    'quantity': quantity,
    'avg_price': avgPrice,
    'market_value': marketValue,
    'currency': currency,
  };

  /// 사용자가 고친 값으로 새 종목을 만든다. [base]가 null이면 직접 추가한 종목.
  factory Holding.edited(
    Holding? base, {
    required String stockName,
    double? quantity,
    double? avgPrice,
  }) {
    if (base == null) {
      return Holding(
        stockName: stockName,
        quantity: quantity,
        avgPrice: avgPrice,
      );
    }
    final changed = quantity != base.quantity || avgPrice != base.avgPrice;
    return Holding(
      stockName: stockName,
      stockCode: base.stockCode,
      quantity: quantity,
      avgPrice: avgPrice,
      // 수량·단가를 고치면 캡처의 평가금액은 더 이상 맞지 않을 수 있어 버림
      marketValue: changed ? null : base.marketValue,
      currency: base.currency,
    );
  }
}
