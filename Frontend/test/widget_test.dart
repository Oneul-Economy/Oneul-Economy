import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oneul_economy/models/news.dart';
import 'package:oneul_economy/screens/news_detail_screen.dart';
import 'package:oneul_economy/widgets/news_card.dart';

void main() {
    final news = News.fromJson({ /* widget_test.dart의 JSON 복사, title만 고유하게 */ });

  testWidgets('카드를 누르면 본문 화면에 실제 제목이 보인다', (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: Builder(
          builder: (context) => NewsCard(
            news: news,
            onTap: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => NewsDetailScreen(news: news))),
          ),
        ),
      ),
    ));

    await tester.tap(find.text('본문 읽기'));
    await tester.pumpAndSettle();

    expect(find.byType(NewsDetailScreen), findsOneWidget);
    expect(find.text(news.title), findsOneWidget);
    expect(find.text(news.body.first), findsOneWidget);
  });
}
