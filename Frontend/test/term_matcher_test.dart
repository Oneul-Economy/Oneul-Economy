import 'package:flutter_test/flutter_test.dart';
import 'package:oneul_economy/models/news.dart';
import 'package:oneul_economy/utils/term_matcher.dart';

void main() {
  const union = Term(word: '노동조합', meaning: '노동자들이 모인 단체');
  const solo = Term(word: '단독교섭', meaning: '혼자 따로 하는 협상');
  const talk = Term(word: '교섭', meaning: '서로 조건을 맞추는 협상');

  test('용어가 두 문단에 나오면 첫 문단에만 결과가 있다', () {
    final hits = findTermHits(
      ['노동조합이 파업했다.', '노동조합은 내일 다시 모인다.'],
      [union],
    );

    expect(hits[0], hasLength(1));
    expect(hits[1], isEmpty);
  });

  test('"단독교섭"과 "교섭"이 둘 다 용어일 때 겹치지 않는다', () {
    final hits = findTermHits(
      ['회사는 단독교섭을 원했고, 노조는 공동 교섭을 원했다.'],
      [talk, solo], // 짧은 용어가 앞에 있어도 긴 용어부터 처리해야 함
    );

    final p = hits[0];
    expect(p, hasLength(2));
    expect(p[0].term, solo);
    expect(p[1].term, talk);
    expect(p[0].end <= p[1].start, isTrue);
    // "교섭"은 "단독교섭" 안이 아니라 그 뒤 "공동 교섭"에 걸린다
    expect(p[1].start, '회사는 단독교섭을 원했고, 노조는 공동 '.length);
  });

  test('"노동조합(노조)은"에서 "노동조합"의 위치가 정확하다', () {
    const text = '삼성전자 노동조합(노조)은 오늘 파업을 선언했다.';
    final hits = findTermHits([text], [union]);

    final hit = hits[0].single;
    expect(hit.start, 5);
    expect(hit.end, 9);
    expect(text.substring(hit.start, hit.end), '노동조합');
  });

  test('본문에 없는 용어는 결과가 없고 오류도 없다', () {
    final hits = findTermHits(
      ['노동조합이 파업했다.'],
      [union, const Term(word: '배당금', meaning: '회사가 나눠 주는 이익')],
    );

    expect(hits[0].map((h) => h.term), [union]);
  });

  test('용어가 0개면 모든 문단의 결과가 빈 목록이다', () {
    final hits = findTermHits(['첫 문단', '둘째 문단'], []);

    expect(hits, hasLength(2));
    expect(hits.every((h) => h.isEmpty), isTrue);
  });
}
