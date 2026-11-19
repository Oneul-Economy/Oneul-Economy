import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// 배경(paper)보다 살짝 밝고 그림자로 경계가 흐린 둥근 카드.
/// 본문 '오늘 나온 용어' 칸과 같은 모양이라 저장 목록에서도 같이 쓴다.
class SoftCard extends StatelessWidget {
  const SoftCard({super.key, required this.child, this.onTap});

  final Widget child;
  final VoidCallback? onTap;

  static final color = Color.alphaBlend(
    Colors.white.withValues(alpha: 0.5),
    AppColors.paper,
  );

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.ink.withValues(alpha: 0.06),
            blurRadius: 24,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: color,
        borderRadius: BorderRadius.circular(16),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 8, 16),
            child: child,
          ),
        ),
      ),
    );
  }
}
