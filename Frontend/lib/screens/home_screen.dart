import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/news.dart';
import '../models/quiz.dart';
import '../theme/app_colors.dart';
import '../theme/app_fonts.dart';
import '../widgets/news_card.dart';
import 'news_detail_screen.dart';
import 'quiz_screen.dart';

/// 앱에 넣어 둔 샘플 JSON 기사들. (서버 연결 전 임시)
/// 기사가 늘어나면 여기에 파일을 추가하면 카드 상단 `< 1 / N >`으로 넘길 수 있다.
const _mockNewsFiles = ['assets/mock/news.json'];
const _mockQuizFile = 'assets/mock/quiz.json';

/// 샘플 JSON에서 오늘의 기사 목록을 읽는다.
Future<List<News>> loadNewsList() async {
  return Future.wait(
    _mockNewsFiles.map((path) async {
      final text = await rootBundle.loadString(path);
      return News.fromJson(jsonDecode(text) as Map<String, dynamic>);
    }),
  );
}

/// 샘플 JSON에서 용어 퀴즈를 읽는다. 실패하면 null을 반환한다.
Future<Quiz?> loadQuiz() async {
  try {
    final text = await rootBundle.loadString(_mockQuizFile);
    return Quiz.fromJson(jsonDecode(text) as Map<String, dynamic>);
  } catch (e) {
    debugPrint('[Quiz] 퀴즈 로드 실패 (파일 없음 또는 형식 오류): $e');
    return null;
  }
}

/// 해당 기사에 대해 용어 퀴즈를 열 수 있는지 판단하는 순수 함수.
bool canOpenQuiz(News news, Quiz? quiz) {
  if (quiz == null) return false;
  if (quiz.quizzes.isEmpty) return false;
  if (quiz.newsId != news.id) return false;
  return true;
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
    this.initialNewsList,
    this.initialQuiz,
  });

  /// 위젯 테스트에서 rootBundle 대신 데이터를 직접 주입할 때 사용.
  final List<News>? initialNewsList;
  final Quiz? initialQuiz;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final Future<List<News>> _newsFuture;
  Quiz? _quiz;

  /// 지금 보고 있는 기사 카드 (0부터).
  int _index = 0;

  @override
  void initState() {
    super.initState();
    _newsFuture = widget.initialNewsList != null
        ? Future.value(widget.initialNewsList)
        : loadNewsList();

    if (widget.initialNewsList != null) {
      _quiz = widget.initialQuiz;
    } else {
      _loadQuizSeparately();
    }
  }

  /// 뉴스와 별도로 퀴즈를 불러온다. 퀴즈 실패가 뉴스 카드에 영향을 주지 않게 하기 위함.
  Future<void> _loadQuizSeparately() async {
    final loaded = await loadQuiz();
    if (!mounted) return;
    setState(() => _quiz = loaded);
  }

  void _openDetail(News news) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => NewsDetailScreen(news: news)),
    );
  }

  void _handleQuizTap(News news, int quizIndex) {
    if (quizIndex != 1) {
      _showQuizComingSoon(quizIndex);
      return;
    }

    if (!canOpenQuiz(news, _quiz)) {
      if (_quiz == null) {
        debugPrint('[Quiz] 준비 중 처리: 퀴즈 데이터 없음 (파일 없음/형식 오류)');
      } else if (_quiz!.quizzes.isEmpty) {
        debugPrint('[Quiz] 준비 중 처리: 퀴즈 문제가 0개');
      } else if (_quiz!.newsId != news.id) {
        debugPrint(
          '[Quiz] 준비 중 처리: news_id 불일치 (기사: ${news.id}, 퀴즈: ${_quiz!.newsId})',
        );
      }
      _showQuizComingSoon(quizIndex);
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => QuizScreen(quiz: _quiz!, news: news),
      ),
    );
  }

  void _showQuizComingSoon(int index) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text('퀴즈 ${index + 1}은(는) 준비 중이에요.')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.paper,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
          children: [
            const _HomeHeader(),
            const SizedBox(height: 14),
            Container(height: 1.5, color: AppColors.ink),
            const SizedBox(height: 20),
            FutureBuilder<List<News>>(
              future: _newsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState != ConnectionState.done) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 48),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
                if (snapshot.hasError) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 48),
                    child: Center(
                      child: Text(
                        '뉴스를 불러오지 못했어요.\n${snapshot.error}',
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                }
                final list = snapshot.data!;
                if (list.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 48),
                    child: Center(child: Text('오늘의 기사가 아직 없어요.')),
                  );
                }
                final news = list[_index];
                // 카드가 바뀔 때 살짝 페이드
                return AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: NewsCard(
                    key: ValueKey(news.id),
                    news: news,
                    onTap: () => _openDetail(news),
                    onQuizTap: (quizIndex) => _handleQuizTap(news, quizIndex),
                    pager: NewsCardPager(
                      index: _index,
                      total: list.length,
                      onPrev: () => setState(() => _index--),
                      onNext: () => setState(() => _index++),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

/// "오늘의 경제" 타이틀 + 날짜 + 알림 아이콘.
class _HomeHeader extends StatelessWidget {
  const _HomeHeader();

  static const _months = [
    'JAN',
    'FEB',
    'MAR',
    'APR',
    'MAY',
    'JUN',
    'JUL',
    'AUG',
    'SEP',
    'OCT',
    'NOV',
    'DEC',
  ];
  static const _weekdays = [
    'MONDAY',
    'TUESDAY',
    'WEDNESDAY',
    'THURSDAY',
    'FRIDAY',
    'SATURDAY',
    'SUNDAY',
  ];

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final date =
        '${_months[now.month - 1]} ${now.day} · ${_weekdays[now.weekday - 1]}';

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '오늘의 경제',
                style: TextStyle(
                  fontFamily: AppFonts.serif,
                  color: AppColors.ink,
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  height: 1.2,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                date,
                style: TextStyle(
                  fontFamily: AppFonts.sans,
                  color: AppColors.muted,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.4,
                ),
              ),
            ],
          ),
        ),
        const Icon(
          Icons.notifications_none_rounded,
          color: AppColors.ink,
          size: 24,
        ),
      ],
    );
  }
}