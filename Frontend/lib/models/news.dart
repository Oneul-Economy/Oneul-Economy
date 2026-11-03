/// AI 첨삭이 끝난 뉴스 1건 (#3 `News` 형식).
///
/// JSON 키는 snake_case(`stock_name`), Dart 필드는 camelCase(`stockName`).
class News {
  final String id;
  final String stockName;
  final String title;
  final String summary;
  final int readMinutes;
  final List<String> body;
  final List<Term> terms;
  final NewsSource source;

  const News({
    required this.id,
    required this.stockName,
    required this.title,
    required this.summary,
    required this.readMinutes,
    required this.body,
    required this.terms,
    required this.source,
  });

  factory News.fromJson(Map<String, dynamic> json) => News(
        id: json['id'] as String,
        stockName: json['stock_name'] as String,
        title: json['title'] as String,
        summary: json['summary'] as String,
        readMinutes: json['read_minutes'] as int,
        body: List<String>.from(json['body'] as List),
        terms: (json['terms'] as List)
            .map((e) => Term.fromJson(e as Map<String, dynamic>))
            .toList(),
        source: NewsSource.fromJson(json['source'] as Map<String, dynamic>),
      );
}

/// 본문 아래 용어 박스에 들어갈 어려운 용어와 쉬운 설명.
class Term {
  final String word;
  final String meaning;

  const Term({required this.word, required this.meaning});

  factory Term.fromJson(Map<String, dynamic> json) => Term(
        word: json['word'] as String,
        meaning: json['meaning'] as String,
      );
}

/// 원문 기사 정보 (본문 맨 아래 출처).
class NewsSource {
  final String press;
  final String url;
  final DateTime publishedAt;

  const NewsSource({
    required this.press,
    required this.url,
    required this.publishedAt,
  });

  factory NewsSource.fromJson(Map<String, dynamic> json) => NewsSource(
        press: json['press'] as String,
        url: json['url'] as String,
        publishedAt: DateTime.parse(json['published_at'] as String),
      );
}
