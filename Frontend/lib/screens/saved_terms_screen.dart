import 'package:flutter/material.dart';

import '../stores/saved_store.dart';
import '../theme/app_colors.dart';
import '../theme/app_fonts.dart';
import '../widgets/empty_message.dart';
import '../widgets/save_button.dart';
import '../widgets/soft_card.dart';

/// 용어집: 저장한 용어와 쉬운 설명. 북마크를 누르면 저장 취소.
class SavedTermsScreen extends StatelessWidget {
  const SavedTermsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('용어집')),
      body: ListenableBuilder(
        listenable: savedStore,
        builder: (context, _) {
          final items = savedStore.savedTerms;
          if (items.isEmpty) {
            return const EmptyMessage(
              icon: Icons.menu_book_outlined,
              message: '저장한 용어가 없어요.\n본문에서 밑줄 친 용어를 누르고 북마크를 눌러 담아 보세요.',
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(24),
            itemCount: items.length,
            separatorBuilder: (_, _) => const SizedBox(height: 12),
            itemBuilder: (context, i) {
              final term = items[i];
              return SoftCard(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              term.word,
                              style: const TextStyle(
                                fontFamily: AppFonts.serif,
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                                color: AppColors.ink,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              term.meaning,
                              style: const TextStyle(
                                fontSize: 14,
                                height: 1.6,
                                color: AppColors.ink,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SaveButton(
                      saved: true,
                      onPressed: () => savedStore.toggleTerm(term),
                      kind: '용어',
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
