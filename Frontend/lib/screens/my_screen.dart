import 'package:flutter/material.dart';

import '../stores/saved_store.dart';
import '../theme/app_colors.dart';
import '../theme/app_fonts.dart';
import '../widgets/soft_card.dart';
import 'saved_news_screen.dart';
import 'saved_quizzes_screen.dart';
import 'saved_terms_screen.dart';

/// MY 탭: 내가 저장한 기사집 / 용어집 / 퀴즈집으로 들어가는 곳.
class MyScreen extends StatelessWidget {
  const MyScreen({super.key});

  void _open(BuildContext context, Widget screen) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ListenableBuilder(
          listenable: savedStore,
          builder: (context, _) => ListView(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
            children: [
              const Text(
                'MY',
                style: TextStyle(
                  fontFamily: AppFonts.serif,
                  color: AppColors.ink,
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 14),
              Container(height: 1.5, color: AppColors.ink),
              const SizedBox(height: 24),
              const Text(
                '내가 모은 것',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              _CollectionTile(
                icon: Icons.article_outlined,
                title: '기사집',
                count: '${savedStore.savedNews.length}개',
                onTap: () => _open(context, const SavedNewsScreen()),
              ),
              const SizedBox(height: 12),
              _CollectionTile(
                icon: Icons.menu_book_outlined,
                title: '용어집',
                count: '${savedStore.savedTerms.length}개',
                onTap: () => _open(context, const SavedTermsScreen()),
              ),
              const SizedBox(height: 12),
              _CollectionTile(
                icon: Icons.quiz_outlined,
                title: '퀴즈집',
                count: '준비 중',
                onTap: () => _open(context, const SavedQuizzesScreen()),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CollectionTile extends StatelessWidget {
  const _CollectionTile({
    required this.icon,
    required this.title,
    required this.count,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String count;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SoftCard(
      onTap: onTap,
      child: Row(
        children: [
          Icon(icon, color: AppColors.ink),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.ink,
              ),
            ),
          ),
          Text(count, style: const TextStyle(color: AppColors.muted)),
          const Icon(Icons.chevron_right_rounded, color: AppColors.muted),
          const SizedBox(width: 8),
        ],
      ),
    );
  }
}
