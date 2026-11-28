import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../models/holding.dart';
import '../stores/portfolio_store.dart';
import '../theme/app_colors.dart';
import '../theme/app_fonts.dart';
import '../utils/number_format.dart';
import 'onboarding_portfolio_screens.dart';

/// 도넛 차트·범례 색. 종목 수가 더 많으면 처음부터 다시 돈다.
const _chartColors = [
  AppColors.ink,
  Color(0xFF6B655D),
  Color(0xFFA79F93),
  Color(0xFFC5B08B),
  Color(0xFF8EA3CF),
  Color(0xFFD98A7E),
];

String _dateLabel(DateTime d) =>
    '${d.month}월 ${d.day}일 ${d.hour.toString().padLeft(2, '0')}:'
    '${d.minute.toString().padLeft(2, '0')}';

void _openUpload(BuildContext context) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => const OnboardingPortfolioUploadScreen(onboarding: false),
    ),
  );
}

/// 포트폴리오 탭
class PortfolioTabScreen extends StatelessWidget {
  const PortfolioTabScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.paper,
      body: SafeArea(
        child: ListenableBuilder(
          listenable: portfolioStore,
          builder: (context, _) => ListView(
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
              if (portfolioStore.isEmpty)
                const _EmptyPortfolio()
              else
                _PortfolioBody(
                  holdings: portfolioStore.holdings,
                  total: portfolioStore.totalKrw,
                  updatedAt: portfolioStore.updatedAt,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyPortfolio extends StatelessWidget {
  const _EmptyPortfolio();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 32, 20, 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.ink.withValues(alpha: 0.06)),
      ),
      child: Column(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: const BoxDecoration(
              color: AppColors.paper,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.pie_chart_outline, color: AppColors.ink),
          ),
          const SizedBox(height: 14),
          Text(
            '아직 등록한 종목이 없어요',
            style: TextStyle(
              fontFamily: AppFonts.serif,
              color: AppColors.ink,
              fontSize: 17,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '증권 앱 보유 종목 화면을 캡처해서 올리면\n종목과 수량을 자동으로 읽어서 등록해요.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: AppFonts.sans,
              color: AppColors.muted,
              fontSize: 12,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _openUpload(context),
              icon: const Icon(Icons.photo_camera_outlined, size: 18),
              label: Text(
                '포트폴리오 캡처 올리기',
                style: TextStyle(
                  fontFamily: AppFonts.sans,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.ink,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          const SizedBox(height: 4),
          TextButton(
            onPressed: portfolioStore.useSample,
            child: Text(
              'mock 데이터로 계속하기',
              style: TextStyle(
                fontFamily: AppFonts.sans,
                color: AppColors.muted,
                fontSize: 13,
                fontWeight: FontWeight.w600,
                decoration: TextDecoration.underline,
                decorationColor: AppColors.muted,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PortfolioBody extends StatelessWidget {
  const _PortfolioBody({
    required this.holdings,
    required this.total,
    required this.updatedAt,
  });

  final List<Holding> holdings;
  final double? total;
  final DateTime? updatedAt;

  @override
  Widget build(BuildContext context) {
    // 차트는 원화 평가금액을 아는 종목만으로 그림
    final valued = [
      for (final (i, h) in holdings.indexed)
        if (h.currency == 'KRW' && (h.value ?? 0) > 0)
          (holding: h, color: _chartColors[i % _chartColors.length]),
    ];
    final sum = valued.fold<double>(0, (a, e) => a + e.holding.value!);
    final slices = [
      for (final e in valued)
        (
          name: e.holding.stockName,
          ratio: e.holding.value! / sum,
          color: e.color,
        ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
          total == null ? '-' : formatMoney(total!, 'KRW'),
          style: TextStyle(
            fontFamily: AppFonts.sans,
            color: AppColors.ink,
            fontSize: 28,
            fontWeight: FontWeight.w800,
          ),
        ),
        if (updatedAt != null) ...[
          const SizedBox(height: 4),
          Text(
            portfolioStore.isSample
                ? 'mock 데이터로 보는 중 · 재첨부하면 내 종목으로 바뀌어요'
                : '${_dateLabel(updatedAt!)} 등록 · 평가금액은 캡처 기준',
            style: TextStyle(
              fontFamily: AppFonts.sans,
              color: AppColors.muted,
              fontSize: 11,
            ),
          ),
        ],
        const SizedBox(height: 16),

        // 재첨부 / 종목 수정하기 버튼
        Row(
          children: [
            Expanded(
              child: _OutlineAction(
                icon: Icons.photo_camera_outlined,
                label: '포트폴리오 재첨부',
                onPressed: () => _openUpload(context),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _OutlineAction(
                icon: Icons.edit_outlined,
                label: '종목 수정하기',
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const PortfolioEditScreen(),
                  ),
                ),
              ),
            ),
          ],
        ),

        if (slices.isNotEmpty) ...[
          const SizedBox(height: 26),
          Text(
            '자산 구성',
            style: TextStyle(
              fontFamily: AppFonts.serif,
              color: AppColors.ink,
              fontSize: 17,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 18),
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
                      painter: _DonutChartPainter(slices),
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
                          '${holdings.length}개',
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
                  children: slices.map((s) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 5),
                      child: Row(
                        children: [
                          Container(
                            width: 7,
                            height: 7,
                            decoration: BoxDecoration(
                              color: s.color,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              s.name,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontFamily: AppFonts.sans,
                                color: AppColors.ink,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          Text(
                            '${(s.ratio * 100).round()}%',
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
        ],
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
            border: Border.all(color: AppColors.ink.withValues(alpha: 0.06)),
          ),
          child: Column(
            children: [
              for (final (i, h) in holdings.indexed) ...[
                if (i > 0)
                  Divider(
                    height: 1,
                    color: AppColors.ink.withValues(alpha: 0.08),
                  ),
                _HoldingRow(h),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _OutlineAction extends StatelessWidget {
  const _OutlineAction({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 16),
      label: Text(
        label,
        style: TextStyle(
          fontFamily: AppFonts.sans,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.ink,
        backgroundColor: Colors.white,
        side: BorderSide(color: AppColors.ink.withValues(alpha: 0.14)),
        padding: const EdgeInsets.symmetric(vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}

class _HoldingRow extends StatelessWidget {
  const _HoldingRow(this.h);
  final Holding h;

  @override
  Widget build(BuildContext context) {
    final detail = [
      if (h.quantity != null) '${formatNumber(h.quantity!)}주',
      if (h.avgPrice != null) '평균 ${formatMoney(h.avgPrice!, h.currency)}',
    ].join(' · ');
    final value = h.value;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: AppColors.paper,
            child: Text(
              h.stockName.characters.first,
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
                  h.stockName,
                  style: TextStyle(
                    fontFamily: AppFonts.sans,
                    color: AppColors.ink,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (detail.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    detail,
                    style: TextStyle(
                      fontFamily: AppFonts.sans,
                      color: AppColors.muted,
                      fontSize: 11,
                    ),
                  ),
                ],
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                value == null ? '-' : formatMoney(value, h.currency),
                style: TextStyle(
                  fontFamily: AppFonts.sans,
                  color: AppColors.ink,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
              if (h.stockCode != null) ...[
                const SizedBox(height: 2),
                Text(
                  h.stockCode!,
                  style: TextStyle(
                    fontFamily: AppFonts.sans,
                    color: AppColors.muted,
                    fontSize: 11,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _DonutChartPainter extends CustomPainter {
  const _DonutChartPainter(this.slices);
  final List<({String name, double ratio, Color color})> slices;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 10;
    final rect = Rect.fromCircle(center: center, radius: radius);
    var startAngle = -math.pi / 2;
    final gap = slices.length > 1 ? 0.04 : 0.0;

    for (final s in slices) {
      final sweep = s.ratio * 2 * math.pi;
      final paint = Paint()
        ..color = s.color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 18;
      canvas.drawArc(rect, startAngle, math.max(0, sweep - gap), false, paint);
      startAngle += sweep;
    }
  }

  @override
  bool shouldRepaint(covariant _DonutChartPainter oldDelegate) =>
      oldDelegate.slices != slices;
}

/// 포트폴리오 / 종목 수정 화면
class PortfolioEditScreen extends StatefulWidget {
  const PortfolioEditScreen({super.key});

  @override
  State<PortfolioEditScreen> createState() => _PortfolioEditScreenState();
}

class _EditableStock {
  _EditableStock(this.base)
    : name = TextEditingController(text: base?.stockName ?? ''),
      qty = TextEditingController(
        text: base?.quantity == null
            ? ''
            : formatNumber(base!.quantity!, decimals: 6),
      ),
      avgPrice = TextEditingController(
        text: base?.avgPrice == null
            ? ''
            : formatNumber(base!.avgPrice!, decimals: 6),
      );

  final Holding? base;
  final TextEditingController name;
  final TextEditingController qty;
  final TextEditingController avgPrice;

  Holding? toHolding() {
    final n = name.text.trim();
    if (n.isEmpty) return null;
    return Holding.edited(
      base,
      stockName: n,
      quantity: parseNumber(qty.text),
      avgPrice: parseNumber(avgPrice.text),
    );
  }

  void dispose() {
    name.dispose();
    qty.dispose();
    avgPrice.dispose();
  }
}

class _PortfolioEditScreenState extends State<PortfolioEditScreen> {
  late final List<_EditableStock> _stocks = portfolioStore.holdings
      .map(_EditableStock.new)
      .toList();

  @override
  void dispose() {
    for (final s in _stocks) {
      s.dispose();
    }
    super.dispose();
  }

  void _save() {
    portfolioStore.setHoldings(
      _stocks.map((s) => s.toHolding()).whereType<Holding>().toList(),
    );
    Navigator.pop(context);
  }

  void _remove(int i) {
    final removed = _stocks.removeAt(i);
    setState(() {});
    WidgetsBinding.instance.addPostFrameCallback((_) => removed.dispose());
  }

  @override
  Widget build(BuildContext context) {
    final updatedAt = portfolioStore.updatedAt;
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
            onPressed: _save,
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
                  Icon(
                    Icons.photo_camera_outlined,
                    size: 18,
                    color: AppColors.muted,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      updatedAt == null
                          ? '틀린 부분만 고쳐주세요.'
                          : '${updatedAt.month}월 ${updatedAt.day}일에 등록된 값이에요.\n틀린 부분만 고쳐주세요.',
                      style: TextStyle(
                        fontFamily: AppFonts.sans,
                        color: AppColors.ink,
                        fontSize: 11,
                        height: 1.4,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () => _openUpload(context),
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
            for (final (i, s) in _stocks.indexed)
              Container(
                key: ObjectKey(s),
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
                        Expanded(
                          child: TextField(
                            controller: s.name,
                            autofocus: s.base == null,
                            style: TextStyle(
                              fontFamily: AppFonts.sans,
                              color: AppColors.ink,
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                            decoration: InputDecoration(
                              isDense: true,
                              border: InputBorder.none,
                              hintText: '종목명',
                              hintStyle: TextStyle(
                                fontFamily: AppFonts.sans,
                                color: AppColors.muted,
                                fontSize: 14,
                              ),
                              helperText: s.base?.stockCode,
                              helperStyle: TextStyle(
                                fontFamily: AppFonts.sans,
                                color: AppColors.muted,
                                fontSize: 11,
                              ),
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () => _remove(i),
                          tooltip: '삭제',
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
                            controller: s.qty,
                            suffix: '주',
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _EditField(
                            label: '평균 단가',
                            controller: s.avgPrice,
                            suffix: (s.base?.currency ?? 'KRW') == 'KRW'
                                ? '원'
                                : s.base!.currency,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

            // 종목 직접 추가 버튼
            OutlinedButton(
              onPressed: () =>
                  setState(() => _stocks.add(_EditableStock(null))),
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
              onPressed: _save,
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

class _EditField extends StatelessWidget {
  const _EditField({
    required this.label,
    required this.controller,
    required this.suffix,
  });

  final String label;
  final TextEditingController controller;
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
        TextField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          style: TextStyle(
            fontFamily: AppFonts.sans,
            color: AppColors.ink,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
          decoration: InputDecoration(
            suffixText: suffix,
            hintText: '읽지 못함',
            hintStyle: TextStyle(
              fontFamily: AppFonts.sans,
              color: AppColors.muted.withValues(alpha: 0.7),
              fontSize: 13,
            ),
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
