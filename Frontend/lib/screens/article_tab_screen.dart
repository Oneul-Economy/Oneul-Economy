import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_fonts.dart';

class ArticleTabScreen extends StatefulWidget {
  const ArticleTabScreen({super.key});

  @override
  State<ArticleTabScreen> createState() => _ArticleTabScreenState();
}

class _ArticleTabScreenState extends State<ArticleTabScreen> {
  String _selectedFilter = '전체';
  final Set<int> _savedIndices = {};

  static const _filters = ['전체', '내 종목', '관심 키워드', '저장한 기사'];

  static const _articles = [
    _MockArticle(
      stockTag: '삼성전자',
      hashTags: ['#노동조합', '#임금교섭'],
      title: '삼성전자에 노조가 또 생긴다고요?',
      summary: '여섯 번째 노조 설립신고서가 접수됐어요. 임금교섭 구도가 바뀔 수 있어요.',
      meta: '오늘 · 1분',
      statusText: '✓ 읽음 · 퀴즈 2/3',
    ),
    _MockArticle(
      stockTag: 'SK하이닉스',
      hashTags: ['#HBM', '#실적'],
      title: 'HBM 주문, 내년 물량까지 이미 찼다',
      summary: 'AI 서버용 메모리 수요가 이어지며 내년 생산분 계약이 마무리됐어요.',
      meta: '오늘 · 3분',
    ),
    _MockArticle(
      stockTag: '현대차',
      hashTags: ['#환율', '#수출'],
      title: '원·달러 1,400원대, 자동차엔 호재일까',
      summary: '환율이 오르면 수출 기업 이익이 늘지만, 원자재 부담도 함께 커져요.',
      meta: '오늘 · 4분',
    ),
    _MockArticle(
      hashTags: ['#반도체', '#메모리가격'],
      title: 'D램 가격, 석 달 만에 반등',
      summary: '재고가 줄면서 메모리 가격이 다시 오르기 시작했어요.',
      meta: '어제 · 2분',
    ),
    _MockArticle(
      stockTag: 'NAVER',
      hashTags: ['#AI', '#광고'],
      title: '네이버, AI 검색 광고 매출 첫 공개',
      summary: '검색 결과에 붙는 AI 요약 광고가 새 수익원이 될 수 있을지 짚어봐요.',
      meta: '어제 · 3분',
    ),
    _MockArticle(
      hashTags: ['#금리', '#환율'],
      title: '한은, 기준금리 동결… 내년 인하 신호',
      summary: '금리가 내리면 내 종목과 환율에는 어떤 일이 생길지 정리했어요.',
      meta: '2일 전 · 3분',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final visibleIndices = <int>[];
    for (var i = 0; i < _articles.length; i++) {
      final a = _articles[i];
      if (_selectedFilter == '전체') {
        visibleIndices.add(i);
      } else if (_selectedFilter == '내 종목' && a.stockTag != null) {
        visibleIndices.add(i);
      } else if (_selectedFilter == '관심 키워드' && a.stockTag == null) {
        visibleIndices.add(i);
      } else if (_selectedFilter == '저장한 기사' && _savedIndices.contains(i)) {
        visibleIndices.add(i);
      }
    }

    return Scaffold(
      backgroundColor: AppColors.paper,
      body: SafeArea(
        child: ListView(
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
                  onPressed: () {},
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
                      horizontal: 10,
                      vertical: 6,
                    ),
                    minimumSize: Size.zero,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              '삼성전자 · SK하이닉스 · 현대차 · NAVER  |  반도체 · 환율 · AI',
              style: TextStyle(
                fontFamily: AppFonts.sans,
                color: AppColors.muted,
                fontSize: 11,
              ),
            ),
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
            if (visibleIndices.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 48),
                child: Center(
                  child: Text(
                    '저장한 기사가 아직 없어요',
                    style: TextStyle(
                      fontFamily: AppFonts.sans,
                      color: AppColors.muted,
                      fontSize: 13,
                    ),
                  ),
                ),
              )
            else
              ...visibleIndices.map((index) {
                final article = _articles[index];
                final isSaved = _savedIndices.contains(index);
                return _ArticleCard(
                  article: article,
                  isSaved: isSaved,
                  onToggleSave: () {
                    setState(() {
                      isSaved
                          ? _savedIndices.remove(index)
                          : _savedIndices.add(index);
                    });
                  },
                );
              }),

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
    );
  }
}

class _MockArticle {
  const _MockArticle({
    this.stockTag,
    required this.hashTags,
    required this.title,
    required this.summary,
    required this.meta,
    this.statusText,
  });

  final String? stockTag;
  final List<String> hashTags;
  final String title;
  final String summary;
  final String meta;
  final String? statusText;
}

class _ArticleCard extends StatelessWidget {
  const _ArticleCard({
    required this.article,
    required this.isSaved,
    required this.onToggleSave,
  });

  final _MockArticle article;
  final bool isSaved;
  final VoidCallback onToggleSave;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.ink.withValues(alpha: 0.06)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              if (article.stockTag != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.ink,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    article.stockTag!,
                    style: TextStyle(
                      fontFamily: AppFonts.sans,
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ...article.hashTags.map(
                (tag) => Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.paper,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    tag,
                    style: TextStyle(
                      fontFamily: AppFonts.sans,
                      color: AppColors.muted,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            article.title,
            style: TextStyle(
              fontFamily: AppFonts.serif,
              color: AppColors.ink,
              fontSize: 16,
              fontWeight: FontWeight.w700,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            article.summary,
            style: TextStyle(
              fontFamily: AppFonts.sans,
              color: AppColors.muted,
              fontSize: 12,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Text(
                article.meta,
                style: TextStyle(
                  fontFamily: AppFonts.sans,
                  color: AppColors.muted,
                  fontSize: 11,
                ),
              ),
              if (article.statusText != null) ...[
                const SizedBox(width: 8),
                Text(
                  article.statusText!,
                  style: TextStyle(
                    fontFamily: AppFonts.sans,
                    color: AppColors.ink,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
              const Spacer(),
              InkWell(
                onTap: onToggleSave,
                child: Icon(
                  isSaved ? Icons.bookmark : Icons.bookmark_border,
                  size: 18,
                  color: AppColors.ink,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}