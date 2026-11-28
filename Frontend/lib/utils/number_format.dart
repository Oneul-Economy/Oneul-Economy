/// 1234567.0 → "1,234,567". 소수가 있으면 [decimals]자리까지 (끝의 0은 지움).
String formatNumber(num value, {int decimals = 2}) {
  final negative = value < 0;
  var text = value.abs().toStringAsFixed(decimals);
  if (text.contains('.')) {
    text = text.replaceFirst(RegExp(r'\.?0+$'), '');
  }
  final parts = text.split('.');
  final intPart = parts[0].replaceAllMapped(
    RegExp(r'\B(?=(\d{3})+(?!\d))'),
    (_) => ',',
  );
  final result = parts.length > 1 ? '$intPart.${parts[1]}' : intPart;
  return negative ? '-$result' : result;
}

/// 통화에 맞춰 금액 표시. KRW → "71,000원", USD → "$12.5", 그 외 → "12.5 EUR".
String formatMoney(num value, String currency) {
  return switch (currency) {
    'KRW' => '${formatNumber(value, decimals: 0)}원',
    'USD' => '\$${formatNumber(value)}',
    _ => '${formatNumber(value)} $currency',
  };
}

/// "1,234" 같은 입력을 숫자로. 비었거나 숫자가 아니면 null.
double? parseNumber(String text) {
  final cleaned = text.replaceAll(RegExp(r'[,\s원주$]'), '');
  if (cleaned.isEmpty) return null;
  return double.tryParse(cleaned);
}
