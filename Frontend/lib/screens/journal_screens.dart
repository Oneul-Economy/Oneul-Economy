import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../stores/portfolio_store.dart';
import '../theme/app_colors.dart';
import '../theme/app_fonts.dart';
import 'main_shell.dart';

/// Figma「일지」·「일지 작성」 화면 색. 각진 종이 노트 느낌.
class _JColors {
  _JColors._();

  /// 카드·노트 종이
  static const sheet = Color(0xFFFBF8F1);

  /// 카드 테두리, 버튼 테두리
  static const line = Color(0xFFE4E0D8);

  /// 캘린더 빈 날, 구분선
  static const soft = Color(0xFFEFECE6);

  /// 흐린 글자 (요일, 예시 문장)
  static const faint = Color(0xFFA8A39A);

  /// 칩·버튼 글자
  static const body = Color(0xFF4A4741);

  /// 노트 본문 글자
  static const text = Color(0xFF2A2C31);

  /// 섹션 라벨, 날짜 도장
  static const sepia = Color(0xFF8A7F6E);

  /// 노트 가로줄 / 왼쪽 여백 세로줄
  static const rule = Color(0xFFE9E2D4);
  static const margin = Color(0xFFE7BFB6);

  /// 오늘 시장 칸 배경
  static const snapshot = Color(0xFFECE7DD);
  static const marketUp = Color(0xFFD6453D);

  static const shadow = Color(0x124D4026); // rgba(77,64,38,0.07)
}

/// 내 예측 세 가지.
enum Prediction {
  up('오를 것 같다', '▲', Color(0xFFD98A7E), Color(0xFFA4554A)),
  hold('지켜볼래요', '―', Color(0xFFCDB98C), Color(0xFF8A7F6E)),
  down('내릴 것 같다', '▼', Color(0xFF8EA3CF), Color(0xFF5A6F9C));

  const Prediction(this.label, this.mark, this.color, this.stampText);

  final String label;
  final String mark;

  /// 캘린더 동그라미, 점, 도장 테두리
  final Color color;

  /// 도장 글자 (테두리보다 진하게)
  final Color stampText;
}

class _Entry {
  const _Entry(this.date, this.prediction, this.stock, this.content);

  final DateTime date;
  final Prediction prediction;
  final String stock;
  final String content;
}

// 서버에 일지 저장이 생기기 전까지 쓰는 예시 기록 (2026년 11월).
final _sampleEntries = <_Entry>[
  _Entry(
    DateTime(2026, 11, 23),
    Prediction.up,
    'SK하이닉스',
    'HBM 계약이 내년 물량까지 찼다는 기사를 보고 확신이 생겼다. 다음 실적 발표까진 들고 간다.',
  ),
  _Entry(
    DateTime(2026, 11, 22),
    Prediction.hold,
    '삼성전자',
    '주말 동안 노조 기사가 계속 나온다. 월요일 장을 보고 판단하자.',
  ),
  _Entry(
    DateTime(2026, 11, 20),
    Prediction.down,
    '삼성전자',
    '외국인 매도가 길어지는 느낌. 실적 발표 전까진 조금 더 지켜보자.',
  ),
  _Entry(
    DateTime(2026, 11, 19),
    Prediction.up,
    '현대차',
    '환율이 1,400원을 넘었다. 수출 기업엔 나쁘지 않을지도.',
  ),
  _Entry(
    DateTime(2026, 11, 18),
    Prediction.up,
    '삼성전자',
    '반도체 업황 회복 기사가 많아졌다. 분위기가 바뀌는 중인 것 같다.',
  ),
  _Entry(
    DateTime(2026, 11, 16),
    Prediction.hold,
    'NAVER',
    'AI 서비스 발표가 있었는데 시장 반응은 미지근하다.',
  ),
  _Entry(
    DateTime(2026, 11, 13),
    Prediction.down,
    'SK하이닉스',
    '단기간에 너무 많이 올랐다. 숨 고르기가 올 것 같다.',
  ),
  _Entry(
    DateTime(2026, 11, 12),
    Prediction.up,
    '삼성전자',
    '배당 확대 이야기가 나왔다. 길게 보면 좋은 신호.',
  ),
  _Entry(
    DateTime(2026, 11, 11),
    Prediction.up,
    '삼성전자',
    '파운드리 수주 소식. 기대감이 조금 생긴다.',
  ),
  _Entry(
    DateTime(2026, 11, 9),
    Prediction.hold,
    '현대차',
    '미국 관세 이야기로 오르락내리락. 방향이 안 보인다.',
  ),
  _Entry(
    DateTime(2026, 11, 5),
    Prediction.up,
    'SK하이닉스',
    '엔비디아 실적이 좋았다. 같이 움직일 것 같다.',
  ),
  _Entry(
    DateTime(2026, 11, 4),
    Prediction.down,
    'NAVER',
    '광고 매출이 줄었다는 기사. 당분간은 힘들 듯.',
  ),
  _Entry(
    DateTime(2026, 11, 2),
    Prediction.up,
    '삼성전자',
    '첫 기록. 오늘부터 매일 내 종목을 보며 생각을 남겨 본다.',
  ),
];

const _monthNames = [
  'JANUARY', 'FEBRUARY', 'MARCH', 'APRIL', 'MAY', 'JUNE', //
  'JULY', 'AUGUST', 'SEPTEMBER', 'OCTOBER', 'NOVEMBER', 'DECEMBER',
];
const _weekdaysKo = ['월요일', '화요일', '수요일', '목요일', '금요일', '토요일', '일요일'];
const _weekdaysEn = ['MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT', 'SUN'];

/// 캘린더 날짜 동그라미 크기
const _cell = 32.0;

DateTime _dayOf(DateTime d) => DateTime(d.year, d.month, d.day);

bool _sameDay(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;

/// "NOV 24 2026"
String _stampDate(DateTime d) =>
    '${_monthNames[d.month - 1].substring(0, 3)} ${d.day} ${d.year}';

TextStyle _mono({
  required double size,
  required Color color,
  bool bold = false,
  double? spacing,
  double? height,
}) {
  return TextStyle(
    fontFamily: AppFonts.mono,
    fontFamilyFallback: AppFonts.monoFallback,
    fontSize: size,
    color: color,
    fontWeight: bold ? FontWeight.w700 : FontWeight.w400,
    letterSpacing: spacing,
    height: height,
  );
}

TextStyle _sans({
  required double size,
  required Color color,
  FontWeight weight = FontWeight.w400,
  double? spacing,
}) {
  return TextStyle(
    fontFamily: AppFonts.sans,
    fontSize: size,
    color: color,
    fontWeight: weight,
    letterSpacing: spacing,
  );
}

/// 일지 탭
class JournalTabScreen extends StatefulWidget {
  const JournalTabScreen({super.key});

  @override
  State<JournalTabScreen> createState() => _JournalTabScreenState();
}

class _JournalTabScreenState extends State<JournalTabScreen> {
  final _today = _dayOf(DateTime.now());
  late DateTime _selected = _today;

  /// 일지 탭에 미리 보여 줄 지난 기록 수. 나머지는 '전체 보기'에서.
  static const _previewCount = 3;

  DateTime get _month => DateTime(_selected.year, _selected.month);

  void _moveMonth(int delta) {
    final m = DateTime(_month.year, _month.month + delta);
    setState(() {
      _selected = (m.year == _today.year && m.month == _today.month)
          ? _today
          : m;
    });
  }

  void _openWrite() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const JournalWriteScreen()),
    );
  }

  /// 기록이 있는 날을 누르면 그날 일지로, 없는 날은 위쪽 날짜만 바꾼다.
  void _onDayTap(DateTime day) {
    for (final e in _sampleEntries) {
      if (_sameDay(e.date, day)) {
        _openJournalEntry(context, e);
        return;
      }
    }
    setState(() => _selected = day);
  }

  @override
  Widget build(BuildContext context) {
    final recent = _sampleEntries.take(_previewCount).toList();

    return Scaffold(
      backgroundColor: AppColors.paper,
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            // 헤더
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
              child: Column(
                children: [
                  Row(
                    children: [
                      Text(
                        '일지',
                        style: TextStyle(
                          fontFamily: AppFonts.serif,
                          color: AppColors.ink,
                          fontSize: 26,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        onPressed: () {},
                        tooltip: '알림',
                        icon: const Icon(
                          Icons.notifications_none,
                          size: 26,
                          color: AppColors.ink,
                        ),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Container(height: 1.5, color: AppColors.ink),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(24, 18, 24, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // 나의 일지 + 기록하기 + 달 이동
                  Row(
                    children: [
                      Text(
                        '나의 일지',
                        style: TextStyle(
                          fontFamily: AppFonts.serif,
                          color: AppColors.ink,
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const Spacer(),
                      _SharpButton(
                        label: '기록하기',
                        onPressed: _openWrite,
                        fontSize: 13,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                      const SizedBox(width: 12),
                      _ChevronBox(
                        icon: Icons.chevron_left,
                        tooltip: '이전 달',
                        onTap: () => _moveMonth(-1),
                      ),
                      const SizedBox(width: 8),
                      _ChevronBox(
                        icon: Icons.chevron_right,
                        tooltip: '다음 달',
                        onTap: () => _moveMonth(1),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  _CalendarCard(
                    month: _month,
                    today: _today,
                    selected: _selected,
                    entries: _sampleEntries,
                    onSelect: _onDayTap,
                  ),
                  const SizedBox(height: 30),

                  // 지난 기록
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
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
                      const Spacer(),
                      Text(
                        '${_sampleEntries.length} ENTRIES',
                        style: _mono(
                          size: 11,
                          color: AppColors.muted,
                          bold: true,
                          spacing: 1.1,
                        ),
                      ),
                    ],
                  ),
                  // 카드 위에 도장이 12px 튀어나와서 간격은 그만큼 작게
                  const SizedBox(height: 2),
                  _EntryList(entries: recent, previewLines: 3),
                  if (_sampleEntries.length > _previewCount) ...[
                    const SizedBox(height: 8),
                    Center(
                      child: _TextLink(
                        label: '전체 보기 ›',
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const JournalArchiveScreen(),
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
              child: Text(
                '투자 권유가 아닌 학습용 정보입니다',
                textAlign: TextAlign.center,
                style: _sans(size: 11, color: _JColors.faint),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 날짜·요일·월 기록 현황이 있는 큰 캘린더 카드.
class _CalendarCard extends StatelessWidget {
  const _CalendarCard({
    required this.month,
    required this.today,
    required this.selected,
    required this.entries,
    required this.onSelect,
  });

  final DateTime month;
  final DateTime today;
  final DateTime selected;
  final List<_Entry> entries;
  final ValueChanged<DateTime> onSelect;

  String _summary(Map<int, _Entry> byDay) {
    if (byDay.isEmpty) return '이 달에는 아직 기록이 없어요';
    final days = byDay.keys.toList()..sort();
    var longest = 1, run = 1;
    for (var i = 1; i < days.length; i++) {
      run = days[i] == days[i - 1] + 1 ? run + 1 : 1;
      longest = math.max(longest, run);
    }
    final counts = <String, int>{};
    for (final e in byDay.values) {
      counts[e.stock] = (counts[e.stock] ?? 0) + 1;
    }
    final top = counts.entries.reduce((a, b) => b.value > a.value ? b : a).key;
    final label = month.year == today.year && month.month == today.month
        ? '이번 달'
        : '${month.month}월';
    return '$label ${byDay.length}번 기록 · 최장 $longest일 연속 · 가장 많이 쓴 종목 $top';
  }

  @override
  Widget build(BuildContext context) {
    final byDay = {
      for (final e in entries)
        if (e.date.year == month.year && e.date.month == month.month)
          e.date.day: e,
    };
    final daysInMonth = DateTime(month.year, month.month + 1, 0).day;
    final lead = DateTime(month.year, month.month).weekday % 7; // 일요일 = 0
    final cells = [
      ...List<int?>.filled(lead, null),
      for (var d = 1; d <= daysInMonth; d++) d,
    ];
    while (cells.length % 7 != 0) {
      cells.add(null);
    }

    return Container(
      padding: const EdgeInsets.fromLTRB(18, 20, 18, 18),
      decoration: BoxDecoration(
        color: _JColors.sheet,
        borderRadius: BorderRadius.circular(2),
        border: Border.all(color: _JColors.line),
        boxShadow: const [
          BoxShadow(
            color: _JColors.shadow,
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${selected.day}',
                style: TextStyle(
                  fontFamily: AppFonts.serif,
                  color: AppColors.ink,
                  fontSize: 56,
                  fontWeight: FontWeight.w700,
                  height: 1,
                ),
              ),
              const SizedBox(width: 12),
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _monthNames[selected.month - 1],
                      style: _mono(
                        size: 12,
                        color: AppColors.ink,
                        bold: true,
                        spacing: 1.56,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${selected.year}',
                      style: _mono(
                        size: 12,
                        color: AppColors.muted,
                        bold: true,
                        spacing: 1.56,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  _weekdaysKo[selected.weekday - 1],
                  style: TextStyle(
                    fontFamily: AppFonts.serif,
                    color: _JColors.sepia,
                    fontSize: 19,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(_summary(byDay), style: _sans(size: 11, color: AppColors.muted)),
          const SizedBox(height: 20),
          Container(height: 1, color: _JColors.soft),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              for (final d in const ['일', '월', '화', '수', '목', '금', '토'])
                SizedBox(
                  width: _cell,
                  child: Text(
                    d,
                    textAlign: TextAlign.center,
                    style: _sans(
                      size: 10,
                      color: _JColors.faint,
                      weight: FontWeight.w500,
                      spacing: 0.6,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),
          for (var w = 0; w < cells.length; w += 7) ...[
            if (w > 0) const SizedBox(height: 7),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                for (final day in cells.sublist(w, w + 7))
                  if (day == null)
                    const SizedBox(width: _cell, height: _cell)
                  else
                    _DayCell(
                      date: DateTime(month.year, month.month, day),
                      today: today,
                      selected: selected,
                      prediction: byDay[day]?.prediction,
                      onTap: onSelect,
                    ),
              ],
            ),
          ],
          const SizedBox(height: 20),
          Container(height: 1, color: _JColors.soft),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              for (final p in Prediction.values)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _Dot(p.color, size: 8),
                    const SizedBox(width: 6),
                    Text(
                      p.label,
                      style: _sans(size: 11, color: AppColors.muted),
                    ),
                  ],
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DayCell extends StatelessWidget {
  const _DayCell({
    required this.date,
    required this.today,
    required this.selected,
    required this.prediction,
    required this.onTap,
  });

  final DateTime date;
  final DateTime today;
  final DateTime selected;
  final Prediction? prediction;
  final ValueChanged<DateTime> onTap;

  @override
  Widget build(BuildContext context) {
    final isToday = _sameDay(date, today);
    final isFuture = date.isAfter(today);
    final isSelected = _sameDay(date, selected) && !isToday;
    final p = prediction;

    final Color? fill;
    final Color textColor;
    if (p != null) {
      fill = p.color;
      textColor = Colors.white;
    } else if (isToday) {
      fill = null;
      textColor = AppColors.ink;
    } else if (isFuture) {
      fill = null;
      textColor = _JColors.faint;
    } else {
      fill = _JColors.soft;
      textColor = _JColors.faint;
    }

    Widget cell = Container(
      width: _cell,
      height: _cell,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: fill,
        shape: BoxShape.circle,
        border: isSelected
            ? Border.all(color: AppColors.ink, width: 1.5)
            : null,
      ),
      child: Text(
        '${date.day}',
        style: _mono(size: 12, color: textColor, bold: isToday),
      ),
    );
    if (isToday || (isFuture && p == null)) {
      cell = CustomPaint(
        foregroundPainter: _DashedBorderPainter(
          color: isToday ? AppColors.ink : _JColors.line,
          strokeWidth: isToday ? 1.5 : 1.2,
          circle: true,
        ),
        child: cell,
      );
    }
    return InkResponse(onTap: () => onTap(date), radius: 18, child: cell);
  }
}

/// 지난 기록 카드. 오른쪽 위에 살짝 기울어진 날짜 도장이 붙는다.
class _EntryCard extends StatelessWidget {
  const _EntryCard({
    required this.entry,
    required this.tilt,
    this.onTap,
    this.maxLines,
  });

  final _Entry entry;

  /// 도장 기울기 (도)
  final double tilt;

  /// 누르면 일지 상세로. null이면 눌리지 않음.
  final VoidCallback? onTap;

  /// 본문 미리보기 줄 수. null이면 전부.
  final int? maxLines;

  @override
  Widget build(BuildContext context) {
    final p = entry.prediction;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.only(top: 12),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 30, 20, 16),
              decoration: BoxDecoration(
                color: _JColors.sheet,
                borderRadius: BorderRadius.circular(2),
                border: Border.all(color: _JColors.line),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x0F4D4026),
                    blurRadius: 4,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    entry.content,
                    maxLines: maxLines,
                    overflow: maxLines == null ? null : TextOverflow.ellipsis,
                    style: _mono(size: 13, color: _JColors.text, height: 1.75),
                  ),
                  const SizedBox(height: 14),
                  Container(height: 1, color: _JColors.line),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      _Dot(p.color, size: 6),
                      const SizedBox(width: 6),
                      Text(
                        p.label,
                        style: _sans(
                          size: 10,
                          color: AppColors.muted,
                          weight: FontWeight.w700,
                          spacing: 0.8,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text('·', style: _sans(size: 10, color: _JColors.faint)),
                      const SizedBox(width: 6),
                      Text(
                        entry.stock,
                        style: _sans(
                          size: 11,
                          color: _JColors.body,
                          weight: FontWeight.w500,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        '연결 기사 1',
                        style: _sans(size: 10, color: _JColors.faint),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Positioned(
              top: -11,
              right: 50,
              child: Transform.rotate(
                angle: tilt * math.pi / 180,
                child: _DateStamp(
                  text: _stampDate(entry.date),
                  border: p.color,
                  textColor: p.stampText,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

void _openJournalEntry(BuildContext context, _Entry entry) {
  Navigator.push(
    context,
    MaterialPageRoute(builder: (_) => _JournalEntryScreen(entry: entry)),
  );
}

/// 기록 카드 목록. 카드를 누르면 그날 일지로.
class _EntryList extends StatelessWidget {
  const _EntryList({required this.entries, this.previewLines});

  final List<_Entry> entries;
  final int? previewLines;

  @override
  Widget build(BuildContext context) {
    if (entries.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Text(
          '아직 기록이 없어요',
          textAlign: TextAlign.center,
          style: _sans(size: 12, color: _JColors.faint),
        ),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final (i, e) in entries.indexed) ...[
          if (i > 0) const SizedBox(height: 18),
          _EntryCard(
            entry: e,
            tilt: const [2.0, -3.0, 1.0][i % 3],
            maxLines: previewLines,
            onTap: () => _openJournalEntry(context, e),
          ),
        ],
      ],
    );
  }
}

/// 버튼 모양 없이 글자만 있는 링크 ('전체 보기 ›').
class _TextLink extends StatelessWidget {
  const _TextLink({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
        child: Text(
          label,
          style: _sans(
            size: 13,
            color: AppColors.muted,
            weight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

/// 지난 기록 전체 보기. 종목별로 걸러 볼 수 있다.
class JournalArchiveScreen extends StatefulWidget {
  const JournalArchiveScreen({super.key});

  @override
  State<JournalArchiveScreen> createState() => _JournalArchiveScreenState();
}

class _JournalArchiveScreenState extends State<JournalArchiveScreen> {
  String _filter = '전체';

  @override
  Widget build(BuildContext context) {
    final stocks = {for (final e in _sampleEntries) e.stock}.toList();
    final filtered = _filter == '전체'
        ? _sampleEntries
        : _sampleEntries.where((e) => e.stock == _filter).toList();

    return Scaffold(
      backgroundColor: AppColors.paper,
      appBar: _journalAppBar(context, '지난 기록', back: true),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
        children: [
          Row(
            children: [
              Text(
                '${filtered.length} ENTRIES',
                style: _mono(
                  size: 11,
                  color: AppColors.muted,
                  bold: true,
                  spacing: 1.1,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                for (final s in ['전체', ...stocks])
                  Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: _SharpChip(
                      label: s,
                      selected: s == _filter,
                      onTap: () => setState(() => _filter = s),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          _EntryList(entries: filtered, previewLines: 3),
        ],
      ),
    );
  }
}

/// 일지 화면들의 위쪽 바 (닫기 X 또는 뒤로 가기).
PreferredSizeWidget _journalAppBar(
  BuildContext context,
  String? title, {
  bool back = false,
}) {
  return AppBar(
    backgroundColor: AppColors.paper,
    surfaceTintColor: Colors.transparent,
    elevation: 0,
    foregroundColor: AppColors.ink,
    toolbarHeight: 52,
    leading: IconButton(
      icon: Icon(back ? Icons.arrow_back : Icons.close, size: 22),
      tooltip: back ? '뒤로' : '닫기',
      onPressed: () => Navigator.pop(context),
    ),
    centerTitle: true,
    title: title == null
        ? null
        : Text(
            title,
            style: _sans(
              size: 16,
              color: AppColors.ink,
              weight: FontWeight.w700,
            ),
          ),
  );
}

/// 그날 쓴 일지 한 편 보기.
class _JournalEntryScreen extends StatelessWidget {
  const _JournalEntryScreen({required this.entry});

  final _Entry entry;

  @override
  Widget build(BuildContext context) {
    final d = entry.date;
    final p = entry.prediction;
    final textStyle = _mono(size: 14, color: _JColors.text, height: 32 / 14);

    return Scaffold(
      backgroundColor: AppColors.paper,
      appBar: _journalAppBar(context, '일지', back: true),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(24, 14, 24, 32),
        children: [
          // 날짜
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${d.day}',
                style: TextStyle(
                  fontFamily: AppFonts.serif,
                  color: AppColors.ink,
                  fontSize: 56,
                  fontWeight: FontWeight.w700,
                  height: 1,
                ),
              ),
              const SizedBox(width: 12),
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _monthNames[d.month - 1],
                      style: _mono(
                        size: 12,
                        color: AppColors.ink,
                        bold: true,
                        spacing: 1.56,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${d.year}',
                      style: _mono(
                        size: 12,
                        color: AppColors.muted,
                        bold: true,
                        spacing: 1.56,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Text(
                  _weekdaysKo[d.weekday - 1],
                  style: TextStyle(
                    fontFamily: AppFonts.serif,
                    color: _JColors.sepia,
                    fontSize: 19,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(height: 1.5, color: AppColors.ink),
          const SizedBox(height: 20),

          // 노트
          Container(
            padding: const EdgeInsets.fromLTRB(18, 14, 18, 14),
            decoration: BoxDecoration(
              color: _JColors.sheet,
              borderRadius: BorderRadius.circular(2),
              border: Border.all(color: _JColors.line),
              boxShadow: const [
                BoxShadow(
                  color: _JColors.shadow,
                  blurRadius: 5,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: CustomPaint(
              painter: const _RuledPaperPainter(
                lineHeight: 32,
                firstLine: 34,
                marginX: 14,
              ),
              child: ConstrainedBox(
                constraints: const BoxConstraints(minHeight: 32 * 5 + 4),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(26, 4, 4, 2),
                  child: Text(
                    entry.content,
                    style: textStyle,
                    strutStyle: const StrutStyle(
                      fontSize: 14,
                      height: 32 / 14,
                      forceStrutHeight: true,
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 26),

          const _SectionLabel('연결 종목'),
          const SizedBox(height: 10),
          Wrap(
            children: [
              _SharpChip(
                label: '# ${entry.stock}',
                selected: true,
                onTap: () {},
              ),
            ],
          ),
          const SizedBox(height: 22),
          const _SectionLabel('내 예측'),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(2),
              border: Border.all(color: _JColors.line),
            ),
            child: Row(
              children: [
                Text(
                  p.mark,
                  style: _sans(
                    size: 13,
                    color: p.color,
                    weight: FontWeight.w700,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  p.label,
                  style: _sans(
                    size: 13,
                    color: AppColors.ink,
                    weight: FontWeight.w700,
                  ),
                ),
                const Spacer(),
                _DateStamp(
                  text: _stampDate(d),
                  border: p.color,
                  textColor: p.stampText,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DateStamp extends StatelessWidget {
  const _DateStamp({
    required this.text,
    required this.border,
    required this.textColor,
  });

  final String text;
  final Color border;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: _JColors.sheet,
        border: Border.all(color: border),
      ),
      child: Text(
        text,
        style: _mono(size: 10, color: textColor, bold: true, spacing: 0.4),
      ),
    );
  }
}

class _Dot extends StatelessWidget {
  const _Dot(this.color, {required this.size});
  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}

/// 모서리가 거의 없는 검은 버튼 (일지 화면 공통).
class _SharpButton extends StatelessWidget {
  const _SharpButton({
    required this.label,
    required this.onPressed,
    required this.fontSize,
    required this.padding,
  });

  final String label;
  final VoidCallback? onPressed;
  final double fontSize;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.ink,
        foregroundColor: Colors.white,
        disabledBackgroundColor: AppColors.ink.withValues(alpha: 0.3),
        disabledForegroundColor: Colors.white,
        elevation: 0,
        padding: padding,
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(2)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontFamily: AppFonts.sans,
          fontSize: fontSize,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _ChevronBox extends StatelessWidget {
  const _ChevronBox({
    required this.icon,
    required this.tooltip,
    required this.onTap,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(2),
          side: const BorderSide(color: _JColors.line),
        ),
        child: InkWell(
          onTap: onTap,
          child: SizedBox(
            width: 32,
            height: 32,
            child: Icon(icon, size: 18, color: AppColors.ink),
          ),
        ),
      ),
    );
  }
}

/// 각진 선택 칩. 선택되면 검은 바탕.
class _SharpChip extends StatelessWidget {
  const _SharpChip({
    required this.label,
    required this.selected,
    required this.onTap,
    this.padding = const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? AppColors.ink : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(2),
        side: selected
            ? BorderSide.none
            : const BorderSide(color: _JColors.line),
      ),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: padding,
          child: Text(
            label,
            style: _sans(
              size: 12,
              color: selected ? Colors.white : _JColors.body,
              weight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}

/// 점선 테두리 (오늘·앞으로의 날짜 동그라미, '+ 추가' 칩).
class _DashedBorderPainter extends CustomPainter {
  const _DashedBorderPainter({
    required this.color,
    required this.strokeWidth,
    this.circle = false,
  });

  final Color color;
  final double strokeWidth;
  final bool circle;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = (Offset.zero & size).deflate(strokeWidth / 2);
    final path = circle
        ? (Path()..addOval(rect))
        : (Path()..addRRect(
            RRect.fromRectAndRadius(rect, const Radius.circular(2)),
          ));
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;
    const dash = 3.0, gap = 2.5;
    for (final metric in path.computeMetrics()) {
      for (var d = 0.0; d < metric.length; d += dash + gap) {
        canvas.drawPath(metric.extractPath(d, d + dash), paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DashedBorderPainter old) =>
      old.color != color || old.strokeWidth != strokeWidth;
}

/// 노트 가로줄과 왼쪽 여백 세로줄.
class _RuledPaperPainter extends CustomPainter {
  const _RuledPaperPainter({
    required this.lineHeight,
    required this.firstLine,
    required this.marginX,
  });

  final double lineHeight;
  final double firstLine;
  final double marginX;

  @override
  void paint(Canvas canvas, Size size) {
    final rule = Paint()
      ..color = _JColors.rule
      ..strokeWidth = 1;
    for (var y = firstLine; y <= size.height; y += lineHeight) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), rule);
    }
    canvas.drawLine(
      Offset(marginX, 0),
      Offset(marginX, size.height),
      Paint()
        ..color = _JColors.margin
        ..strokeWidth = 1,
    );
  }

  @override
  bool shouldRepaint(covariant _RuledPaperPainter old) => false;
}

/// 지금까지 쓴 일지 수 (홈의 'JOURNAL · N번째 기록').
int get journalEntryCount => _sampleEntries.length;

/// 홈 화면 '오늘의 일지' 노트 카드 (Figma 홈, node 138-294).
/// 어디를 눌러도 일지 쓰기 화면으로 간다.
class JournalPromptCard extends StatelessWidget {
  const JournalPromptCard({super.key});

  static const _tools = ['# 종목 태그', '↗ 예측 남기기', '✦ 브리핑 인용'];

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    void openWrite() => Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const JournalWriteScreen()),
    );

    return GestureDetector(
      onTap: openWrite,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.only(top: 12),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(16, 26, 16, 14),
              decoration: BoxDecoration(
                color: _JColors.sheet,
                borderRadius: BorderRadius.circular(2),
                border: Border.all(color: _JColors.line),
                boxShadow: const [
                  BoxShadow(
                    color: _JColors.shadow,
                    blurRadius: 5,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(
                    height: 78,
                    child: CustomPaint(
                      painter: const _RuledPaperPainter(
                        lineHeight: 26,
                        firstLine: 26,
                        marginX: 14,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(26, 0, 0, 0),
                        child: Text(
                          'SK하이닉스가 4% 올랐다. 실적 때문일까,\n'
                          '아니면 반도체 전체가 좋아지는 걸까?',
                          style: _mono(
                            size: 13,
                            color: _JColors.faint,
                            height: 26 / 13,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      for (final t in _tools)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(2),
                            border: Border.all(color: _JColors.line),
                          ),
                          child: Text(
                            t,
                            style: _sans(
                              size: 12,
                              color: _JColors.body,
                              weight: FontWeight.w500,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Container(height: 1, color: _JColors.line),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          '코스피 +1.1% · 원/달러 1,352',
                          style: _mono(size: 10, color: AppColors.muted),
                        ),
                      ),
                      const SizedBox(width: 8),
                      _SharpButton(
                        label: '기록하기',
                        onPressed: openWrite,
                        fontSize: 12,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Positioned(
              top: -12,
              right: 10,
              child: Transform.rotate(
                angle: 2 * math.pi / 180,
                child: _DateStamp(
                  text: _stampDate(now),
                  border: _JColors.sepia,
                  textColor: _JColors.sepia,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 일지 작성 / 01 작성 중
class JournalWriteScreen extends StatefulWidget {
  const JournalWriteScreen({super.key});

  @override
  State<JournalWriteScreen> createState() => _JournalWriteScreenState();
}

class _JournalWriteScreenState extends State<JournalWriteScreen> {
  static const _maxLength = 500;
  static const _lineHeight = 32.0;
  static const _periods = ['1주', '1개월', '3개월'];
  static const _example =
      '노조 소식에 삼성전자가 장 초반 2% 빠졌다가 오후에 다시 올랐다. '
      '생각보다 시장은 덤덤하다.\n'
      '파업까지 가지 않는다면 실적 발표 전까지는 들고 가도 될 것 같다.';

  final _controller = TextEditingController();
  final _now = DateTime.now();

  /// 포트폴리오에 없는데 '+ 추가'로 넣은 종목
  final _extraStocks = <String>[];
  String? _selectedStock;
  Prediction _prediction = Prediction.up;
  String _period = '1개월';

  List<String> get _stocks => [
    ...portfolioStore.stockNames,
    ..._extraStocks.where((s) => !portfolioStore.stockNames.contains(s)),
  ];

  /// 고른 종목이 목록에서 빠졌으면 첫 종목으로.
  String? get _stock {
    final stocks = _stocks;
    if (_selectedStock != null && stocks.contains(_selectedStock)) {
      return _selectedStock;
    }
    return stocks.isEmpty ? null : stocks.first;
  }

  DateTime get _dueDate => switch (_period) {
    '1주' => _now.add(const Duration(days: 7)),
    '3개월' => DateTime(_now.year, _now.month + 3, _now.day),
    _ => DateTime(_now.year, _now.month + 1, _now.day),
  };

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _addStock() async {
    final name = await showDialog<String>(
      context: context,
      builder: (_) => const _AddStockDialog(),
    );
    if (name == null || name.isEmpty) return;
    setState(() {
      if (!_stocks.contains(name)) _extraStocks.add(name);
      _selectedStock = name;
    });
  }

  void _submit() {
    final due = _dueDate;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => JournalCompleteScreen(
          date: _now,
          content: _controller.text.trim(),
          stock: _stock,
          prediction: _prediction,
          period: _period,
          dueDate: due,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final hh = _now.hour.toString().padLeft(2, '0');
    final mm = _now.minute.toString().padLeft(2, '0');

    return Scaffold(
      backgroundColor: AppColors.paper,
      appBar: AppBar(
        backgroundColor: AppColors.paper,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        foregroundColor: AppColors.ink,
        toolbarHeight: 52,
        leading: IconButton(
          icon: const Icon(Icons.close, size: 22),
          tooltip: '닫기',
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: Text(
          '일지 쓰기',
          style: _sans(size: 16, color: AppColors.ink, weight: FontWeight.w700),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListenableBuilder(
              listenable: portfolioStore,
              builder: (context, _) => ListView(
                padding: const EdgeInsets.fromLTRB(24, 14, 24, 24),
                children: [
                  // 날짜 도장 + 몇 번째 기록
                  Row(
                    children: [
                      _DateStamp(
                        text:
                            '${_stampDate(_now)} · ${_weekdaysEn[_now.weekday - 1]}',
                        border: _JColors.sepia,
                        textColor: _JColors.sepia,
                      ),
                      const Spacer(),
                      Text(
                        '${_sampleEntries.length + 1}번째 기록',
                        style: _sans(size: 12, color: AppColors.muted),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    '오늘 내 종목,\n어떻게 보였나요?',
                    style: TextStyle(
                      fontFamily: AppFonts.serif,
                      color: AppColors.ink,
                      fontSize: 26,
                      fontWeight: FontWeight.w700,
                      height: 1.38,
                    ),
                  ),
                  const SizedBox(height: 20),
                  _notePage(),
                  const SizedBox(height: 26),

                  // 연결 종목
                  const _SectionLabel('연결 종목'),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      for (final s in _stocks)
                        _SharpChip(
                          label: '# $s',
                          selected: s == _stock,
                          onTap: () => setState(() => _selectedStock = s),
                        ),
                      _AddChip(onTap: _addStock),
                    ],
                  ),
                  if (portfolioStore.isEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      '포트폴리오에 종목을 등록하면 내 종목이 여기에 떠요',
                      style: _sans(size: 11, color: _JColors.faint),
                    ),
                  ],
                  const SizedBox(height: 22),

                  // 내 예측
                  _SectionLabel('내 예측', trailing: _stock),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      for (final (i, p) in Prediction.values.indexed) ...[
                        if (i > 0) const SizedBox(width: 6),
                        Expanded(child: _predictionButton(p)),
                      ],
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Text(
                        '언제까지?',
                        style: _sans(size: 12, color: AppColors.muted),
                      ),
                      const SizedBox(width: 10),
                      for (final p in _periods)
                        Padding(
                          padding: const EdgeInsets.only(right: 6),
                          child: _SharpChip(
                            label: p,
                            selected: p == _period,
                            onTap: () => setState(() => _period = p),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    '${_dueDate.month}월 ${_dueDate.day}일에 이 예측이 맞았는지 알려드릴게요',
                    style: _mono(size: 11, color: _JColors.sepia),
                  ),
                  const SizedBox(height: 22),

                  // 오늘 시장
                  _SectionLabel('오늘 시장', trailing: '$hh:$mm 자동 기록'),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: _JColors.snapshot,
                      borderRadius: BorderRadius.circular(2),
                    ),
                    child: const Column(
                      children: [
                        _MarketRow('코스피', '2,612.4  +1.1%', up: true),
                        SizedBox(height: 6),
                        _MarketRow('원/달러', '1,352.0'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 하단 기록하기 버튼
          Container(
            padding: EdgeInsets.fromLTRB(
              24,
              12,
              24,
              18 + MediaQuery.of(context).padding.bottom,
            ),
            decoration: const BoxDecoration(
              color: _JColors.sheet,
              border: Border(top: BorderSide(color: _JColors.line)),
            ),
            child: Align(
              alignment: Alignment.centerRight,
              child: ListenableBuilder(
                listenable: _controller,
                builder: (context, _) => _SharpButton(
                  label: '기록하기',
                  onPressed: _controller.text.trim().isEmpty ? null : _submit,
                  fontSize: 15,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 15,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 줄 노트. 줄은 글이 길어지면 같이 늘어난다.
  Widget _notePage() {
    final textStyle = _mono(
      size: 14,
      color: _JColors.text,
      height: _lineHeight / 14,
    );
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 14, 18, 14),
      decoration: BoxDecoration(
        color: _JColors.sheet,
        borderRadius: BorderRadius.circular(2),
        border: Border.all(color: _JColors.line),
        boxShadow: const [
          BoxShadow(
            color: _JColors.shadow,
            blurRadius: 5,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          CustomPaint(
            painter: const _RuledPaperPainter(
              lineHeight: _lineHeight,
              firstLine: 34,
              marginX: 14,
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(26, 4, 4, 2),
              child: TextField(
                controller: _controller,
                minLines: 7,
                maxLines: null,
                maxLength: _maxLength,
                keyboardType: TextInputType.multiline,
                cursorColor: AppColors.ink,
                cursorWidth: 1.5,
                cursorHeight: 17,
                style: textStyle,
                strutStyle: StrutStyle(
                  fontSize: 14,
                  height: _lineHeight / 14,
                  forceStrutHeight: true,
                ),
                decoration: InputDecoration(
                  isCollapsed: true,
                  border: InputBorder.none,
                  counterText: '',
                  hintText: _example,
                  hintMaxLines: 7,
                  hintStyle: textStyle.copyWith(
                    color: _JColors.faint.withValues(alpha: 0.7),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          ListenableBuilder(
            listenable: _controller,
            builder: (context, _) => Text(
              '${_controller.text.characters.length} / $_maxLength',
              textAlign: TextAlign.right,
              style: _mono(size: 10, color: _JColors.faint),
            ),
          ),
        ],
      ),
    );
  }

  Widget _predictionButton(Prediction p) {
    final selected = p == _prediction;
    return Material(
      color: selected ? AppColors.ink : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(2),
        side: selected
            ? BorderSide.none
            : const BorderSide(color: _JColors.line),
      ),
      child: InkWell(
        onTap: () => setState(() => _prediction = p),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 11),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                p.mark,
                style: _sans(size: 12, color: p.color, weight: FontWeight.w700),
              ),
              const SizedBox(width: 5),
              Flexible(
                child: Text(
                  p.label,
                  overflow: TextOverflow.ellipsis,
                  style: _sans(
                    size: 12,
                    color: selected ? Colors.white : _JColors.body,
                    weight: selected ? FontWeight.w700 : FontWeight.w500,
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

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text, {this.trailing});
  final String text;
  final String? trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          text,
          style: _sans(
            size: 11,
            color: _JColors.sepia,
            weight: FontWeight.w700,
            spacing: 1.1,
          ),
        ),
        const Spacer(),
        if (trailing != null)
          Text(trailing!, style: _sans(size: 11, color: AppColors.muted)),
      ],
    );
  }
}

class _AddChip extends StatelessWidget {
  const _AddChip({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      foregroundPainter: const _DashedBorderPainter(
        color: _JColors.faint,
        strokeWidth: 1,
      ),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(2),
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
            child: Text(
              '+ 추가',
              style: _sans(
                size: 12,
                color: _JColors.body,
                weight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _AddStockDialog extends StatefulWidget {
  const _AddStockDialog();

  @override
  State<_AddStockDialog> createState() => _AddStockDialogState();
}

class _AddStockDialogState extends State<_AddStockDialog> {
  final _c = TextEditingController();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  void _done() => Navigator.pop(context, _c.text.trim());

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: _JColors.sheet,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(2)),
      title: Text(
        '종목 추가',
        style: _sans(size: 16, color: AppColors.ink, weight: FontWeight.w700),
      ),
      content: TextField(
        controller: _c,
        autofocus: true,
        onSubmitted: (_) => _done(),
        style: _sans(size: 14, color: AppColors.ink),
        decoration: InputDecoration(
          hintText: '종목 이름',
          hintStyle: _sans(size: 14, color: _JColors.faint),
          enabledBorder: const UnderlineInputBorder(
            borderSide: BorderSide(color: _JColors.line),
          ),
          focusedBorder: const UnderlineInputBorder(
            borderSide: BorderSide(color: AppColors.ink),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('취소', style: _sans(size: 13, color: AppColors.muted)),
        ),
        TextButton(
          onPressed: _done,
          child: Text(
            '추가',
            style: _sans(
              size: 13,
              color: AppColors.ink,
              weight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}

class _MarketRow extends StatelessWidget {
  const _MarketRow(this.name, this.value, {this.up = false});
  final String name;
  final String value;
  final bool up;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(name, style: _mono(size: 12, color: _JColors.body)),
        const Spacer(),
        Text(
          value,
          style: _mono(
            size: 12,
            color: up ? _JColors.marketUp : _JColors.text,
            bold: true,
          ),
        ),
      ],
    );
  }
}

/// 일지 작성 / 02 기록 완료
class JournalCompleteScreen extends StatelessWidget {
  const JournalCompleteScreen({
    super.key,
    required this.date,
    required this.content,
    required this.stock,
    required this.prediction,
    required this.period,
    required this.dueDate,
  });

  final DateTime date;
  final String content;
  final String? stock;
  final Prediction prediction;
  final String period;
  final DateTime dueDate;

  @override
  Widget build(BuildContext context) {
    final today = _dayOf(date);
    // 이번 주 (일요일 시작)
    final sunday = today.subtract(Duration(days: today.weekday % 7));
    final week = [for (var i = 0; i < 7; i++) sunday.add(Duration(days: i))];
    Prediction? predictionOn(DateTime d) {
      if (_sameDay(d, today)) return prediction;
      for (final e in _sampleEntries) {
        if (_sameDay(e.date, d)) return e.prediction;
      }
      return null;
    }

    var streak = 0;
    for (
      var d = today;
      predictionOn(d) != null;
      d = d.subtract(const Duration(days: 1))
    ) {
      streak++;
    }

    return Scaffold(
      backgroundColor: AppColors.paper,
      appBar: AppBar(
        backgroundColor: AppColors.paper,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        foregroundColor: AppColors.ink,
        toolbarHeight: 52,
        leading: IconButton(
          icon: const Icon(Icons.close, size: 22),
          tooltip: '닫기',
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
          children: [
            Text(
              'JOURNAL · ${_sampleEntries.length + 1}번째 기록',
              textAlign: TextAlign.center,
              style: _mono(
                size: 11,
                color: AppColors.muted,
                bold: true,
                spacing: 1.1,
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
                height: 1.38,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              streak > 1 ? '$streak일 연속 기록 중이에요. 내일도 만나요.' : '내일도 만나요.',
              textAlign: TextAlign.center,
              style: _sans(size: 13, color: AppColors.muted),
            ),
            const SizedBox(height: 28),

            _EntryCard(
              entry: _Entry(date, prediction, stock ?? '종목 없음', content),
              tilt: 2,
            ),
            const SizedBox(height: 14),

            // 알림 안내
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: _JColors.snapshot,
                borderRadius: BorderRadius.circular(2),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.notifications_none,
                    size: 16,
                    color: _JColors.sepia,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '${dueDate.month}월 ${dueDate.day}일, 이 예측이 맞았는지 다시 보여드릴게요 ($period)',
                      style: _mono(size: 11, color: _JColors.body),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 26),

            // 이번 주
            _SectionLabel('이번 주', trailing: streak > 1 ? '$streak일 연속' : null),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                for (final (i, d) in week.indexed)
                  Column(
                    children: [
                      Text(
                        const ['일', '월', '화', '수', '목', '금', '토'][i],
                        style: _sans(
                          size: 10,
                          color: _sameDay(d, today)
                              ? AppColors.ink
                              : _JColors.faint,
                          weight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 6),
                      _DayCell(
                        date: d,
                        today: today,
                        selected: today,
                        prediction: predictionOn(d),
                        onTap: (_) {},
                      ),
                    ],
                  ),
              ],
            ),
            const SizedBox(height: 36),

            _SharpButton(
              label: '일지에서 보기',
              onPressed: () => Navigator.pop(context),
              fontSize: 15,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            const SizedBox(height: 6),
            Center(
              child: TextButton(
                onPressed: () => MainShell.goHome(context),
                child: Text(
                  '홈으로',
                  style: _sans(size: 13, color: AppColors.muted),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
