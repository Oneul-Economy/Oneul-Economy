import 'package:flutter_test/flutter_test.dart';

import 'package:oneul_economy/models/news.dart';

void main() {
  test('News.fromJson이 #3 형식의 JSON을 읽는다', () {
    final news = News.fromJson({
      'id': '20261102-005930-001',
      'stock_name': '삼성전자',
      'title': 'HBM이 뭐길래 주가가 오를까',
      'summary': '요약',
      'read_minutes': 3,
      'body': ['문단 1', '문단 2'],
      'terms': [
        {'word': 'HBM', 'meaning': '쌓아 올린 메모리'},
      ],
      'source': {
        'press': '한국경제',
        'url': 'https://example.com',
        'published_at': '2026-11-02T09:00:00+09:00',
      },
    });

    expect(news.stockName, '삼성전자');
    expect(news.readMinutes, 3);
    expect(news.body, hasLength(2));
    expect(news.terms.single.word, 'HBM');
    expect(news.source.press, '한국경제');
    expect(news.source.publishedAt.toUtc(), DateTime.utc(2026, 11, 2, 0));
  });
}
