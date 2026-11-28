import 'package:flutter/foundation.dart';

import '../models/holding.dart';

/// 내 보유 종목 (포트폴리오 탭, 일지 쓰기의 연결 종목에서 함께 씀).
///
/// saved_store.dart처럼 지금은 앱이 켜져 있는 동안만 메모리에 들고 있다.
/// 서버 저장(PUT /users/{id}/holdings)이 생기면 이 클래스 안쪽만 바꾼다.
class PortfolioStore extends ChangeNotifier {
  List<Holding> _holdings = const [];
  DateTime? _updatedAt;
  bool _isSample = false;

  List<Holding> get holdings => List.unmodifiable(_holdings);
  DateTime? get updatedAt => _updatedAt;
  bool get isEmpty => _holdings.isEmpty;

  /// 서버 없이 화면을 둘러보려고 예시 포트폴리오를 넣은 상태인지.
  bool get isSample => _isSample;

  /// 종목 이름 목록 (중복 제거, 등록 순서 유지).
  List<String> get stockNames =>
      _holdings.map((h) => h.stockName).toSet().toList();

  /// 원화 종목 평가금액 합계. 값이 하나도 없으면 null.
  double? get totalKrw {
    final values = _holdings
        .where((h) => h.currency == 'KRW')
        .map((h) => h.value)
        .whereType<double>();
    if (values.isEmpty) return null;
    return values.fold<double>(0, (a, b) => a + b);
  }

  void setHoldings(List<Holding> holdings) {
    _holdings = List.of(holdings);
    _updatedAt = DateTime.now();
    _isSample = false;
    notifyListeners();
  }

  /// 예시 포트폴리오로 채운다 ('mock 데이터로 계속하기').
  void useSample() {
    setHoldings(samplePortfolio);
    _isSample = true;
    notifyListeners();
  }

  @visibleForTesting
  void clear() {
    _holdings = const [];
    _updatedAt = null;
    _isSample = false;
    notifyListeners();
  }
}

/// 서버·캡처 없이 화면을 볼 때 쓰는 예시 포트폴리오 (목업은 이것 하나만 둔다).
const samplePortfolio = [
  Holding(
    stockName: '삼성전자',
    stockCode: '005930',
    quantity: 30,
    avgPrice: 152000,
    marketValue: 5190000,
  ),
  Holding(
    stockName: 'SK하이닉스',
    stockCode: '000660',
    quantity: 12,
    avgPrice: 231000,
    marketValue: 3204000,
  ),
  Holding(
    stockName: '현대차',
    stockCode: '005380',
    quantity: 10,
    avgPrice: 251000,
    marketValue: 2468000,
  ),
  Holding(
    stockName: 'NAVER',
    stockCode: '035420',
    quantity: 7,
    avgPrice: 198000,
    marketValue: 1480500,
  ),
];

/// 앱 전체에서 함께 쓰는 포트폴리오 하나.
final portfolioStore = PortfolioStore();
