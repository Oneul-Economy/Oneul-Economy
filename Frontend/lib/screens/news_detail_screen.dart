import 'package:flutter/material.dart';

import '../models/news.dart';

/// 뉴스 본문 화면. 지금은 빈 화면이고 #5에서 채울 예정.
class NewsDetailScreen extends StatelessWidget {
  const NewsDetailScreen({super.key, required this.news});

  final News news;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(news.stockName)),
      body: Center(child: Text(news.title)),
    );
  }
}
