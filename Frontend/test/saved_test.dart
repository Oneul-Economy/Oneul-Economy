import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oneul_economy/models/news.dart';
import 'package:oneul_economy/screens/main_shell.dart';
import 'package:oneul_economy/screens/saved_terms_screen.dart';
import 'package:oneul_economy/stores/saved_store.dart';
import 'package:oneul_economy/utils/term_matcher.dart';
import 'package:oneul_economy/widgets/term_paragraph.dart';

void main() {
  const term = Term(word: '노동조합', meaning: '노동자들이 모여 회사와 협상하는 단체');
  final news = News.fromJson({
    'id': 'test-001',
    'stock_name': '테스트전자',
    'title': '테스트 제목',
    'summary': '요약',
    'read_minutes': 3,
    'body': ['본문'],
    'terms': [],
    'source': {
      'press': '테스트일보',
      'url': 'https://example.com',
      'published_at': '2026-11-05T09:00:00+09:00',
    },
  });

  setUp(() {
    savedStore.clear();
    // 이전 테스트에서 캐시된 에셋 Future는 다음 테스트에서 끝나지 않으므로 비운다.
    rootBundle.clear();
  });

  group('SavedStore', () {
    test('한 번 누르면 저장, 다시 누르면 저장 취소', () {
      savedStore.toggleTerm(term);
      expect(savedStore.isTermSaved(term), isTrue);

      savedStore.toggleTerm(term);
      expect(savedStore.isTermSaved(term), isFalse);
      expect(savedStore.savedTerms, isEmpty);
    });

    test('최근에 저장한 것이 맨 앞에 온다', () {
      const other = Term(word: '성과급', meaning: '성과에 따라 주는 돈');
      savedStore.toggleTerm(term);
      savedStore.toggleTerm(other);

      expect(savedStore.savedTerms.map((t) => t.word), ['성과급', '노동조합']);
    });

    test('기사는 id로 구분해 저장한다', () {
      savedStore.toggleNews(news);
      expect(savedStore.isNewsSaved(news), isTrue);
      expect(savedStore.savedNews.single.id, 'test-001');
    });
  });

  testWidgets('바텀시트의 북마크를 누르면 용어집에 담긴다', (tester) async {
    const text = '삼성전자 노동조합(노조)은 파업했다.';
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: TermParagraph(
            text: text,
            hits: findTermHits([text], [term])[0],
          ),
        ),
      ),
    );

    await tester.tapOnText(find.textRange.ofSubstring('노동조합'));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.bookmark_border_rounded));
    await tester.pump();

    expect(savedStore.isTermSaved(term), isTrue);
    expect(find.byIcon(Icons.bookmark_rounded), findsOneWidget);
    expect(find.text('용어를 스크랩했어요'), findsOneWidget);

    // 안내 문구는 잠깐 뒤 사라진다
    await tester.pumpAndSettle();
    expect(find.text('용어를 스크랩했어요'), findsNothing);
  });

  testWidgets('용어집에서 북마크를 누르면 목록에서 빠진다', (tester) async {
    savedStore.toggleTerm(term);
    await tester.pumpWidget(const MaterialApp(home: SavedTermsScreen()));
    expect(find.text(term.meaning), findsOneWidget);

    await tester.tap(find.byIcon(Icons.bookmark_rounded));
    await tester.pump();

    expect(find.text(term.meaning), findsNothing);
    expect(find.textContaining('저장한 용어가 없어요'), findsOneWidget);
    expect(find.text('용어 스크랩을 취소했어요'), findsOneWidget);
    await tester.pumpAndSettle();
  });

  testWidgets('기사가 1개면 홈 카드 상단은 1 / 1, 화살표는 눌리지 않는다', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: MainShell()));
    await tester.pumpAndSettle();

    expect(find.text('1 / 1'), findsOneWidget);
    for (final tip in ['이전 기사', '다음 기사']) {
      final button = tester.widget<IconButton>(
        find.ancestor(of: find.byTooltip(tip), matching: find.byType(IconButton)),
      );
      expect(button.onPressed, isNull);
    }
  });

  testWidgets('하단 메뉴에서 MY를 누르면 기사집·용어집·퀴즈집이 보인다', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: MainShell()));

    await tester.tap(find.text('MY'));
    await tester.pumpAndSettle();

    expect(find.text('기사집'), findsOneWidget);
    expect(find.text('용어집'), findsOneWidget);
    expect(find.text('퀴즈집'), findsOneWidget);
  });
}
