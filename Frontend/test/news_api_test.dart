import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:oneul_economy/api/news_api.dart';

void main() {
  final newsJson = {
    'id': '20261105-005930-002',
    'stock_name': '삼성전자',
    'title': '제목',
    'summary': '요약',
    'read_minutes': 3,
    'body': ['문단1'],
    'terms': [
      {'word': '용어', 'meaning': '설명'},
    ],
    'source': {
      'press': '시사저널',
      'url': 'https://n.news.naver.com/x',
      'published_at': '2026-11-05T12:00:00+09:00',
    },
  };

  test('GET /news 응답(한글 포함)을 News 목록으로 읽는다', () async {
    late Uri called;
    final client = MockClient((req) async {
      called = req.url;
      return http.Response.bytes(
        utf8.encode(jsonEncode([newsJson])),
        200,
        headers: {'content-type': 'application/json'},
      );
    });

    final list = await fetchNewsList(limit: 5, client: client);
    expect(called.path, '/news');
    expect(called.queryParameters['limit'], '5');
    expect(list.single.stockName, '삼성전자');
    expect(list.single.terms.single.word, '용어');
  });

  test('GET /news/{id} 404면 NewsApiException', () async {
    final client = MockClient((_) async => http.Response('{}', 404));
    expect(fetchNews('nope', client: client), throwsA(isA<NewsApiException>()));
  });
}
