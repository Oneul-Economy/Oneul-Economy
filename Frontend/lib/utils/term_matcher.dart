import '../models/news.dart';

/// 문단 안에서 용어가 나온 자리 [start, end).
class TermHit {
  const TermHit(this.start, this.end, this.term);
  final int start;
  final int end;
  final Term term;
}

/// 문단마다 밑줄 칠 위치 목록. 용어 하나당 기사 전체에서 처음 나온 곳 한 군데만.
///
/// - 긴 용어부터 처리해서, 이미 고른 자리와 겹치는 곳은 건너뛰고 다음에 나오는 곳을 찾는다.
///   (예: "단독교섭"을 먼저 고르면 그 안의 "교섭"에는 밑줄을 치지 않는다)
/// - 본문에 없는 용어는 그냥 건너뛴다.
/// - 결과는 `body`와 길이가 같고, 문단별 목록은 `start` 순으로 정렬된다.
List<List<TermHit>> findTermHits(List<String> body, List<Term> terms) {
  final hits = List.generate(body.length, (_) => <TermHit>[]);

  // 긴 용어부터. sort는 원본을 바꾸므로 복사해서 정렬한다.
  final sorted = [...terms]..sort((a, b) => b.word.length - a.word.length);

  for (final term in sorted) {
    if (term.word.isEmpty) continue; // 빈 용어는 indexOf가 0을 돌려줘서 무한 반복 위험

    final hit = _firstFreeHit(body, hits, term);
    if (hit != null) hits[hit.$1].add(hit.$2);
  }

  for (final list in hits) {
    list.sort((a, b) => a.start - b.start);
  }
  return hits;
}

/// 문단을 앞에서부터 훑어 이미 고른 자리와 겹치지 않는 첫 위치를 찾는다.
(int, TermHit)? _firstFreeHit(
  List<String> body,
  List<List<TermHit>> hits,
  Term term,
) {
  for (var p = 0; p < body.length; p++) {
    var from = 0;
    while (true) {
      final start = body[p].indexOf(term.word, from);
      if (start < 0) break;
      final end = start + term.word.length;
      final overlaps = hits[p].any((h) => start < h.end && h.start < end);
      if (!overlaps) return (p, TermHit(start, end, term));
      from = start + 1;
    }
  }
  return null;
}
