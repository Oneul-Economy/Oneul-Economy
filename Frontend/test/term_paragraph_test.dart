import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oneul_economy/models/news.dart';
import 'package:oneul_economy/utils/term_matcher.dart';
import 'package:oneul_economy/widgets/term_paragraph.dart';

void main() {
  const text = '삼성전자 노동조합(노조)은 오늘 파업을 선언했다.';
  const meaning = '노동자들이 모여 회사와 협상하는 단체';
  const term = Term(word: '노동조합', meaning: meaning);

  Future<void> pumpParagraph(WidgetTester tester) async {
    final hits = findTermHits([text], [term]);
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: TermParagraph(text: text, hits: hits[0]),
        ),
      ),
    );
  }

  testWidgets('용어를 누르면 바텀시트에 설명이 보인다', (tester) async {
    await pumpParagraph(tester);

    await tester.tapOnText(find.textRange.ofSubstring('노동조합'));
    await tester.pumpAndSettle();

    expect(find.byType(BottomSheet), findsOneWidget);
    expect(find.text(meaning), findsOneWidget);
  });

  testWidgets('용어가 아닌 글자를 누르면 바텀시트가 뜨지 않는다', (tester) async {
    await pumpParagraph(tester);

    await tester.tapOnText(find.textRange.ofSubstring('파업'));
    await tester.pumpAndSettle();

    expect(find.byType(BottomSheet), findsNothing);
    expect(find.text(meaning), findsNothing);
  });
}
