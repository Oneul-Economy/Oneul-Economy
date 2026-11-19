import 'package:flutter/foundation.dart';

import '../models/news.dart';

/// 내가 저장한 기사·용어 (기사집 / 용어집).
///
/// 지금은 앱이 켜져 있는 동안만 메모리에 들고 있다. (새로고침하면 사라짐)
/// 나중에 기기 저장소나 서버 DB로 옮길 때는 이 클래스 안쪽만 바꾸면 되고,
/// 화면은 `isXxxSaved` / `toggleXxx` / `savedXxx`만 쓰므로 그대로 둔다.
///
/// 퀴즈 저장은 퀴즈 데이터와 화면이 생기면 같은 방식으로 추가한다.
class SavedStore extends ChangeNotifier {
  // Map은 넣은 순서를 기억하므로, 꺼낼 때 뒤집으면 최근 저장 순이 된다.
  final _news = <String, News>{}; // key: News.id
  final _terms = <String, Term>{}; // key: Term.word

  /// 최근에 저장한 것부터.
  List<News> get savedNews => _news.values.toList().reversed.toList();
  List<Term> get savedTerms => _terms.values.toList().reversed.toList();

  bool isNewsSaved(News news) => _news.containsKey(news.id);
  bool isTermSaved(Term term) => _terms.containsKey(term.word);

  void toggleNews(News news) {
    if (_news.remove(news.id) == null) _news[news.id] = news;
    notifyListeners();
  }

  void toggleTerm(Term term) {
    if (_terms.remove(term.word) == null) _terms[term.word] = term;
    notifyListeners();
  }

  /// 테스트에서 매번 빈 상태로 시작하려고 쓴다.
  @visibleForTesting
  void clear() {
    _news.clear();
    _terms.clear();
    notifyListeners();
  }
}

/// 앱 전체에서 함께 쓰는 저장소 하나.
final savedStore = SavedStore();
