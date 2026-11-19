import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../models/news.dart';
import '../stores/saved_store.dart';
import '../theme/app_colors.dart';
import '../theme/app_fonts.dart';
import '../utils/term_matcher.dart';
import 'save_button.dart';

/// 용어에 밑줄을 친 본문 문단. 용어를 누르면 바텀시트로 쉬운 설명을 보여 준다.
///
/// [hits]는 `findTermHits`가 돌려준 이 문단의 결과 (start 순, 서로 겹치지 않음).
class TermParagraph extends StatefulWidget {
  const TermParagraph({
    super.key,
    required this.text,
    required this.hits,
    this.style,
  });

  final String text;
  final List<TermHit> hits;

  /// 문단 기본 글자 스타일. 용어 부분은 여기에 밑줄과 굵기만 더한다.
  final TextStyle? style;

  @override
  State<TermParagraph> createState() => _TermParagraphState();
}

class _TermParagraphState extends State<TermParagraph> {
  // TextSpan.recognizer는 위젯이 대신 정리해 주지 않으므로 직접 dispose 한다.
  List<TapGestureRecognizer> _recognizers = [];

  @override
  void initState() {
    super.initState();
    _buildRecognizers();
  }

  @override
  void didUpdateWidget(TermParagraph oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.text != widget.text ||
        !_sameHits(oldWidget.hits, widget.hits)) {
      _disposeRecognizers();
      _buildRecognizers();
    }
  }

  @override
  void dispose() {
    _disposeRecognizers();
    super.dispose();
  }

  void _buildRecognizers() {
    _recognizers = [
      for (final hit in widget.hits)
        TapGestureRecognizer()..onTap = () => showTermSheet(context, hit.term),
    ];
  }

  void _disposeRecognizers() {
    for (final r in _recognizers) {
      r.dispose();
    }
    _recognizers = [];
  }

  static bool _sameHits(List<TermHit> a, List<TermHit> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i].start != b[i].start ||
          a[i].end != b[i].end ||
          a[i].term.word != b[i].term.word ||
          a[i].term.meaning != b[i].term.meaning) {
        return false;
      }
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    const termStyle = TextStyle(
      fontWeight: FontWeight.w600,
      decoration: TextDecoration.underline,
      decorationColor: AppColors.gold,
      decorationThickness: 2,
    );

    final spans = <TextSpan>[];
    var cursor = 0;
    for (var i = 0; i < widget.hits.length; i++) {
      final hit = widget.hits[i];
      if (hit.start > cursor) {
        spans.add(TextSpan(text: widget.text.substring(cursor, hit.start)));
      }
      spans.add(
        TextSpan(
          text: widget.text.substring(hit.start, hit.end),
          style: termStyle,
          recognizer: _recognizers[i],
        ),
      );
      cursor = hit.end;
    }
    if (cursor < widget.text.length) {
      spans.add(TextSpan(text: widget.text.substring(cursor)));
    }

    return Text.rich(TextSpan(children: spans), style: widget.style);
  }
}

/// 용어와 쉬운 설명을 바텀시트로 띄운다. (Figma '오늘의 용어' 카드 모양)
Future<void> showTermSheet(BuildContext context, Term term) {
  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: AppColors.paper,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (context) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 상단 가운데 작대기: 끌어내려 닫을 수 있다는 표시
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.muted.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 12),
            // 용어 + 우측 저장 아이콘 (용어집에 담기)
            Row(
              children: [
                Expanded(
                  child: Text(
                    term.word,
                    style: const TextStyle(
                      fontFamily: AppFonts.serif,
                      fontWeight: FontWeight.bold,
                      fontSize: 24,
                      color: AppColors.ink,
                    ),
                  ),
                ),
                ListenableBuilder(
                  listenable: savedStore,
                  builder: (context, _) => SaveButton(
                    saved: savedStore.isTermSaved(term),
                    onPressed: () => savedStore.toggleTerm(term),
                    kind: '용어',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              term.meaning,
              style: const TextStyle(
                fontSize: 15,
                height: 1.7,
                color: AppColors.ink,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
