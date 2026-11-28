import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oneul_economy/models/news.dart';
import 'package:oneul_economy/screens/main_shell.dart';
import 'package:oneul_economy/screens/news_detail_screen.dart';
import 'package:oneul_economy/screens/quiz_result_screen.dart';

void main() {
  final news = News.fromJson({
    'id': 'test-001',
    'stock_name': '테스트전자',
    'title': '테스트 기사',
    'summary': '요약',
    'read_minutes': 3,
    'body': ['문단'],
    'terms': <Map<String, dynamic>>[],
    'source': {
      'press': '테스트일보',
      'url': 'https://example.com',
      'published_at': '2026-11-05T09:00:00+09:00',
    },
  });

  tearDown(() => MainShell.tab.value = MainShell.home);

  testWidgets('퀴즈 결과의 홈으로는 본문이 아니라 홈 탭으로 간다', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: MainShell()));
    await tester.pumpAndSettle();

    // 다른 탭에서 본문 → 퀴즈 결과까지 열어 둔 상황
    MainShell.tab.value = MainShell.articles;
    final nav = tester.state<NavigatorState>(find.byType(Navigator));
    nav.push(MaterialPageRoute(builder: (_) => NewsDetailScreen(news: news)));
    nav.push(
      MaterialPageRoute(
        builder: (_) => QuizResultScreen(
          news: news,
          totalCount: 3,
          correctCount: 2,
          wrongItems: const [],
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('홈으로'));
    await tester.pumpAndSettle();

    expect(find.byType(QuizResultScreen), findsNothing);
    expect(find.byType(NewsDetailScreen), findsNothing);
    expect(MainShell.tab.value, MainShell.home);
  });
}
