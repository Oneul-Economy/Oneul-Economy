import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oneul_economy/models/news.dart';
import 'package:oneul_economy/screens/news_detail_screen.dart';
import 'package:oneul_economy/widgets/news_card.dart';

void main() {
  // ① 테스트용 가짜 뉴스
  final news = News.fromJson({
    'id': 'test-001',
    'stock_name': '테스트전자',
    'title': '테스트용 고유 제목입니다',
    'summary': '요약',
    'read_minutes': 3,
    'body': ['첫째 문단입니다', '둘째 문단입니다'],
    'terms': [
      {'word': '테스트용어', 'meaning': '테스트용 설명'},
    ],
    'source': {
      'press': '테스트일보',
      'url': 'https://example.com',
      'published_at': '2026-11-05T09:00:00+09:00',
    },
  });

  testWidgets('카드를 누르면 본문 화면에 실제 제목이 보인다', (tester) async {
    // ② 화면에 카드 띄우기
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: Builder(
          builder: (context) => NewsCard(
            news: news,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => NewsDetailScreen(news: news)),
            ),
          ),
        ),
      ),
    ));

    // ③ "본문 읽기" 누르고 화면 전환 기다리기
    await tester.tap(find.text('본문 읽기'));
    await tester.pumpAndSettle();

    // ④ 확인
    expect(find.byType(NewsDetailScreen), findsOneWidget);
    expect(find.text(news.title), findsOneWidget);
    expect(find.text(news.body.first), findsOneWidget);
  });

  testWidgets('카드에서 본문 읽기 버튼 말고 다른 곳을 누르면 이동하지 않는다', (tester) async {
    var opened = false;
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: SingleChildScrollView(
          child: NewsCard(news: news, onTap: () => opened = true),
        ),
      ),
    ));

    await tester.tap(find.text(news.title));
    await tester.tap(find.text(news.summary));
    await tester.pump();
    expect(opened, isFalse);

    await tester.tap(find.text('본문 읽기'));
    expect(opened, isTrue);
  });
}