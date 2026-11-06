import 'package:flutter/material.dart';

class NewsDetailScreen extends StatelessWidget {
  final dynamic news; // 팀원의 홈 화면 코드와 충돌하지 않도록 데이터 받는 통로 복구

  const NewsDetailScreen({super.key, required this.news});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('삼성전자 · 3분', style: TextStyle(fontSize: 16)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'HBM이 뭐길래 주가가 오를까',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            const Text(
              'AI 서버에 꼭 필요한 메모리 HBM 주문이 늘면서 삼성전자 실적 기대감이 커졌습니다.\n\n'
              'HBM은 데이터를 한 번에 많이, 그리고 빠르게 처리할 수 있어서 인공지능(AI) 서비스에 필수적인 부품으로 꼽힙니다. 최근 전 세계적으로 AI 열풍이 불면서 HBM을 찾는 기업들이 폭발적으로 증가하고 있습니다.\n\n'
              '특히 삼성전자는 차세대 HBM 개발과 양산에 박차를 가하며 시장의 주목을 받고 있습니다. 전문가들은 이러한 메모리 반도체 수요 증가가 향후 주가에도 긍정적인 영향을 미칠 것으로 전망하고 있습니다.',
              style: TextStyle(fontSize: 16, height: 1.7),
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