import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_fonts.dart';

/// 일지 탭
class JournalTabScreen extends StatefulWidget {
  const JournalTabScreen({super.key});

  @override
  State<JournalTabScreen> createState() => _JournalTabScreenState();
}

class _JournalTabScreenState extends State<JournalTabScreen> {
  static const _upColor = Color(0xFFD67B71);
  static const _holdColor = Color(0xFFC7B28B);
  static const _downColor = Color(0xFF7B98C4);

  String _selectedStock = '전체';

  static const _stockFilters = ['전체', '삼성전자', 'SK하이닉스', '현대차', 'NAVER'];

  // 11월 캘린더 더미 색상 (1: 오를 것 같다, 2: 지켜볼래요, 3: 내릴 것 같다)
  static const Map<int, int> _dayStatus = {
    2: 1, 4: 3, 5: 3, 6: 2,
    9: 2, 11: 1, 12: 1, 13: 2,
    17: 3, 18: 2, 19: 3, 20: 3,
    22: 2, 23: 1,
  };

  static const _entries = [
    _MockJournalEntry(
      date: 'NOV 23 2026',
      content: 'HBM 계약이 내년 물량까지 찼다는 기사를 보고 확신이 생겼다. 다음 실적 발표까진 들고 간다.',
      sentiment: '오를 것 같다',
      sentimentType: 1,
      stock: 'SK하이닉스',
    ),
    _MockJournalEntry(
      date: 'NOV 20 2026',
      content: '외국인 매도가 길어지는 느낌. 실적 발표 전까진 조금 더 지켜보자.',
      sentiment: '내릴 것 같다',
      sentimentType: 3,
      stock: '삼성전자',
    ),
    _MockJournalEntry(
      date: 'NOV 19 2026',
      content: '환율이 1,480원을 넘었다. 수출 기업엔 나쁘지 않을지도.',
      sentiment: '오를 것 같다',
      sentimentType: 1,
      stock: '현대차',
    ),
  ];

  Color _statusColor(int type) {
    if (type == 1) return _upColor;
    if (type == 2) return _holdColor;
    return _downColor;
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _selectedStock == '전체'
        ? _entries
        : _entries.where((e) => e.stock == _selectedStock).toList();

    return Scaffold(
      backgroundColor: AppColors.paper,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
          children: [
            // 상단 헤더
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '일지',
                  style: TextStyle(
                    fontFamily: AppFonts.serif,
                    color: AppColors.ink,
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.notifications_none, color: AppColors.ink),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Divider(color: AppColors.ink.withValues(alpha: 0.15), height: 1),
            const SizedBox(height: 16),

            // 나의 일지 + 기록하기 버튼
            Row(
              children: [
                Text(
                  '나의 일지',
                  style: TextStyle(
                    fontFamily: AppFonts.serif,
                    color: AppColors.ink,
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const Spacer(),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const JournalWriteScreen(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.ink,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ),
                    minimumSize: Size.zero,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    '기록하기',
                    style: TextStyle(
                      fontFamily: AppFonts.sans,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // 캘린더 카드
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.ink.withValues(alpha: 0.06)),
              ),
              child: Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '24',
                        style: TextStyle(
                          fontFamily: AppFonts.serif,
                          color: AppColors.ink,
                          fontSize: 34,
                          fontWeight: FontWeight.w700,
                          height: 1.0,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'NOVEMBER',
                            style: TextStyle(
                              fontFamily: AppFonts.sans,
                              color: AppColors.muted,
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            '2026',
                            style: TextStyle(
                              fontFamily: AppFonts.sans,
                              color: AppColors.muted,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      Text(
                        '화요일',
                        style: TextStyle(
                          fontFamily: AppFonts.serif,
                          color: AppColors.ink,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      '이번 달 13번 기록 · 최장 3일 연속 · 가장 많이 쓴 종목 삼성전자',
                      style: TextStyle(
                        fontFamily: AppFonts.sans,
                        color: AppColors.muted,
                        fontSize: 11,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // 요일 헤더
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: ['일', '월', '화', '수', '목', '금', '토']
                        .map(
                          (d) => SizedBox(
                            width: 32,
                            child: Text(
                              d,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontFamily: AppFonts.sans,
                                color: AppColors.muted,
                                fontSize: 11,
                              ),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                  const SizedBox(height: 10),

                  // 1~30일 그리드
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: 30,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 7,
                      mainAxisSpacing: 8,
                      crossAxisSpacing: 4,
                    ),
                    itemBuilder: (_, index) {
                      final day = index + 1;
                      final status = _dayStatus[day];
                      final isToday = day == 24;
                      return Center(
                        child: Container(
                          width: 30,
                          height: 30,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: status != null
                                ? _statusColor(status)
                                : (day < 24
                                    ? AppColors.paper
                                    : Colors.transparent),
                            shape: BoxShape.circle,
                            border: isToday
                                ? Border.all(color: AppColors.ink, width: 1.5)
                                : null,
                          ),
                          child: Text(
                            '$day',
                            style: TextStyle(
                              fontFamily: AppFonts.sans,
                              color: status != null
                                  ? Colors.white
                                  : (isToday
                                      ? AppColors.ink
                                      : AppColors.muted),
                              fontSize: 11,
                              fontWeight: isToday || status != null
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 14),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _LegendDot(_upColor, '오를 것 같다'),
                      _LegendDot(_holdColor, '지켜볼래요'),
                      _LegendDot(_downColor, '내릴 것 같다'),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // 지난 기록 헤더
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '지난 기록',
                  style: TextStyle(
                    fontFamily: AppFonts.serif,
                    color: AppColors.ink,
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  '58 ENTRIES',
                  style: TextStyle(
                    fontFamily: AppFonts.sans,
                    color: AppColors.muted,
                    fontSize: 11,
                    letterSpacing: 0.8,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // 종목 필터 칩
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _stockFilters.map((s) {
                  final selected = s == _selectedStock;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: InkWell(
                      onTap: () => setState(() => _selectedStock = s),
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: selected ? AppColors.ink : Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: selected
                                ? AppColors.ink
                                : AppColors.ink.withValues(alpha: 0.12),
                          ),
                        ),
                        child: Text(
                          s,
                          style: TextStyle(
                            fontFamily: AppFonts.sans,
                            color: selected ? Colors.white : AppColors.ink,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 14),

            // 기록 카드 리스트
            ...filtered.map(
              (e) => Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border:
                      Border.all(color: AppColors.ink.withValues(alpha: 0.06)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Align(
                      alignment: Alignment.centerRight,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: _statusColor(e.sentimentType),
                          ),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          e.date,
                          style: TextStyle(
                            fontFamily: AppFonts.sans,
                            color: _statusColor(e.sentimentType),
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      e.content,
                      style: TextStyle(
                        fontFamily: AppFonts.serif,
                        color: AppColors.ink,
                        fontSize: 13,
                        height: 1.55,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: _statusColor(e.sentimentType),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '${e.sentiment} · ${e.stock}',
                          style: TextStyle(
                            fontFamily: AppFonts.sans,
                            color: AppColors.muted,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          '연결 기사 1',
                          style: TextStyle(
                            fontFamily: AppFonts.sans,
                            color: AppColors.muted,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 8),
            Center(
              child: Text(
                '투자 권유가 아닌 학습용 정보입니다',
                style: TextStyle(
                  fontFamily: AppFonts.sans,
                  color: AppColors.muted,
                  fontSize: 11,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  const _LegendDot(this.color, this.label);
  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            fontFamily: AppFonts.sans,
            color: AppColors.muted,
            fontSize: 10,
          ),
        ),
      ],
    );
  }
}

class _MockJournalEntry {
  const _MockJournalEntry({
    required this.date,
    required this.content,
    required this.sentiment,
    required this.sentimentType,
    required this.stock,
  });

  final String date;
  final String content;
  final String sentiment;
  final int sentimentType;
  final String stock;
}

/// 일지 작성 / 01 작성 중
class JournalWriteScreen extends StatefulWidget {
  const JournalWriteScreen({super.key});

  @override
  State<JournalWriteScreen> createState() => _JournalWriteScreenState();
}

class _JournalWriteScreenState extends State<JournalWriteScreen> {
  final _controller = TextEditingController(
    text: '노조 소식에 삼성전자가 장 초반 2% 빠졌다가 오후에 다시 올랐다. 생각보다 시장은 덤덤하다.\n\n파업까지 가지 않는다면 실적 발표 전까지는 들고 가도 될 것 같다.',
  );

  String _selectedStock = '삼성전자';
  String _selectedPrediction = '오를 것 같다';
  String _selectedPeriod = '1개월';

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.paper,
      appBar: AppBar(
        backgroundColor: AppColors.paper,
        elevation: 0,
        foregroundColor: AppColors.ink,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: Text(
          '일지 쓰기',
          style: TextStyle(
            fontFamily: AppFonts.sans,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: AppColors.ink.withValues(alpha: 0.25),
                          ),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'NOV 24 2026 · TUE',
                          style: TextStyle(
                            fontFamily: AppFonts.sans,
                            color: AppColors.muted,
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      Text(
                        '59번째 기록',
                        style: TextStyle(
                          fontFamily: AppFonts.sans,
                          color: AppColors.muted,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '오늘 내 종목,\n어떻게 보였나요?',
                    style: TextStyle(
                      fontFamily: AppFonts.serif,
                      color: AppColors.ink,
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      height: 1.35,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // 노트 입력 영역
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: AppColors.ink.withValues(alpha: 0.08),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        TextField(
                          controller: _controller,
                          maxLines: 6,
                          onChanged: (_) => setState(() {}),
                          style: TextStyle(
                            fontFamily: AppFonts.serif,
                            color: AppColors.ink,
                            fontSize: 14,
                            height: 1.6,
                          ),
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            hintText: '오늘 시장을 보며 든 생각을 적어보세요.',
                          ),
                        ),
                        Text(
                          '${_controller.text.length} / 500',
                          style: TextStyle(
                            fontFamily: AppFonts.sans,
                            color: AppColors.muted,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // 연결 종목
                  _sectionLabel('연결 종목'),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: ['삼성전자', 'SK하이닉스'].map((s) {
                      final selected = s == _selectedStock;
                      return ChoiceChip(
                        label: Text('# $s'),
                        selected: selected,
                        onSelected: (_) => setState(() => _selectedStock = s),
                        selectedColor: AppColors.ink,
                        backgroundColor: Colors.white,
                        showCheckmark: false,
                        labelStyle: TextStyle(
                          fontFamily: AppFonts.sans,
                          color: selected ? Colors.white : AppColors.ink,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 18),

                  // 내 예측
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _sectionLabel('내 예측'),
                      Text(
                        _selectedStock,
                        style: TextStyle(
                          fontFamily: AppFonts.sans,
                          color: AppColors.muted,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _predictButton('▲ 오를 것 같다', '오를 것 같다'),
                      const SizedBox(width: 8),
                      _predictButton('— 지켜볼래요', '지켜볼래요'),
                      const SizedBox(width: 8),
                      _predictButton('▼ 내릴 것 같다', '내릴 것 같다'),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // 언제까지?
                  Row(
                    children: [
                      Text(
                        '언제까지?',
                        style: TextStyle(
                          fontFamily: AppFonts.sans,
                          color: AppColors.muted,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(width: 12),
                      ...['1주', '1개월', '3개월'].map((p) {
                        final selected = p == _selectedPeriod;
                        return Padding(
                          padding: const EdgeInsets.only(right: 6),
                          child: InkWell(
                            onTap: () => setState(() => _selectedPeriod = p),
                            borderRadius: BorderRadius.circular(8),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: selected ? AppColors.ink : Colors.white,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: selected
                                      ? AppColors.ink
                                      : AppColors.ink.withValues(alpha: 0.12),
                                ),
                              ),
                              child: Text(
                                p,
                                style: TextStyle(
                                  fontFamily: AppFonts.sans,
                                  color:
                                      selected ? Colors.white : AppColors.ink,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        );
                      }),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '12월 24일에 이 예측이 맞았는지 알려드릴게요',
                    style: TextStyle(
                      fontFamily: AppFonts.sans,
                      color: AppColors.muted,
                      fontSize: 11,
                    ),
                  ),
                  const SizedBox(height: 18),

                  // 오늘 시장 자동 기록
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _sectionLabel('오늘 시장'),
                      Text(
                        '15:42 자동 기록',
                        style: TextStyle(
                          fontFamily: AppFonts.sans,
                          color: AppColors.muted,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.ink.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Column(
                      children: [
                        _MarketRow('코스피', '2,612.4', '+1.1%', isUp: true),
                        SizedBox(height: 6),
                        _MarketRow('원/달러', '1,352.0', ''),
                        SizedBox(height: 6),
                        _MarketRow('삼성전자', '173,000', '+3.10%', isUp: true),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // 하단 기록하기 버튼
            Container(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
              decoration: BoxDecoration(
                color: AppColors.paper,
                border: Border(
                  top: BorderSide(color: AppColors.ink.withValues(alpha: 0.08)),
                ),
              ),
              child: Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (_) => JournalCompleteScreen(
                          content: _controller.text,
                          stock: _selectedStock,
                          prediction: _selectedPrediction,
                          period: _selectedPeriod,
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.ink,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 13,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(
                    '기록하기',
                    style: TextStyle(
                      fontFamily: AppFonts.sans,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _predictButton(String label, String value) {
    final selected = _selectedPrediction == value;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _selectedPrediction = value),
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected ? AppColors.ink : Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: selected
                  ? AppColors.ink
                  : AppColors.ink.withValues(alpha: 0.12),
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontFamily: AppFonts.sans,
              color: selected ? Colors.white : AppColors.ink,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}

class _MarketRow extends StatelessWidget {
  const _MarketRow(this.name, this.price, this.rate, {this.isUp = false});
  final String name;
  final String price;
  final String rate;
  final bool isUp;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          name,
          style: TextStyle(
            fontFamily: AppFonts.sans,
            color: AppColors.muted,
            fontSize: 12,
          ),
        ),
        const Spacer(),
        Text(
          price,
          style: TextStyle(
            fontFamily: AppFonts.sans,
            color: isUp ? const Color(0xFFD93025) : AppColors.ink,
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
        if (rate.isNotEmpty) ...[
          const SizedBox(width: 6),
          Text(
            rate,
            style: TextStyle(
              fontFamily: AppFonts.sans,
              color: const Color(0xFFD93025),
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ],
    );
  }
}

/// 일지 작성 / 02 기록 완료
class JournalCompleteScreen extends StatelessWidget {
  const JournalCompleteScreen({
    super.key,
    required this.content,
    required this.stock,
    required this.prediction,
    required this.period,
  });

  final String content;
  final String stock;
  final String prediction;
  final String period;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.paper,
      appBar: AppBar(
        backgroundColor: AppColors.paper,
        elevation: 0,
        foregroundColor: AppColors.ink,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'JOURNAL · 59번째 기록',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: AppFonts.sans,
                  color: AppColors.muted,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.8,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                '오늘의 생각을\n남겼어요',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: AppFonts.serif,
                  color: AppColors.ink,
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                  height: 1.35,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '3일 연속 기록 중이에요. 내일도 만나요.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: AppFonts.sans,
                  color: AppColors.muted,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 24),

              // 작성한 일지 카드
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border:
                      Border.all(color: AppColors.ink.withValues(alpha: 0.08)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Align(
                      alignment: Alignment.centerRight,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(color: const Color(0xFFD67B71)),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'NOV 24 2026',
                          style: TextStyle(
                            fontFamily: AppFonts.sans,
                            color: const Color(0xFFD67B71),
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      content,
                      style: TextStyle(
                        fontFamily: AppFonts.serif,
                        color: AppColors.ink,
                        fontSize: 13,
                        height: 1.55,
                      ),
                    ),
                    const Divider(height: 24),
                    Text(
                      '● $prediction · $period · $stock',
                      style: TextStyle(
                        fontFamily: AppFonts.sans,
                        color: AppColors.ink,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // 알림 안내 배너
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: AppColors.ink.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(Icons.notifications_none,
                        size: 16, color: AppColors.muted),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '12월 24일, 이 예측이 맞았는지 다시 보여드릴게요',
                        style: TextStyle(
                          fontFamily: AppFonts.sans,
                          color: AppColors.ink,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // 이번 주 연속 기록
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '이번 주',
                    style: TextStyle(
                      fontFamily: AppFonts.sans,
                      color: AppColors.ink,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    '3일 연속',
                    style: TextStyle(
                      fontFamily: AppFonts.sans,
                      color: AppColors.muted,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  _WeekCircle('일', '22', fill: Color(0xFFC7B28B)),
                  _WeekCircle('월', '23', fill: Color(0xFFD67B71)),
                  _WeekCircle('화', '24', fill: Color(0xFFD67B71), today: true),
                  _WeekCircle('수', '25'),
                  _WeekCircle('목', '26'),
                  _WeekCircle('금', '27'),
                  _WeekCircle('토', '28'),
                ],
              ),
              const Spacer(),

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
                  '일지에서 보기',
                  style: TextStyle(
                    fontFamily: AppFonts.sans,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Center(
                child: TextButton(
                  onPressed: () =>
                      Navigator.popUntil(context, (r) => r.isFirst),
                  child: Text(
                    '홈으로',
                    style: TextStyle(
                      fontFamily: AppFonts.sans,
                      color: AppColors.muted,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _WeekCircle extends StatelessWidget {
  const _WeekCircle(this.dayLabel, this.date, {this.fill, this.today = false});
  final String dayLabel;
  final String date;
  final Color? fill;
  final bool today;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          dayLabel,
          style: TextStyle(
            fontFamily: AppFonts.sans,
            color: today ? AppColors.ink : AppColors.muted,
            fontSize: 11,
            fontWeight: today ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          width: 34,
          height: 34,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: fill ?? Colors.transparent,
            shape: BoxShape.circle,
            border: Border.all(
              color: today
                  ? AppColors.ink
                  : (fill ?? AppColors.ink.withValues(alpha: 0.15)),
              width: today ? 1.8 : 1,
            ),
          ),
          child: Text(
            date,
            style: TextStyle(
              fontFamily: AppFonts.sans,
              color: fill != null ? Colors.white : AppColors.muted,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}

Widget _sectionLabel(String text) {
  return Text(
    text,
    style: TextStyle(
      fontFamily: AppFonts.sans,
      color: AppColors.muted,
      fontSize: 12,
      fontWeight: FontWeight.w600,
    ),
  );
}