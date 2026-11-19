import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import 'toast.dart';

/// 저장(북마크) 아이콘 버튼. 저장 전에는 빈 아이콘, 저장 후에는 채워진 아이콘.
///
/// 누르면 "[kind]를 스크랩했어요" / "[kind] 스크랩을 취소했어요" 문구가 잠깐 뜬다.
class SaveButton extends StatelessWidget {
  const SaveButton({
    super.key,
    required this.saved,
    required this.onPressed,
    required this.kind,
  });

  final bool saved;
  final VoidCallback onPressed;

  /// 문구에 들어갈 이름. 예: '기사', '용어'
  final String kind;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () {
        onPressed();
        // 누르기 전 saved 값의 반대가 지금 상태
        showToast(
          context,
          saved ? '$kind 스크랩을 취소했어요' : '${_withObject(kind)} 스크랩했어요',
        );
      },
      tooltip: saved ? '스크랩 취소' : '스크랩',
      icon: Icon(
        saved ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
        color: AppColors.ink,
      ),
    );
  }

  /// 받침이 있으면 '을', 없으면 '를'. (기사를 / 용어를 / 퀴즈를)
  static String _withObject(String word) {
    final last = word.codeUnitAt(word.length - 1);
    final isHangul = last >= 0xAC00 && last <= 0xD7A3;
    final hasBatchim = isHangul && (last - 0xAC00) % 28 != 0;
    return '$word${hasBatchim ? '을' : '를'}';
  }
}
