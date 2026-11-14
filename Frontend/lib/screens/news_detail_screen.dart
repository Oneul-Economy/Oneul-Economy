import 'package:flutter/material.dart';
import '../models/news.dart';

class NewsDetailScreen extends StatelessWidget {

  const NewsDetailScreen({super.key, required this.news});
  final News news; // 팀원의 홈 화면 코드와 충돌하지 않도록 데이터 받는 통로 복구


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('${news.stockName} · ${news.readMinutes}분', style: TextStyle(fontSize: 16)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              news.title,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            for (final paragraph in news.body)
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Text(paragraph, style: const TextStyle(fontSize: 16, height: 1.7)),
            ),
            const SizedBox(height: 24),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 24),
              decoration: BoxDecoration(
                color: const Color(0xFFF6F4EF), 
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '오늘 나온 용어',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  RichText(
                    text: const TextSpan(
                      style: TextStyle(color: Colors.black87, fontSize: 14, height: 1.5),
                      children: [
                        TextSpan(text: 'HBM  ', style: TextStyle(fontWeight: FontWeight.bold)),
                        TextSpan(text: '고대역폭 메모리(High Bandwidth Memory)의 약자로, 여러 개의 D램을 수직으로 연결해 데이터 처리 속도를 혁신적으로 끌어올린 고성능 반도체입니다.'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            const Text(
              '출처 · 오늘의 경제 · 2026-11-05',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            const Text(
              '원문 보기 →',
              style: TextStyle(fontSize: 14, color: Colors.black87, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}