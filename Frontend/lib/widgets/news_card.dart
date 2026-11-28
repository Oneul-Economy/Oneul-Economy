import 'package:flutter/material.dart';

import '../models/news.dart';
import '../theme/app_colors.dart';
import '../theme/app_fonts.dart';

/// 홈 화면의 다크 '오늘의 브리핑' 카드 (Figma 홈, node 129-89).
///
/// `종목명 · N분  < 1 / 3 >` → 제목 → 요약 → 태그 칩 + 오른쪽 둥근 화살표 버튼.
/// 화살표(본문 읽기) 버튼을 누르면 [onTap]. 카드의 나머지 부분은 눌러도 아무 일도 없다.
class NewsCard extends StatelessWidget {
  const NewsCard({
    super.key,
    required this.news,
    required this.onTap,
    this.pager,
  });

  final News news;
  final VoidCallback onTap;

  /// 카드 상단 `< 1 / 3 >` 넘기기. 없으면 표시하지 않는다.
  final NewsCardPager? pager;

  @override
  Widget build(BuildContext context) {
    // 종목 + 기사에 나온 용어 두 개
    final chips = [news.stockName, ...news.terms.take(2).map((t) => t.word)];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 18),
      decoration: BoxDecoration(
        color: AppColors.ink,
        borderRadius: BorderRadius.circular(20),
      ),
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
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.72,
                  ),
                ),
              ),
              // `< 1 / N >`. 기사가 1개면 `1 / 1`에 화살표는 둘 다 비활성
              if (pager != null) _Pager(pager: pager!),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            news.title,
            style: TextStyle(
              fontFamily: AppFonts.serif,
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w700,
              height: 1.32,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            news.summary,
            style: TextStyle(
              fontFamily: AppFonts.sans,
              color: AppColors.onInkMuted,
              fontSize: 13,
              height: 1.6,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [for (final c in chips) _DarkChip(c)],
                ),
              ),
              const SizedBox(width: 10),
              // 본문으로 가는 곳은 이 버튼 하나뿐
              Material(
                color: AppColors.paper,
                shape: const CircleBorder(),
                clipBehavior: Clip.antiAlias,
                child: InkWell(
                  onTap: onTap,
                  child: Tooltip(
                    message: '본문 읽기',
                    child: const SizedBox(
                      width: 40,
                      height: 40,
                      child: Icon(
                        Icons.arrow_forward,
                        size: 18,
                        color: AppColors.ink,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DarkChip extends StatelessWidget {
  const _DarkChip(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.ink,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.inkRing),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontFamily: AppFonts.sans,
          color: AppColors.onInkMuted,
          fontSize: 11,
          fontWeight: FontWeight.w500,
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
        icon: Icon(icon, size: 16),
        color: AppColors.onInkMuted,
        disabledColor: AppColors.inkRing,
        visualDensity: VisualDensity.compact,
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints.tightFor(width: 24, height: 24),
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        arrow(Icons.chevron_left_rounded, hasPrev, pager.onPrev, '이전 기사'),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2),
          child: Text(
            '${pager.index + 1} / ${pager.total}',
            style: TextStyle(
              fontFamily: AppFonts.sans,
              color: AppColors.onInkMuted,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        arrow(Icons.chevron_right_rounded, hasNext, pager.onNext, '다음 기사'),
      ],
    );
  }
}

/// 카드 아래 점 페이지 표시. 지금 보는 기사는 긴 막대.
class NewsPagerDots extends StatelessWidget {
  const NewsPagerDots({super.key, required this.index, required this.total});

  final int index;
  final int total;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (var i = 0; i < total; i++)
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            margin: EdgeInsets.only(right: i == total - 1 ? 0 : 6),
            width: i == index ? 18 : 6,
            height: 6,
            decoration: BoxDecoration(
              color: i == index ? AppColors.ink : AppColors.onInkMuted,
              borderRadius: BorderRadius.circular(3),
            ),
          ),
      ],
    );
  }
}
