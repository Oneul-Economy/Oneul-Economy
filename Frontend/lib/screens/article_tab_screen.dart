import 'package:flutter/material.dart';

import '../models/news.dart';
import '../stores/portfolio_store.dart';
import '../stores/saved_store.dart';
import '../theme/app_colors.dart';
import '../theme/app_fonts.dart';
import '../widgets/save_button.dart';
import '../widgets/toast.dart';
import 'home_screen.dart' show loadNewsListWithSource;
import 'news_detail_screen.dart';

/// 본문이 아직 없는 기사 = 준비 중.
bool _isReady(News news) => news.body.isNotEmpty;

News _preview(
  String id,
  String stock,
  List<String> tags,
  String title,
  String summary,
  int daysAgo,
  int minutes,
) {
  return News(
    id: 'preview-$id',
    stockName: stock,
    title: title,
    summary: summary,
    readMinutes: minutes,
    body: const [],
    terms: [for (final t in tags) Term(word: t, meaning: '')],
    source: NewsSource(
      press: '',
      url: '',
      publishedAt: DateTime.now().subtract(Duration(days: daysAgo)),
    ),
  );
}

/// 서버 없이 샘플 기사로 볼 때 목록을 채우는 '준비 중' 기사들.
final _upcomingPreviews = [
  _preview(
    '1',
    'SK하이닉스',
    ['HBM', '실적'],
    'HBM 주문, 내년 물량까지 이미 찼다',
    'AI 서버용 메모리 수요가 이어지며 내년 생산분 계약이 마무리됐어요.',
    0,
    3,
  ),
  _preview(
    '2',
    '현대차',
    ['환율', '수출'],
    '원·달러 1,400원대, 자동차엔 호재일까',
    '환율이 오르면 수출 기업 이익이 늘지만, 원자재 부담도 함께 커져요.',
    0,
    4,
  ),
  _preview(
    '3',
    'NAVER',
    ['AI', '광고'],
    '네이버, AI 검색 광고 매출 첫 공개',
    '검색 결과에 붙는 AI 요약 광고가 새 수익원이 될 수 있을지 짚어봐요.',
    1,
    3,
  ),
  _preview(
    '4',
    '삼성전자',
    ['금리', '환율'],
    '한은, 기준금리 동결… 내년 인하 신호',
    '금리가 내리면 내 종목과 환율에는 어떤 일이 생길지 정리했어요.',
    2,
    3,
  ),
];

class ArticleTabScreen extends StatefulWidget {
  const ArticleTabScreen({super.key, this.initialNewsList});

  /// 위젯 테스트에서 서버 대신 기사를 직접 넣을 때 사용.
  final List<News>? initialNewsList;

  @override
  State<ArticleTabScreen> createState() => _ArticleTabScreenState();
}

class _ArticleTabScreenState extends State<ArticleTabScreen> {
  String _selectedFilter = '전체';
  late Future<List<News>> _newsFuture = _load();

  static const _filters = ['전체', '내 종목', '저장한 기사'];

  /// 서버(`GET /news`)에서 받고, 안 되면 샘플 기사 + '준비 중' 기사들.
  Future<List<News>> _load() async {
    if (widget.initialNewsList != null) return widget.initialNewsList!;
    final r = await loadNewsListWithSource();
    return r.fromServer ? r.news : [...r.news, ..._upcomingPreviews];
  }

  void _open(News news) {
    if (!_isReady(news)) {
      showToast(context, '준비 중입니다');
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => NewsDetailScreen(news: news)),
    );
  }

  /// 재추천: 기사를 다시 받는다.
  void _reload() => setState(() => _newsFuture = _load());

  List<News> _visible(List<News> all) {
    final mine = portfolioStore.stockNames.toSet();
    return switch (_selectedFilter) {
      '내 종목' => all.where((n) => mine.contains(n.stockName)).toList(),
      '저장한 기사' => all.where(savedStore.isNewsSaved).toList(),
      _ => all,
    };
  }

  String _emptyText() => switch (_selectedFilter) {
    '내 종목' =>
      portfolioStore.isEmpty
          ? '포트폴리오에 종목을 등록하면 내 종목 기사가 모여요'
          : '오늘은 내 종목 기사가 없어요',
    '저장한 기사' => '저장한 기사가 아직 없어요',
    _ => '오늘의 기사가 아직 없어요',
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.paper,
      body: SafeArea(
        child: ListenableBuilder(
          listenable: Listenable.merge([portfolioStore, savedStore]),
          builder: (context, _) => ListView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
            children: [
              // 상단 헤더
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '기사',
                    style: TextStyle(
                      fontFamily: AppFonts.serif,
                      color: AppColors.ink,
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.search, color: AppColors.ink),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Divider(color: AppColors.ink.withValues(alpha: 0.15), height: 1),
              const SizedBox(height: 16),

              // FOR YOU 영역
              Text(
                'FOR YOU',
                style: TextStyle(
                  fontFamily: AppFonts.sans,
                  color: AppColors.muted,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.0,
                ),
              ),
              const SizedBox(height: 6),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      '투자 종목과 관심 분야를\n기준으로 선별된 기사입니다',
                      style: TextStyle(
                        fontFamily: AppFonts.serif,
                        color: AppColors.ink,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        height: 1.35,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  OutlinedButton.icon(
                    onPressed: _reload,
                    icon: const Icon(Icons.refresh, size: 14),
                    label: Text(
                      '재추천',
                      style: TextStyle(
                        fontFamily: AppFonts.sans,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.ink,
                      backgroundColor: Colors.white,
                      side: BorderSide(
                        color: AppColors.ink.withValues(alpha: 0.14),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 11,
                      ),
                      minimumSize: Size.zero,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                  ),
                ],
              ),
              if (!portfolioStore.isEmpty) ...[
                const SizedBox(height: 6),
                Text(
                  portfolioStore.stockNames.join(' · '),
                  style: TextStyle(
                    fontFamily: AppFonts.sans,
                    color: AppColors.muted,
                    fontSize: 11,
                  ),
                ),
              ],
              const SizedBox(height: 14),

              // 필터 칩
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: _filters.map((filter) {
                    final selected = filter == _selectedFilter;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: InkWell(
                        onTap: () => setState(() => _selectedFilter = filter),
                        borderRadius: BorderRadius.circular(18),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 7,
                          ),
                          decoration: BoxDecoration(
                            color: selected ? AppColors.ink : Colors.white,
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(
                              color: selected
                                  ? AppColors.ink
                                  : AppColors.ink.withValues(alpha: 0.12),
                            ),
                          ),
                          child: Text(
                            filter,
                            style: TextStyle(
                              fontFamily: AppFonts.sans,
                              color: selected ? Colors.white : AppColors.ink,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 16),

              // 기사 카드 리스트
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
                    return _Message('기사를 불러오지 못했어요.\n${snapshot.error}');
                  }
                  final visible = _visible(snapshot.data!);
                  if (visible.isEmpty) return _Message(_emptyText());
                  return Column(
                    children: [
                      for (final news in visible)
                        _ArticleCard(
                          news: news,
                          isSaved: savedStore.isNewsSaved(news),
                          onToggleSave: _isReady(news)
                              ? () => savedStore.toggleNews(news)
                              : null,
                          onTap: () => _open(news),
                        ),
                    ],
                  );
                },
              ),

              const SizedBox(height: 8),
              Center(
                child: Text(
                  '매일 아침 7시, 새 기사로 업데이트돼요',
                  style: TextStyle(
                    fontFamily: AppFonts.sans,
                    color: AppColors.muted,
                    fontSize: 11,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Message extends StatelessWidget {
  const _Message(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 48),
      child: Center(
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: AppFonts.sans,
            color: AppColors.muted,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}

/// "오늘 · 3분", "어제 · 2분", "3일 전 · 4분", 그보다 오래되면 "11월 5일 · 3분".
String _metaText(News news) {
  final d = news.source.publishedAt.toLocal();
  final now = DateTime.now();
  final days = DateTime(
    now.year,
    now.month,
    now.day,
  ).difference(DateTime(d.year, d.month, d.day)).inDays;
  final when = switch (days) {
    <= 0 => '오늘',
    1 => '어제',
    < 7 => '$days일 전',
    _ => '${d.month}월 ${d.day}일',
  };
  return '$when · ${news.readMinutes}분';
}

class _ArticleCard extends StatelessWidget {
  const _ArticleCard({
    required this.news,
    required this.isSaved,
    required this.onToggleSave,
    required this.onTap,
  });

  final News news;
  final bool isSaved;

  /// null이면 준비 중인 기사라 저장 대신 '준비 중' 표시.
  final VoidCallback? onToggleSave;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    // 기사에 나온 용어 앞 두 개를 해시태그로
    final hashTags = news.terms.take(2).map((t) => '#${t.word}');

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.ink.withValues(alpha: 0.06)),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(14),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 8, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      _Tag(news.stockName, dark: true),
                      for (final tag in hashTags) _Tag(tag),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: Text(
                    news.title,
                    style: TextStyle(
                      fontFamily: AppFonts.serif,
                      color: AppColors.ink,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      height: 1.35,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: Text(
                    news.summary,
                    style: TextStyle(
                      fontFamily: AppFonts.sans,
                      color: AppColors.muted,
                      fontSize: 12,
                      height: 1.45,
                    ),
                  ),
                ),
                Row(
                  children: [
                    Text(
                      _metaText(news),
                      style: TextStyle(
                        fontFamily: AppFonts.sans,
                        color: AppColors.muted,
                        fontSize: 11,
                      ),
                    ),
                    const Spacer(),
                    if (onToggleSave != null)
                      SaveButton(
                        saved: isSaved,
                        onPressed: onToggleSave!,
                        kind: '기사',
                      )
                    else
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 14,
                        ),
                        child: Text(
                          '준비 중',
                          style: TextStyle(
                            fontFamily: AppFonts.sans,
                            color: AppColors.muted,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  const _Tag(this.text, {this.dark = false});
  final String text;
  final bool dark;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: dark ? AppColors.ink : AppColors.paper,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontFamily: AppFonts.sans,
          color: dark ? Colors.white : AppColors.muted,
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
