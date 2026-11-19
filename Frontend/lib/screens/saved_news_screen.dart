import 'package:flutter/material.dart';

import '../stores/saved_store.dart';
import '../theme/app_colors.dart';
import '../theme/app_fonts.dart';
import '../widgets/empty_message.dart';
import '../widgets/save_button.dart';
import '../widgets/soft_card.dart';
import 'news_detail_screen.dart';

/// 기사집: 저장한 기사 목록. 누르면 본문, 북마크를 누르면 저장 취소.
class SavedNewsScreen extends StatelessWidget {
  const SavedNewsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('기사집')),
      body: ListenableBuilder(
        listenable: savedStore,
        builder: (context, _) {
          final items = savedStore.savedNews;
          if (items.isEmpty) {
            return const EmptyMessage(
              icon: Icons.article_outlined,
              message: '저장한 기사가 없어요.\n기사 본문 오른쪽 위 북마크를 눌러 담아 보세요.',
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(24),
            itemCount: items.length,
            separatorBuilder: (_, _) => const SizedBox(height: 12),
            itemBuilder: (context, i) {
              final news = items[i];
              return SoftCard(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => NewsDetailScreen(news: news),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${news.stockName} · ${news.readMinutes}분',
                            style: const TextStyle(
                              color: AppColors.muted,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            news.title,
                            style: const TextStyle(
                              fontFamily: AppFonts.serif,
                              fontWeight: FontWeight.bold,
                              fontSize: 17,
                              color: AppColors.ink,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SaveButton(
                      saved: true,
                      onPressed: () => savedStore.toggleNews(news),
                      kind: '기사',
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
