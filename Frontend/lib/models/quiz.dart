class QuizItem {
  final String id;
  final String word;
  final String question;
  final List<String> choices;
  final int answerIndex;
  final String explanation;

  const QuizItem({
    required this.id,
    required this.word,
    required this.question,
    required this.choices,
    required this.answerIndex,
    required this.explanation,
  });

  factory QuizItem.fromJson(Map<String, dynamic> json) {
    return QuizItem(
      id: json['id'] as String,
      word: json['word'] as String,
      question: json['question'] as String,
      choices: List<String>.from(json['choices'] as List),
      answerIndex: json['answer_index'] as int,
      explanation: json['explanation'] as String,
    );
  }
}

class Quiz {
  final String newsId;
  final List<QuizItem> quizzes;

  const Quiz({
    required this.newsId,
    required this.quizzes,
  });

  factory Quiz.fromJson(Map<String, dynamic> json) {
    return Quiz(
      newsId: json['news_id'] as String,
      quizzes: (json['quizzes'] as List)
          .map((e) => QuizItem.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}