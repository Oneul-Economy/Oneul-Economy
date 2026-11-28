import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../api/news_api.dart';
import '../models/news.dart';
import '../models/quiz.dart';
import '../stores/portfolio_store.dart';
import '../stores/saved_store.dart';
import '../theme/app_colors.dart';
import '../theme/app_fonts.dart';
import '../utils/number_format.dart';
import '../widgets/news_card.dart';
import '../widgets/toast.dart';
import 'journal_screens.dart';
import 'main_shell.dart';
import 'news_detail_screen.dart';

/// 서버에 연결하지 못할 때 쓰는 샘플 JSON 기사들.
const _mockNewsFiles = ['assets/mock/news.json'];
const _mockQuizFile = 'assets/mock/quiz.json';

/// 기사 목록과, 그게 서버에서 왔는지(false면 샘플 JSON).
typedef NewsLoadResult = ({List<News> news, bool fromServer});

/// 오늘의 기사 목록. 서버(`GET /news`)에서 받고,
/// 서버가 꺼져 있거나 기사가 하나도 없으면 샘플 JSON으로 대신한다.
Future<NewsLoadResult> loadNewsListWithSource() async {
  try {
    final list = await fetchNewsList();
    if (list.isNotEmpty) return (news: list, fromServer: true);
    debugPrint('[News] 서버에 기사가 없어 샘플 기사를 씀');
  } catch (e) {
    debugPrint('[News] 서버 대신 샘플 기사를 씀: $e');
  }
  return (news: await loadMockNewsList(), fromServer: false);
}

Future<List<News>> loadNewsList() async =>
    (await loadNewsListWithSource()).news;

/// 샘플 JSON에서 기사 목록을 읽는다.
Future<List<News>> loadMockNewsList() async {
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

/// 홈 (Figma 홈, node 129-58):
/// 헤더 → 내 투자 → 오늘의 브리핑 카드 → 오늘의 용어 → 오늘의 일지.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, this.initialNewsList, this.initialQuiz});

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
      MaterialPageRoute(
        builder: (_) => NewsDetailScreen(news: news, quiz: _quiz),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.paper,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
          children: [
            const _HomeHeader(),
            const SizedBox(height: 16),
            Container(height: 1.5, color: AppColors.ink),
            const SizedBox(height: 14),
            const _MyInvestmentRow(),
            const SizedBox(height: 14),
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
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // 카드가 바뀔 때 살짝 페이드
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 200),
                      child: NewsCard(
                        key: ValueKey(news.id),
                        news: news,
                        onTap: () => _openDetail(news),
                        pager: NewsCardPager(
                          index: _index,
                          total: list.length,
                          onPrev: () => setState(() => _index--),
                          onNext: () => setState(() => _index++),
                        ),
                      ),
                    ),
                    if (list.length > 1) ...[
                      const SizedBox(height: 10),
                      NewsPagerDots(index: _index, total: list.length),
                    ],
                    if (news.terms.isNotEmpty) ...[
                      const SizedBox(height: 24),
                      _TodayTerm(news: news, term: news.terms.first),
                    ],
                  ],
                );
              },
            ),
            const SizedBox(height: 28),
            const _TodayJournal(),
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
    'JAN', 'FEB', 'MAR', 'APR', 'MAY', 'JUN', //
    'JUL', 'AUG', 'SEP', 'OCT', 'NOV', 'DEC',
  ];
  static const _weekdays = [
    'MONDAY', 'TUESDAY', 'WEDNESDAY', 'THURSDAY', //
    'FRIDAY', 'SATURDAY', 'SUNDAY',
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
                  fontSize: 23,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                date,
                style: TextStyle(
                  fontFamily: AppFonts.sans,
                  color: AppColors.muted,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.44,
                ),
              ),
            ],
          ),
        ),
        const Icon(Icons.notifications_none, color: AppColors.ink, size: 26),
      ],
    );
  }
}

/// `내 투자 12,342,500원  >` — 누르면 포트폴리오 탭으로.
class _MyInvestmentRow extends StatelessWidget {
  const _MyInvestmentRow();

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: portfolioStore,
      builder: (context, _) {
        final total = portfolioStore.totalKrw;
        return InkWell(
          onTap: () => MainShell.selectTab(context, MainShell.portfolio),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: Row(
              children: [
                Text(
                  '내 투자',
                  style: TextStyle(
                    fontFamily: AppFonts.sans,
                    color: AppColors.muted,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  total == null ? '포트폴리오를 등록해 주세요' : formatMoney(total, 'KRW'),
                  style: TextStyle(
                    fontFamily: AppFonts.sans,
                    color: total == null ? AppColors.muted : AppColors.ink,
                    fontSize: 13,
                    fontWeight: total == null
                        ? FontWeight.w400
                        : FontWeight.w700,
                  ),
                ),
                const Spacer(),
                const Icon(
                  Icons.chevron_right,
                  size: 16,
                  color: AppColors.muted,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// 오늘의 용어: 지금 보는 기사의 첫 용어.
class _TodayTerm extends StatelessWidget {
  const _TodayTerm({required this.news, required this.term});

  final News news;
  final Term term;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([savedStore, portfolioStore]),
      builder: (context, _) {
        final saved = savedStore.isTermSaved(term);
        final mine = portfolioStore.stockNames.contains(news.stockName);
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Text(
                  '오늘의 용어',
                  style: TextStyle(
                    fontFamily: AppFonts.serif,
                    color: AppColors.ink,
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const Spacer(),
                InkWell(
                  onTap: () {
                    savedStore.toggleTerm(term);
                    showToast(context, saved ? '용어 스크랩을 취소했어요' : '용어를 스크랩했어요');
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Text(
                      saved ? '용어집에 담김 ✓' : '용어집에 담기',
                      style: TextStyle(
                        fontFamily: AppFonts.sans,
                        color: saved ? AppColors.ink : AppColors.muted,
                        fontSize: 13,
                        fontWeight: saved ? FontWeight.w600 : FontWeight.w400,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    term.word,
                    style: TextStyle(
                      fontFamily: AppFonts.serif,
                      color: AppColors.ink,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    term.meaning,
                    style: TextStyle(
                      fontFamily: AppFonts.sans,
                      color: const Color(0xFF2A2C31),
                      fontSize: 13,
                      height: 1.6,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Container(height: 1, color: const Color(0xFFEFECE6)),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Text(
                        mine ? '내 종목과 연결' : '관련 종목',
                        style: TextStyle(
                          fontFamily: AppFonts.sans,
                          color: AppColors.muted,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(color: const Color(0xFFE4E0D8)),
                        ),
                        child: Text(
                          news.stockName,
                          style: TextStyle(
                            fontFamily: AppFonts.sans,
                            color: const Color(0xFF2A2C31),
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

/// 오늘의 일지: 'JOURNAL · N번째 기록  지난 기록 ›' + 질문 + 노트 카드.
class _TodayJournal extends StatelessWidget {
  const _TodayJournal();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Text(
              'JOURNAL · ${journalEntryCount + 1}번째 기록',
              style: TextStyle(
                fontFamily: AppFonts.sans,
                color: const Color(0xFF8A7F6E),
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.1,
              ),
            ),
            const Spacer(),
            InkWell(
              onTap: () => MainShell.selectTab(context, MainShell.journal),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Text(
                  '지난 기록 ›',
                  style: TextStyle(
                    fontFamily: AppFonts.sans,
                    color: AppColors.muted,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          '오늘 시장을 보며\n어떤 생각을 했나요?',
          style: TextStyle(
            fontFamily: AppFonts.serif,
            color: AppColors.ink,
            fontSize: 20,
            fontWeight: FontWeight.w700,
            height: 1.38,
          ),
        ),
        const SizedBox(height: 4),
        const JournalPromptCard(),
      ],
    );
  }
}
