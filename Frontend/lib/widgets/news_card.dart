import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/news.dart';
import '../theme/app_colors.dart';

/// 홈 화면의 다크 뉴스 카드 (Figma 교육형 홈 카드, node 15-35).
///
/// `종목명 · N분` → 제목 → 요약 → 읽기 버튼 순서. 카드 어디를 눌러도 [onTap].
class NewsCard extends StatelessWidget {
  const NewsCard({super.key, required this.news, required this.onTap});

  final News news;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.ink,
      borderRadius: BorderRadius.circular(24),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 26, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${news.stockName} · ${news.readMinutes}분',
                style: GoogleFonts.notoSansKr(
                  color: AppColors.gold,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.6,
                ),
              ),
              const SizedBox(height: 18),
              Text(
                news.title,
                style: GoogleFonts.notoSerifKr(
                  color: AppColors.paper,
                  fontSize: 30,
                  fontWeight: FontWeight.w700,
                  height: 1.25,
                  letterSpacing: -0.8,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                news.summary,
                style: GoogleFonts.notoSansKr(
                  color: AppColors.onInkMuted,
                  fontSize: 14,
                  height: 1.6,
                ),
              ),
              const SizedBox(height: 24),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.paper,
                  borderRadius: BorderRadius.circular(14),
                ),
                alignment: Alignment.center,
                child: Text(
                  '본문 읽기',
                  style: GoogleFonts.notoSansKr(
                    color: AppColors.ink,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
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
