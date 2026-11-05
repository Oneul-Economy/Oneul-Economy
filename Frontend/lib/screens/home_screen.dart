import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/news.dart';
import '../theme/app_colors.dart';
import '../theme/app_fonts.dart';
import '../widgets/news_card.dart';
import 'news_detail_screen.dart';

/// 앱에 넣어 둔 샘플 JSON에서 뉴스 1건을 읽는다. (서버 연결 전 임시)
Future<News> loadNews() async {
  final text = await rootBundle.loadString('assets/mock/news.json');
  return News.fromJson(jsonDecode(text) as Map<String, dynamic>);
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // build()마다 다시 읽지 않도록 한 번만 만들어 둔다.
  late final Future<News> _newsFuture = loadNews();

  void _openDetail(News news) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => NewsDetailScreen(news: news)),
    );
  }

  // 퀴즈 화면은 아직 없어서 안내만 띄운다.
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
          padding: const EdgeInsets.fromLTRB(24, 10, 24, 32),
          children: [
            const _HomeHeader(),
            const SizedBox(height: 14),
            Container(height: 1.5, color: AppColors.ink),
            const SizedBox(height: 20),
            FutureBuilder<News>(
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
                final news = snapshot.data!;
                return NewsCard(
                  news: news,
                  onTap: () => _openDetail(news),
                  onQuizTap: _showQuizComingSoon,
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
