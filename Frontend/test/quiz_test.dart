import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oneul_economy/models/news.dart';
import 'package:oneul_economy/models/quiz.dart';
import 'package:oneul_economy/screens/home_screen.dart';
import 'package:oneul_economy/screens/quiz_result_screen.dart';
import 'package:oneul_economy/screens/quiz_screen.dart';
import 'package:oneul_economy/theme/app_colors.dart';

News _sampleNews({String id = '20261105-005930-002'}) => News(
      id: id,
      stockName: '삼성전자',
      title: '테스트 기사 제목',
      summary: '테스트 기사 요약입니다.',
      readMinutes: 2,
      body: const ['본문 첫 번째 문단입니다.'],
      terms: const [Term(word: 'HBM', meaning: '고대역폭 메모리')],
      source: NewsSource(
        press: '테스트경제',
        url: 'https://example.com',
        publishedAt: DateTime(2026, 11, 5),
      ),
    );

Quiz _sampleQuiz({String newsId = '20261105-005930-002'}) => Quiz(
      newsId: newsId,
      quizzes: const [
        QuizItem(
          id: '20261105-005930-002-q1',
          word: 'HBM',
          question: '문제 1 질문',
          choices: ['정답1', '오답1-1', '오답1-2', '오답1-3'],
          answerIndex: 0,
          explanation: '문제 1 해설입니다.',
        ),
        QuizItem(
          id: '20261105-005930-002-q2',
          word: '영업이익',
          question: '문제 2 질문',
          choices: ['오답2-1', '정답2', '오답2-2', '오답2-3'],
          answerIndex: 1,
          explanation: '문제 2 해설입니다.',
        ),
        QuizItem(
          id: '20261105-005930-002-q3',
          word: '파운드리',
          question: '문제 3 질문',
          choices: ['오답3-1', '오답3-2', '정답3', '오답3-3'],
          answerIndex: 2,
          explanation: '문제 3 해설입니다.',
        ),
      ],
    );

void main() {
  test('1. Quiz.fromJson이 #30 형식을 정상적으로 읽는다', () {
    final json = {
      'news_id': '20261105-005930-002',
      'quizzes': [
        {
          'id': '20261105-005930-002-q1',
          'word': '노동조합',
          'question': "다음 중 '노동조합'의 뜻으로 맞는 것은?",
          'choices': ['보기 1', '보기 2', '보기 3', '보기 4'],
          'answer_index': 2,
          'explanation': '직원들이 근로 조건을 함께 개선하려고 만든 단체예요.',
        },
      ],
    };

    final quiz = Quiz.fromJson(json);

    expect(quiz.newsId, '20261105-005930-002');
    expect(quiz.quizzes.length, 1);
    expect(quiz.quizzes.first.id, '20261105-005930-002-q1');
    expect(quiz.quizzes.first.word, '노동조합');
    expect(quiz.quizzes.first.answerIndex, 2);
    expect(quiz.quizzes.first.choices.length, 4);
  });

  testWidgets('2. 용어 행을 누르면 퀴즈 화면으로 이동하고, OX 행은 이동하지 않는다', (tester) async {
    final news = _sampleNews();
    final quiz = _sampleQuiz();

    await tester.pumpWidget(
      MaterialApp(
        home: HomeScreen(initialNewsList: [news], initialQuiz: quiz),
      ),
    );
    await tester.pumpAndSettle();

    // OX 행 클릭 → 이동하지 않음
    await tester.tap(find.text('OX 퀴즈 · 30초'));
    await tester.pumpAndSettle();
    expect(find.byType(QuizScreen), findsNothing);

    // 용어 행 클릭 → 퀴즈 화면으로 이동
    await tester.tap(find.text('용어 퀴즈 · 30초'));
    await tester.pumpAndSettle();
    expect(find.byType(QuizScreen), findsOneWidget);
  });

  testWidgets('3. 오답을 고르면 정답 보기가 강조되고 해설이 보인다', (tester) async {
    final news = _sampleNews();
    final quiz = _sampleQuiz();

    await tester.pumpWidget(
      MaterialApp(
        home: QuizScreen(quiz: quiz, news: news),
      ),
    );

    // 오답 선택
    await tester.tap(find.text('오답1-1'));
    await tester.pumpAndSettle();

    // 해설 표시 확인
    expect(find.text('문제 1 해설입니다.'), findsOneWidget);

    // 정답 보기 강조(테두리 AppColors.ink) 확인
    final correctButton = tester.widget<OutlinedButton>(
      find.ancestor(
        of: find.text('정답1'),
        matching: find.byType(OutlinedButton),
      ),
    );
    final side = correctButton.style?.side?.resolve({});
    expect(side?.color, AppColors.ink);
  });

  testWidgets('4. 마지막 문제 뒤 결과 화면에 점수(2/3)가 보인다', (tester) async {
    final news = _sampleNews();
    final quiz = _sampleQuiz();

    await tester.pumpWidget(
      MaterialApp(
        home: QuizScreen(quiz: quiz, news: news),
      ),
    );

    // 1번: 정답
    await tester.tap(find.text('정답1'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('다음 문제'));
    await tester.pumpAndSettle();

    // 2번: 오답
    await tester.tap(find.text('오답2-1'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('다음 문제'));
    await tester.pumpAndSettle();

    // 3번: 정답
    await tester.tap(find.text('정답3'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('결과 보기'));
    await tester.pumpAndSettle();

    expect(find.byType(QuizResultScreen), findsOneWidget);
    expect(find.text('2/3'), findsOneWidget);
    expect(find.text('영업이익'), findsOneWidget); // 틀린 용어 표시 확인
  });

  testWidgets('5. (실패 처리) news_id가 다른 퀴즈를 넣으면 용어 행을 눌러도 이동하지 않는다', (
    tester,
  ) async {
    final news = _sampleNews(id: '20261105-005930-002');
    final mismatchedQuiz = _sampleQuiz(newsId: '99999999-000000-000');

    expect(canOpenQuiz(news, mismatchedQuiz), isFalse);

    await tester.pumpWidget(
      MaterialApp(
        home: HomeScreen(initialNewsList: [news], initialQuiz: mismatchedQuiz),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('용어 퀴즈 · 30초'));
    await tester.pumpAndSettle();
    expect(find.byType(QuizScreen), findsNothing);
  });

  test('6. (목업 일치) assets/mock/quiz.json의 news_id가 news.json의 id와 같다', () {
    final newsJson = jsonDecode(
      File('assets/mock/news.json').readAsStringSync(),
    ) as Map<String, dynamic>;
    final quizJson = jsonDecode(
      File('assets/mock/quiz.json').readAsStringSync(),
    ) as Map<String, dynamic>;

    final news = News.fromJson(newsJson);
    final quiz = Quiz.fromJson(quizJson);

    expect(quiz.newsId, news.id);
    expect(quiz.quizzes, isNotEmpty);
  });
}