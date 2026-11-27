import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_fonts.dart';
import 'onboarding_portfolio_screens.dart';

/// 포트폴리오 탭
class PortfolioTabScreen extends StatefulWidget {
  const PortfolioTabScreen({super.key});

  @override
  State<PortfolioTabScreen> createState() => _PortfolioTabScreenState();
}

class _PortfolioTabScreenState extends State<PortfolioTabScreen> {
  static const _upRed = Color(0xFFD93025);
  static const _downBlue = Color(0xFF1A73E8);

  bool _byStock = true;

  static const _holdings = [
    _Holding(
      badge: '삼',
      name: '삼성전자',
      code: '005930',
      qty: '30주',
      avgPrice: '152,000원',
      totalValue: '5,190,000원',
      currentPrice: '173,000원',
      changeRate: '+3.10%',
      isUp: true,
      ratio: 0.42,
      color: AppColors.ink,
    ),
    _Holding(
      badge: 'S',
      name: 'SK하이닉스',
      code: '000660',
      qty: '12주',
      avgPrice: '231,000원',
      totalValue: '3,204,000원',
      currentPrice: '267,000원',
      changeRate: '+4.20%',
      isUp: true,
      ratio: 0.26,
      color: Color(0xFF6B655D),
    ),
    _Holding(
      badge: '현',
      name: '현대차',
      code: '005380',
      qty: '10주',
      avgPrice: '251,000원',
      totalValue: '2,468,000원',
      currentPrice: '246,800원',
      changeRate: '-0.40%',
      isUp: false,
      ratio: 0.20,
      color: Color(0xFFA79F93),
    ),
    _Holding(
      badge: 'N',
      name: 'NAVER',
      code: '035420',
      qty: '7주',
      avgPrice: '198,000원',
      totalValue: '1,480,500원',
      currentPrice: '211,500원',
      changeRate: '+0.80%',
      isUp: true,
      ratio: 0.12,
      color: Color(0xFFC5B08B),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.paper,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
          children: [
            Text(
              '포트폴리오',
              style: TextStyle(
                fontFamily: AppFonts.serif,
                color: AppColors.ink,
                fontSize: 22,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 10),
            Divider(color: AppColors.ink.withValues(alpha: 0.15), height: 1),
            const SizedBox(height: 18),

            // 내 투자 요약
            Text(
              '내 투자',
              style: TextStyle(
                fontFamily: AppFonts.sans,
                color: AppColors.muted,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '12,342,500원',
              style: TextStyle(
                fontFamily: AppFonts.sans,
                color: AppColors.ink,
                fontSize: 28,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '▲ 286,400 (+2.37%)',
              style: TextStyle(
                fontFamily: AppFonts.sans,
                color: _upRed,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '11월 24일 15:30 시세 기준 · 마지막 캡처 11월 20일',
              style: TextStyle(
                fontFamily: AppFonts.sans,
                color: AppColors.muted,
                fontSize: 11,
              ),
            ),
            const SizedBox(height: 16),

            // 재첨부 / 종목 수정하기 버튼
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              const OnboardingPortfolioUploadScreen(),
                        ),
                      );
                    },
                    icon: const Icon(Icons.photo_camera_outlined, size: 16),
                    label: Text(
                      '포트폴리오 재첨부',
                      style: TextStyle(
                        fontFamily: AppFonts.sans,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.ink,
                      backgroundColor: Colors.white,
                      side: BorderSide(
                        color: AppColors.ink.withValues(alpha: 0.14),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const PortfolioEditScreen(),
                        ),
                      );
                    },
                    icon: const Icon(Icons.edit_outlined, size: 16),
                    label: Text(
                      '종목 수정하기',
                      style: TextStyle(
                        fontFamily: AppFonts.sans,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.ink,
                      backgroundColor: Colors.white,
                      side: BorderSide(
                        color: AppColors.ink.withValues(alpha: 0.14),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 26),

            // 자산 구성 헤더 + 토글
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '자산 구성',
                  style: TextStyle(
                    fontFamily: AppFonts.serif,
                    color: AppColors.ink,
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppColors.ink.withValues(alpha: 0.1),
                    ),
                  ),
                  child: Row(
                    children: [
                      _SegmentPill(
                        label: '종목별',
                        selected: _byStock,
                        onTap: () => setState(() => _byStock = true),
                      ),
                      _SegmentPill(
                        label: '업종별',
                        selected: !_byStock,
                        onTap: () => setState(() => _byStock = false),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),

            // 도넛 차트 + 범례
            Row(
              children: [
                SizedBox(
                  width: 124,
                  height: 124,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      CustomPaint(
                        size: const Size(124, 124),
                        painter: _DonutChartPainter(_holdings),
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '보유 종목',
                            style: TextStyle(
                              fontFamily: AppFonts.sans,
                              color: AppColors.muted,
                              fontSize: 10,
                            ),
                          ),
                          Text(
                            '4개',
                            style: TextStyle(
                              fontFamily: AppFonts.sans,
                              color: AppColors.ink,
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 22),
                Expanded(
                  child: Column(
                    children: _holdings.map((h) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 5),
                        child: Row(
                          children: [
                            Container(
                              width: 7,
                              height: 7,
                              decoration: BoxDecoration(
                                color: h.color,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                h.name,
                                style: TextStyle(
                                  fontFamily: AppFonts.sans,
                                  color: AppColors.ink,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            Text(
                              '${(h.ratio * 100).round()}%',
                              style: TextStyle(
                                fontFamily: AppFonts.sans,
                                color: AppColors.ink,
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),

            // 인사이트 배너
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.ink.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.lightbulb_outline,
                      size: 16, color: AppColors.muted),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '반도체 두 종목이 자산의 68%예요. 한 업종에 많이 몰려 있어요.',
                      style: TextStyle(
                        fontFamily: AppFonts.sans,
                        color: AppColors.ink,
                        fontSize: 12,
                        height: 1.45,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // 보유 종목 리스트
            Text(
              '보유 종목',
              style: TextStyle(
                fontFamily: AppFonts.serif,
                color: AppColors.ink,
                fontSize: 17,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border:
                    Border.all(color: AppColors.ink.withValues(alpha: 0.06)),
              ),
              child: Column(
                children: List.generate(_holdings.length, (i) {
                  final h = _holdings[i];
                  return Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 18,
                              backgroundColor: AppColors.paper,
                              child: Text(
                                h.badge,
                                style: TextStyle(
                                  fontFamily: AppFonts.serif,
                                  color: AppColors.ink,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    h.name,
                                    style: TextStyle(
                                      fontFamily: AppFonts.sans,
                                      color: AppColors.ink,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '${h.qty} · 평균 ${h.avgPrice}',
                                    style: TextStyle(
                                      fontFamily: AppFonts.sans,
                                      color: AppColors.muted,
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  h.totalValue,
                                  style: TextStyle(
                                    fontFamily: AppFonts.sans,
                                    color: AppColors.ink,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      h.currentPrice,
                                      style: TextStyle(
                                        fontFamily: AppFonts.sans,
                                        color: AppColors.muted,
                                        fontSize: 11,
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      h.changeRate,
                                      style: TextStyle(
                                        fontFamily: AppFonts.sans,
                                        color: h.isUp ? _upRed : _downBlue,
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      if (i != _holdings.length - 1)
                        Divider(
                          height: 1,
                          color: AppColors.ink.withValues(alpha: 0.08),
                        ),
                    ],
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SegmentPill extends StatelessWidget {
  const _SegmentPill({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: selected ? AppColors.paper : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontFamily: AppFonts.sans,
            color: selected ? AppColors.ink : AppColors.muted,
            fontSize: 11,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

class _Holding {
  const _Holding({
    required this.badge,
    required this.name,
    required this.code,
    required this.qty,
    required this.avgPrice,
    required this.totalValue,
    required this.currentPrice,
    required this.changeRate,
    required this.isUp,
    required this.ratio,
    required this.color,
  });

  final String badge;
  final String name;
  final String code;
  final String qty;
  final String avgPrice;
  final String totalValue;
  final String currentPrice;
  final String changeRate;
  final bool isUp;
  final double ratio;
  final Color color;
}

class _DonutChartPainter extends CustomPainter {
  const _DonutChartPainter(this.holdings);
  final List<_Holding> holdings;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 10;
    final rect = Rect.fromCircle(center: center, radius: radius);
    var startAngle = -math.pi / 2;

    for (final h in holdings) {
      final sweep = h.ratio * 2 * math.pi;
      final paint = Paint()
        ..color = h.color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 18;
      canvas.drawArc(rect, startAngle, sweep - 0.04, false, paint);
      startAngle += sweep;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// 포트폴리오 / 종목 수정 화면
class PortfolioEditScreen extends StatefulWidget {
  const PortfolioEditScreen({super.key});

  @override
  State<PortfolioEditScreen> createState() => _PortfolioEditScreenState();
}

class _PortfolioEditScreenState extends State<PortfolioEditScreen> {
  final List<_EditableStock> _stocks = [
    _EditableStock('삼', '삼성전자', '005930', '30', '152,000'),
    _EditableStock('S', 'SK하이닉스', '000660', '12', '231,000'),
    _EditableStock('현', '현대차', '005380', '10', '251,000'),
    _EditableStock('N', 'NAVER', '035420', '7', '198,000'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.paper,
      appBar: AppBar(
        backgroundColor: AppColors.paper,
        elevation: 0,
        foregroundColor: AppColors.ink,
        centerTitle: true,
        title: Text(
          '종목 수정',
          style: TextStyle(
            fontFamily: AppFonts.sans,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              '완료',
              style: TextStyle(
                fontFamily: AppFonts.sans,
                color: AppColors.ink,
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          children: [
            // 상단 안내 배너
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.ink.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(Icons.photo_camera_outlined,
                      size: 18, color: AppColors.muted),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      '11월 20일 캡처로 등록된 값이에요.\n틀린 부분만 고쳐주세요.',
                      style: TextStyle(
                        fontFamily: AppFonts.sans,
                        color: AppColors.ink,
                        fontSize: 11,
                        height: 1.4,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              const OnboardingPortfolioUploadScreen(),
                        ),
                      );
                    },
                    child: Text(
                      '다시 캡처',
                      style: TextStyle(
                        fontFamily: AppFonts.sans,
                        color: AppColors.ink,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // 종목별 수정 카드
            ...List.generate(_stocks.length, (i) {
              final s = _stocks[i];
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: AppColors.ink.withValues(alpha: 0.06),
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 16,
                          backgroundColor: AppColors.paper,
                          child: Text(
                            s.badge,
                            style: TextStyle(
                              fontFamily: AppFonts.serif,
                              color: AppColors.ink,
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                s.name,
                                style: TextStyle(
                                  fontFamily: AppFonts.sans,
                                  color: AppColors.ink,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              Text(
                                s.code,
                                style: TextStyle(
                                  fontFamily: AppFonts.sans,
                                  color: AppColors.muted,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: () => setState(() => _stocks.removeAt(i)),
                          icon: Icon(
                            Icons.delete_outline,
                            size: 18,
                            color: AppColors.muted,
                          ),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(
                          child: _EditField(
                            label: '보유 수량',
                            initialValue: s.qty,
                            suffix: '주',
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _EditField(
                            label: '평균 단가',
                            initialValue: s.avgPrice,
                            suffix: '원',
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }),

            // 종목 직접 추가 버튼
            OutlinedButton(
              onPressed: () {},
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.ink,
                side: BorderSide(color: AppColors.ink.withValues(alpha: 0.2)),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                '+ 종목 직접 추가',
                style: TextStyle(
                  fontFamily: AppFonts.sans,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 18),

            // 저장하기 버튼
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.ink,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                '저장하기',
                style: TextStyle(
                  fontFamily: AppFonts.sans,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EditableStock {
  _EditableStock(this.badge, this.name, this.code, this.qty, this.avgPrice);

  final String badge;
  final String name;
  final String code;
  String qty;
  String avgPrice;
}

class _EditField extends StatelessWidget {
  const _EditField({
    required this.label,
    required this.initialValue,
    required this.suffix,
  });

  final String label;
  final String initialValue;
  final String suffix;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontFamily: AppFonts.sans,
            color: AppColors.muted,
            fontSize: 11,
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          initialValue: initialValue,
          keyboardType: TextInputType.number,
          style: TextStyle(
            fontFamily: AppFonts.sans,
            color: AppColors.ink,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
          decoration: InputDecoration(
            suffixText: suffix,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 10,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(
                color: AppColors.ink.withValues(alpha: 0.14),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppColors.ink, width: 1.4),
            ),
          ),
        ),
      ],
    );
  }
}