import 'package:flutter/material.dart';
import 'package:oneul_economy/theme/app_colors.dart';
import 'package:oneul_economy/theme/app_fonts.dart';

import '../models/news.dart';
import '../stores/saved_store.dart';
import '../utils/term_matcher.dart';
import '../widgets/save_button.dart';
import '../widgets/term_paragraph.dart';

import 'package:url_launcher/url_launcher.dart';

import '../models/quiz.dart';
import 'quiz_picker.dart';

class NewsDetailScreen extends StatelessWidget {
  const NewsDetailScreen({super.key, required this.news, this.quiz});
  final News news; // 팀원의 홈 화면 코드와 충돌하지 않도록 데이터 받는 통로 복구

  /// 미리 읽어 둔 용어 퀴즈 (홈·테스트). 없으면 퀴즈를 고를 때 읽는다.
  final Quiz? quiz;

  /// OX · 용어 · 생각 퀴즈 중 고르는 시트를 띄운다.
  Future<void> _openQuiz(BuildContext context) =>
      showQuizPicker(context, news, quiz: quiz);

  @override
  Widget build(BuildContext context) {
    final d = news.source.publishedAt.toLocal();
    final hits = findTermHits(news.body, news.terms);

    return Scaffold(
      backgroundColor: AppColors.paper,

      appBar: AppBar(
        title: Text(
          '${news.stockName} · ${news.readMinutes}분',
          style: TextStyle(fontSize: 16),
        ),
        backgroundColor: AppColors.paper,
        foregroundColor: AppColors.ink,
        elevation: 0,
        actions: [
          // 기사집에 담기
          ListenableBuilder(
            listenable: savedStore,
            builder: (context, _) => SaveButton(
              saved: savedStore.isNewsSaved(news),
              onPressed: () => savedStore.toggleNews(news),
              kind: '기사',
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              news.title,
              style: TextStyle(
                fontFamily: AppFonts.serif,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 24),

            for (var i = 0; i < news.body.length; i++)
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: TermParagraph(
                  text: news.body[i],
                  hits: hits[i],
                  style: const TextStyle(fontSize: 16, height: 1.7),
                ),
              ),

            const SizedBox(height: 24),

            if (news.terms.isNotEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  vertical: 28,
                  horizontal: 24,
                ),
                decoration: BoxDecoration(
                  // 흰색 50%를 배경(paper)에 섞은 색: 배경보다 살짝만 밝게.
                  // 반투명으로 칠하면 아래 그림자가 비쳐서 미리 섞은 불투명 색을 씀
                  color: Color.alphaBlend(
                    Colors.white.withValues(alpha: 0.5),
                    AppColors.paper,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  // 테두리 대신 옅은 그림자로 배경과의 경계를 흐리게
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.ink.withValues(alpha: 0.06),
                      blurRadius: 24,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),

                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '오늘 나온 용어',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 12),

                    for (final (i, term) in news.terms.indexed)
                      Padding(
                        // 마지막 용어 아래에는 간격을 두지 않음
                        padding: EdgeInsets.only(
                          bottom: i == news.terms.length - 1 ? 0 : 16,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              term.word,
                              style: const TextStyle(
                                color: AppColors.ink,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              term.meaning,
                              style: const TextStyle(
                                color: AppColors.ink,
                                fontSize: 14,
                                height: 1.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),

            const SizedBox(height: 32),

            Text(
              '출처 · ${news.source.press} · ${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}',
              style: TextStyle(fontSize: 14, color: AppColors.muted),
            ),
            const SizedBox(height: 8),
            InkWell(
              onTap: () => launchUrl(Uri.parse(news.source.url)),
              child: const Text(
                '원문 보기 →',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.ink,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),

      // 본문을 읽다가 바로 퀴즈로
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 12),
          child: ElevatedButton.icon(
            onPressed: () => _openQuiz(context),
            icon: const Icon(Icons.quiz_outlined, size: 18),
            label: Text(
              '퀴즈 풀러 가기',
              style: TextStyle(
                fontFamily: AppFonts.sans,
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.ink,
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(vertical: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
