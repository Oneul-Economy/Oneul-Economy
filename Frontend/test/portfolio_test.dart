import 'package:flutter_test/flutter_test.dart';
import 'package:oneul_economy/api/portfolio_api.dart';
import 'package:oneul_economy/models/holding.dart';
import 'package:oneul_economy/stores/portfolio_store.dart';
import 'package:oneul_economy/utils/number_format.dart';

void main() {
  test('숫자 표시와 입력 해석', () {
    expect(formatNumber(1234567), '1,234,567');
    expect(formatNumber(0.5), '0.5');
    expect(formatNumber(1200.0), '1,200');
    expect(formatMoney(71000, 'KRW'), '71,000원');
    expect(formatMoney(12.5, 'USD'), '\$12.5');
    expect(parseNumber('1,234원'), 1234);
    expect(parseNumber(''), isNull);
  });

  test('서버 응답을 Holding으로 읽고, null은 그대로 둔다', () {
    final h = Holding.fromJson({
      'stock_name': '삼성전자',
      'stock_code': null,
      'quantity': 3,
      'avg_price': 71000,
      'market_value': null,
      'currency': 'KRW',
    });
    expect(h.quantity, 3.0);
    expect(h.marketValue, isNull);
    expect(h.value, 213000); // 평가금액이 없으면 수량 × 단가
  });

  test('수량을 고치면 캡처의 평가금액은 버린다', () {
    const base = Holding(
      stockName: '카카오',
      quantity: 10,
      avgPrice: 52300,
      marketValue: 398000,
    );
    final same = Holding.edited(
      base,
      stockName: '카카오',
      quantity: 10,
      avgPrice: 52300,
    );
    expect(same.marketValue, 398000);
    final changed = Holding.edited(
      base,
      stockName: '카카오',
      quantity: 11,
      avgPrice: 52300,
    );
    expect(changed.marketValue, isNull);
  });

  test('포트폴리오 저장소: 종목 이름과 원화 합계', () {
    final store = PortfolioStore()
      ..setHoldings(const [
        Holding(stockName: 'A', marketValue: 100),
        Holding(stockName: 'B', marketValue: 50),
        Holding(stockName: 'AAPL', marketValue: 10, currency: 'USD'),
      ]);
    expect(store.stockNames, ['A', 'B', 'AAPL']);
    expect(store.totalKrw, 150);
  });

  test('확장자로 이미지 형식 판단', () {
    expect(imageMediaType('a.JPG'), 'image/jpeg');
    expect(imageMediaType('a.png'), 'image/png');
    expect(imageMediaType('a.heic'), isNull);
  });
}
