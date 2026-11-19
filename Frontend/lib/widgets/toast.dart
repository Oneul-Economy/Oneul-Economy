import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

OverlayEntry? _current;

/// 화면 아래쪽에 잠깐 떴다 사라지는 안내 문구.
///
/// SnackBar는 Scaffold에 붙어서 바텀시트를 띄운 상태면 시트 뒤에 가려진다.
/// 그래서 맨 위 Overlay에 직접 띄워 어느 화면에서든 보이게 한다.
/// 새 문구가 뜨면 이전 문구는 바로 지운다.
void showToast(BuildContext context, String message) {
  _current?.remove();
  _current = null;

  late final OverlayEntry entry;
  entry = OverlayEntry(
    builder: (_) => _Toast(
      message: message,
      onDone: () {
        if (_current == entry) {
          entry.remove();
          _current = null;
        }
      },
    ),
  );
  _current = entry;
  Overlay.of(context, rootOverlay: true).insert(entry);
}

class _Toast extends StatefulWidget {
  const _Toast({required this.message, required this.onDone});

  final String message;
  final VoidCallback onDone;

  @override
  State<_Toast> createState() => _ToastState();
}

class _ToastState extends State<_Toast> with SingleTickerProviderStateMixin {
  // 나타나기(10%) → 머무르기(75%) → 사라지기(15%)를 컨트롤러 하나로.
  late final _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1800),
  );
  late final _opacity = TweenSequence([
    TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.0), weight: 10),
    TweenSequenceItem(tween: ConstantTween(1.0), weight: 75),
    TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.0), weight: 15),
  ]).animate(_controller);

  @override
  void initState() {
    super.initState();
    _controller.forward().whenComplete(() {
      if (mounted) widget.onDone();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 24,
      right: 24,
      bottom: 96 + MediaQuery.paddingOf(context).bottom,
      child: IgnorePointer(
        child: FadeTransition(
          opacity: _opacity,
          child: Center(
            child: Material(
              // 반투명하게 띄워 뒤 내용이 살짝 비치도록
              color: AppColors.ink.withValues(alpha: 0.9),
              borderRadius: BorderRadius.circular(24),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                child: Text(
                  widget.message,
                  style: const TextStyle(
                    color: AppColors.paper,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
