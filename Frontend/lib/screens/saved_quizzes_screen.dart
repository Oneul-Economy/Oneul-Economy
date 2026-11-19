import 'package:flutter/material.dart';

import '../widgets/empty_message.dart';

/// 퀴즈집: 퀴즈 화면이 아직 없어서 자리만 잡아 둔다.
/// 퀴즈 데이터가 생기면 SavedStore에 퀴즈 저장을 추가하고 기사집처럼 목록을 그린다.
class SavedQuizzesScreen extends StatelessWidget {
  const SavedQuizzesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('퀴즈집')),
      body: const EmptyMessage(
        icon: Icons.quiz_outlined,
        message: '퀴즈는 준비 중이에요.\n퀴즈를 풀고 저장하면 여기에 모여요.',
      ),
    );
  }
}
