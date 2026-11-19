import 'package:flutter/material.dart';
import 'package:oneul_economy/theme/app_colors.dart';
import 'package:oneul_economy/theme/app_fonts.dart';
import '../models/news.dart';
import '../utils/term_matcher.dart';
import '../widgets/term_paragraph.dart';
import 'package:url_launcher/url_launcher.dart';

class NewsDetailScreen extends StatelessWidget {

  const NewsDetailScreen({super.key, required this.news});
  final News news; // 팀원의 홈 화면 코드와 충돌하지 않도록 데이터 받는 통로 복구


  @override
  Widget build(BuildContext context) {
    final d = news.source.publishedAt.toLocal();
    final hits = findTermHits(news.body, news.terms);

    return Scaffold(
      backgroundColor: AppColors.paper,

      appBar: AppBar(
        title: Text('${news.stockName} · ${news.readMinutes}분', style: TextStyle(fontSize: 16)),
        backgroundColor: AppColors.paper,
        foregroundColor: AppColors.ink,
        elevation: 0,
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
                 fontWeight: FontWeight.bold
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
                padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 24),
                decoration: BoxDecoration(
                  color: const Color(0xFFF6F4EF), 
                  borderRadius: BorderRadius.circular(12),
                ),

                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '오늘 나온 용어',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),

                    const SizedBox(height: 12),
                    
                    for (Term term in news.terms)
                      RichText(
                        text: TextSpan(
                          style: TextStyle(color: AppColors.ink, fontSize: 14, height: 1.5),
                          children: [
                            TextSpan(text: '${term.word} ', 
                            style: TextStyle(fontWeight: FontWeight.bold)
                            ),
                            TextSpan(text: term.meaning),
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
                style: TextStyle(fontSize: 14, color: AppColors.ink, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}