class OxQuizItem {
  const OxQuizItem({
    required this.id,
    required this.question,
    required this.answer,
    required this.hint,
    required this.explanation,
    required this.evidence,
  });

  final String id;
  final String question;
  final bool answer; // true = O, false = X
  final String hint;
  final String explanation;
  final String evidence;

  factory OxQuizItem.fromJson(Map<String, dynamic> json) {
    return OxQuizItem(
      id: json['id'] as String,
      question: json['question'] as String,
      answer: json['answer'] as bool,
      hint: (json['hint'] as String?) ?? '',
      explanation: json['explanation'] as String,
      evidence: (json['evidence'] as String?) ?? '',
    );
  }
}

class OxQuiz {
  const OxQuiz({
    required this.newsId,
    required this.quizzes,
  });

  final String newsId;
  final List<OxQuizItem> quizzes;

  factory OxQuiz.fromJson(Map<String, dynamic> json) {
    final list = (json['quizzes'] as List<dynamic>)
        .map((e) => OxQuizItem.fromJson(e as Map<String, dynamic>))
        .toList();
    return OxQuiz(
      newsId: json['news_id'] as String,
      quizzes: list,
    );
  }
}