import 'package:flutter/material.dart';

import '../models/news.dart';
import '../theme/app_colors.dart';
import '../theme/app_fonts.dart';

/// 홈 화면의 다크 뉴스 카드 (Figma 교육형 홈 카드, node 15-35).
///
/// `종목명 · N분` → 제목 → 요약 → 퀴즈 3개 → 본문 읽기 버튼 순서.
/// '본문 읽기' 버튼을 누르면 [onTap], 퀴즈 행을 누르면 [onQuizTap].
/// 카드의 나머지 부분은 눌러도 아무 일도 없다.
class NewsCard extends StatelessWidget {
  const NewsCard({
    super.key,
    required this.news,
    required this.onTap,
    this.onQuizTap,
    this.pager,
  });

  final News news;
  final VoidCallback onTap;

  /// 카드 상단 `< 1 / 3 >` 넘기기. 없으면 표시하지 않는다.
  final NewsCardPager? pager;

  /// 몇 번째 퀴즈(0부터)를 눌렀는지 전달. 퀴즈 화면이 생기기 전까지는 비워 둬도 된다.
  final ValueChanged<int>? onQuizTap;

  // 퀴즈 데이터가 #3 형식에 아직 없어서 자리만 잡아 둔 임시 문구.
  static const _quizzes = [
    (label: 'OX 퀴즈 · 30초', title: '핵심 내용 맞혀 보기'),
    (label: '용어 퀴즈 · 30초', title: '오늘 나온 용어 뜻 고르기'),
    (label: '생각 퀴즈 · 1분', title: '내 종목에는 어떤 영향일까'),
  ];

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.ink,
      borderRadius: BorderRadius.circular(24),
      clipBehavior: Clip.antiAlias,
      child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 26, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      '${news.stockName} · ${news.readMinutes}분',
                      style: TextStyle(
                        fontFamily: AppFonts.sans,
                        color: AppColors.gold,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.6,
                      ),
                    ),
                  ),
                  // `< 1 / N >`. 기사가 1개면 `1 / 1`에 화살표는 둘 다 비활성
                  if (pager != null) _Pager(pager: pager!),
                ],
              ),
              const SizedBox(height: 18),
              Text(
                news.title,
                style: TextStyle(
                  fontFamily: AppFonts.serif,
                  color: AppColors.paper,
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                  height: 1.25,
                  letterSpacing: -0.8,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                news.summary,
                style: TextStyle(
                  fontFamily: AppFonts.sans,
                  color: AppColors.onInkMuted,
                  fontSize: 14,
                  height: 1.6,
                ),
              ),
              const SizedBox(height: 20),
              const Divider(
                height: 1,
                thickness: 1,
                color: AppColors.inkDivider,
              ),
              for (var i = 0; i < _quizzes.length; i++)
                _QuizRow(
                  number: i + 1,
                  label: _quizzes[i].label,
                  title: _quizzes[i].title,
                  onTap: () => onQuizTap?.call(i),
                ),
              const SizedBox(height: 18),
              // 본문으로 가는 곳은 이 버튼 하나뿐 (카드 나머지 부분은 눌러도 이동 안 함)
              Material(
                color: AppColors.paper,
                borderRadius: BorderRadius.circular(14),
                clipBehavior: Clip.antiAlias,
                child: InkWell(
                  onTap: onTap,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    alignment: Alignment.center,
                    child: Text(
                      '본문 읽기',
                      style: TextStyle(
                        fontFamily: AppFonts.sans,
                        color: AppColors.ink,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
    );
  }
}

/// 카드 상단 넘기기에 필요한 값. [index]는 0부터.
class NewsCardPager {
  const NewsCardPager({
    required this.index,
    required this.total,
    required this.onPrev,
    required this.onNext,
  });

  final int index;
  final int total;
  final VoidCallback onPrev;
  final VoidCallback onNext;
}

/// `< 1 / 3 >`. 처음/끝에서는 해당 화살표를 흐리게 하고 누를 수 없게 한다.
class _Pager extends StatelessWidget {
  const _Pager({required this.pager});

  final NewsCardPager pager;

  @override
  Widget build(BuildContext context) {
    final hasPrev = pager.index > 0;
    final hasNext = pager.index < pager.total - 1;

    Widget arrow(IconData icon, bool enabled, VoidCallback onTap, String tip) {
      return IconButton(
        onPressed: enabled ? onTap : null,
        tooltip: tip,
        icon: Icon(icon, size: 20),
        color: AppColors.onInkMuted,
        disabledColor: AppColors.inkRing,
        visualDensity: VisualDensity.compact,
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints.tightFor(width: 32, height: 32),
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        arrow(Icons.chevron_left_rounded, hasPrev, pager.onPrev, '이전 기사'),
        Text(
          '${pager.index + 1} / ${pager.total}',
          style: TextStyle(
            fontFamily: AppFonts.sans,
            color: AppColors.onInkMuted,
            fontSize: 12,
            fontWeight: FontWeight.w600,
            letterSpacing: 1,
          ),
        ),
        arrow(Icons.chevron_right_rounded, hasNext, pager.onNext, '다음 기사'),
      ],
    );
  }
}

/// 카드 안 퀴즈 한 줄: `01 | 라벨 / 제목 | 빈 원` (Figma 01~03 행 스타일).
class _QuizRow extends StatelessWidget {
  const _QuizRow({
    required this.number,
    required this.label,
    required this.title,
    required this.onTap,
  });

  final int number;
  final String label;
  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: AppColors.inkDivider)),
        ),
        child: Row(
          children: [
            SizedBox(
              width: 30,
              child: Text(
                number.toString().padLeft(2, '0'),
                style: TextStyle(
                  fontFamily: AppFonts.serif,
                  color: AppColors.gold,
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontFamily: AppFonts.sans,
                      color: AppColors.onInkSubtle,
                      fontSize: 11,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: AppFonts.sans,
                      color: AppColors.paper,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 14),
            // Figma 빈 원 아이콘: 20×20 안에 지름 17, 선 두께 1.5
            SizedBox.square(
              dimension: 20,
              child: Center(
                child: Container(
                  width: 17,
                  height: 17,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.inkRing, width: 1.5),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
