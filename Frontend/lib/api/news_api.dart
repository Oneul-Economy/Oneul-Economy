import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/news.dart';
import 'api_config.dart';

class NewsApiException implements Exception {
  const NewsApiException(this.message);
  final String message;

  @override
  String toString() => message;
}

const _timeout = Duration(seconds: 8);

Future<dynamic> _getJson(String path, http.Client? client) async {
  final c = client ?? http.Client();
  try {
    final res = await c.get(Uri.parse('$apiBaseUrl$path')).timeout(_timeout);
    if (res.statusCode != 200) {
      throw NewsApiException('서버 응답 ${res.statusCode} ($path)');
    }
    return jsonDecode(utf8.decode(res.bodyBytes));
  } on NewsApiException {
    rethrow;
  } catch (e) {
    throw NewsApiException('서버에 연결하지 못했어요 ($path): $e');
  } finally {
    if (client == null) c.close();
  }
}

/// 최신 기사 목록 (`GET /news`). 최신순.
Future<List<News>> fetchNewsList({
  int limit = 20,
  int offset = 0,
  http.Client? client,
}) async {
  final json = await _getJson('/news?limit=$limit&offset=$offset', client);
  return (json as List)
      .map((e) => News.fromJson(e as Map<String, dynamic>))
      .toList();
}

/// 기사 하나 (`GET /news/{id}`).
Future<News> fetchNews(String id, {http.Client? client}) async {
  final json = await _getJson('/news/${Uri.encodeComponent(id)}', client);
  return News.fromJson(json as Map<String, dynamic>);
}
