import 'dart:async';

import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_fonts.dart';
import 'onboarding_auth_screens.dart';

/// 온보딩 06: 포트폴리오 첨부 (STEP 3/3)
class OnboardingPortfolioUploadScreen extends StatelessWidget {
  const OnboardingPortfolioUploadScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.paper,
      appBar: AppBar(
        backgroundColor: AppColors.paper,
        elevation: 0,
        foregroundColor: AppColors.ink,
        actions: [
          TextButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const OnboardingCompleteScreen(),
                ),
              );
            },
            child: Text(
              '건너뛰기',
              style: TextStyle(
                fontFamily: AppFonts.sans,
                color: AppColors.muted,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const OnboardingStepBar(step: 3),
              const SizedBox(height: 20),
              Text(
                'STEP 3 / 3',
                style: TextStyle(
                  fontFamily: AppFonts.sans,
                  color: AppColors.muted,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                '증권 앱 화면을\n캡처해서 올려주세요',
                style: TextStyle(
                  fontFamily: AppFonts.serif,
                  color: AppColors.ink,
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  height: 1.35,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                '보유 종목과 수량을 자동으로 읽어서 등록해요.',
                style: TextStyle(
                  fontFamily: AppFonts.sans,
                  color: AppColors.muted,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 20),
              InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const OnboardingPortfolioScanningScreen(),
                    ),
                  );
                },
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 34),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppColors.ink.withValues(alpha: 0.18),
                    ),
                  ),
                  child: Column(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: AppColors.paper,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.upload_outlined,
                          color: AppColors.ink,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        '캡처 이미지 선택',
                        style: TextStyle(
                          fontFamily: AppFonts.sans,
                          color: AppColors.ink,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '여러 장 올려도 돼요 · JPG, PNG',
                        style: TextStyle(
                          fontFamily: AppFonts.sans,
                          color: AppColors.muted,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '이렇게 캡처해 주세요',
                      style: TextStyle(
                        fontFamily: AppFonts.sans,
                        color: AppColors.ink,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 10),
                    _GuideLine('01', '증권 앱에서 \'잔고\' 또는 \'보유 종목\' 화면 열기'),
                    const SizedBox(height: 6),
                    _GuideLine('02', '종목명 · 수량 · 평균단가가 보이게 캡처'),
                    const SizedBox(height: 6),
                    _GuideLine('03', '위 영역을 눌러 이미지 올리기'),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(Icons.lock_outline, size: 14, color: AppColors.muted),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      '이미지는 인식 후 바로 삭제돼요. 계좌번호는 저장하지 않아요.',
                      style: TextStyle(
                        fontFamily: AppFonts.sans,
                        color: AppColors.muted,
                        fontSize: 11,
                      ),
                    ),
                  ),
                ],
              ),
              const Spacer(),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const OnboardingPortfolioScanningScreen(),
                    ),
                  );
                },
                icon: const Icon(Icons.image_outlined, size: 18),
                label: Text(
                  '이미지 올리기',
                  style: TextStyle(
                    fontFamily: AppFonts.sans,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.ink,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Center(
                child: TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const OnboardingPortfolioResultScreen(),
                      ),
                    );
                  },
                  child: Text(
                    '직접 입력할게요',
                    style: TextStyle(
                      fontFamily: AppFonts.sans,
                      color: AppColors.muted,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
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

class _GuideLine extends StatelessWidget {
  const _GuideLine(this.num, this.text);
  final String num;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          num,
          style: TextStyle(
            fontFamily: AppFonts.sans,
            color: AppColors.gold,
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontFamily: AppFonts.sans,
              color: AppColors.ink,
              fontSize: 12,
            ),
          ),
        ),
      ],
    );
  }
}

/// 온보딩 07: 이미지 인식 중
class OnboardingPortfolioScanningScreen extends StatefulWidget {
  const OnboardingPortfolioScanningScreen({super.key});

  @override
  State<OnboardingPortfolioScanningScreen> createState() =>
      _OnboardingPortfolioScanningScreenState();
}

class _OnboardingPortfolioScanningScreenState
    extends State<OnboardingPortfolioScanningScreen> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer(const Duration(seconds: 2), () {
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const OnboardingPortfolioResultScreen(),
        ),
      );
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
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
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
          child: Column(
            children: [
              const OnboardingStepBar(step: 3),
              const Spacer(),
              Container(
                width: 150,
                height: 190,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 16,
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: List.generate(
                    4,
                    (_) => Container(
                      height: 14,
                      decoration: BoxDecoration(
                        color: AppColors.paper,
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 28),
              Text(
                '캡처 이미지를\n읽고 있어요',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: AppFonts.serif,
                  color: AppColors.ink,
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  height: 1.35,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '종목명과 수량을 찾는 중이에요 · 약 3초',
                style: TextStyle(
                  fontFamily: AppFonts.sans,
                  color: AppColors.muted,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 24),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: const [
                    _ScanStepRow('이미지 올리기', done: true),
                    Divider(height: 20),
                    _ScanStepRow('글자 읽기', done: true),
                    Divider(height: 20),
                    _ScanStepRow('종목 · 수량 맞춰보는 중…', done: false),
                  ],
                ),
              ),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}

class _ScanStepRow extends StatelessWidget {
  const _ScanStepRow(this.label, {required this.done});
  final String label;
  final bool done;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          done ? Icons.check_circle : Icons.radio_button_unchecked,
          size: 18,
          color: done ? AppColors.ink : AppColors.gold,
        ),
        const SizedBox(width: 10),
        Text(
          label,
          style: TextStyle(
            fontFamily: AppFonts.sans,
            color: done ? AppColors.muted : AppColors.ink,
            fontSize: 13,
            fontWeight: done ? FontWeight.w500 : FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

/// 온보딩 08: 인식 결과 확인
class OnboardingPortfolioResultScreen extends StatelessWidget {
  const OnboardingPortfolioResultScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.paper,
      appBar: AppBar(
        backgroundColor: AppColors.paper,
        elevation: 0,
        foregroundColor: AppColors.ink,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const OnboardingStepBar(step: 3),
              const SizedBox(height: 20),
              Text(
                '4개 종목을 찾았어요',
                style: TextStyle(
                  fontFamily: AppFonts.serif,
                  color: AppColors.ink,
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                '틀린 값이 있으면 눌러서 고쳐주세요.',
                style: TextStyle(
                  fontFamily: AppFonts.sans,
                  color: AppColors.muted,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: AppColors.paper,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.image_outlined, size: 18),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '캡처 1장',
                            style: TextStyle(
                              fontFamily: AppFonts.sans,
                              color: AppColors.ink,
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            '11월 24일 15:42 업로드',
                            style: TextStyle(
                              fontFamily: AppFonts.sans,
                              color: AppColors.muted,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        '다시 올리기',
                        style: TextStyle(
                          fontFamily: AppFonts.sans,
                          color: AppColors.muted,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(flex: 3, child: _HeaderText('종목')),
                        Expanded(flex: 2, child: _HeaderText('수량', right: true)),
                        Expanded(flex: 3, child: _HeaderText('평균 단가', right: true)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const _StockRow('삼성전자', '30주', '152,000원'),
                    const _StockRow('SK하이닉스', '12주', '231,000원'),
                    const _StockRow('현대차', '10주', '251,000원'),
                    Container(
                      margin: const EdgeInsets.only(top: 6),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.paper,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const _StockRow(
                        'NAVER',
                        '7주',
                        '198,000원',
                        compact: true,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.info_outline, size: 13, color: AppColors.muted),
                        const SizedBox(width: 4),
                        Text(
                          '수량이 흐릿해요. 한 번 확인해 주세요',
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
              const SizedBox(height: 12),
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
                  '+ 빠진 종목 직접 추가',
                  style: TextStyle(
                    fontFamily: AppFonts.sans,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const Spacer(),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const OnboardingCompleteScreen(),
                    ),
                  );
                },
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
                  '이대로 등록하기',
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
      ),
    );
  }
}

Widget _HeaderText(String text, {bool right = false}) {
  return Text(
    text,
    textAlign: right ? TextAlign.right : TextAlign.left,
    style: TextStyle(
      fontFamily: AppFonts.sans,
      color: AppColors.muted,
      fontSize: 11,
    ),
  );
}

class _StockRow extends StatelessWidget {
  const _StockRow(this.name, this.qty, this.price, {this.compact = false});
  final String name;
  final String qty;
  final String price;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: compact ? 0 : 8),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(
              name,
              style: TextStyle(
                fontFamily: AppFonts.sans,
                color: AppColors.ink,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              qty,
              textAlign: TextAlign.right,
              style: TextStyle(
                fontFamily: AppFonts.sans,
                color: AppColors.ink,
                fontSize: 13,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              price,
              textAlign: TextAlign.right,
              style: TextStyle(
                fontFamily: AppFonts.sans,
                color: AppColors.ink,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 온보딩 09: 완료
class OnboardingCompleteScreen extends StatelessWidget {
  const OnboardingCompleteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.paper,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 48, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: const BoxDecoration(
                    color: AppColors.ink,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.check, color: Colors.white),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                '준비가 끝났어요,\n지민님',
                style: TextStyle(
                  fontFamily: AppFonts.serif,
                  color: AppColors.ink,
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  height: 1.35,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                '내일 아침부터 내 종목 기준으로\n기사를 골라드릴게요.',
                style: TextStyle(
                  fontFamily: AppFonts.sans,
                  color: AppColors.muted,
                  fontSize: 13,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 28),
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: const [
                    _SummaryRow('관심 종목', '삼성전자 외 3개'),
                    Divider(height: 22),
                    _SummaryRow('관심 키워드', '반도체 · 환율 · AI'),
                    Divider(height: 22),
                    _SummaryRow('보유 종목', '4개 · 12,342,500원'),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: AppColors.ink.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(Icons.notifications_none, size: 16, color: AppColors.muted),
                    const SizedBox(width: 8),
                    Text(
                      '매일 아침 7시에 오늘의 브리핑을 보내드릴게요',
                      style: TextStyle(
                        fontFamily: AppFonts.sans,
                        color: AppColors.ink,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              ElevatedButton(
                onPressed: () => Navigator.popUntil(context, (r) => r.isFirst),
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
                  '오늘의 경제 시작하기',
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
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow(this.label, this.value);
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontFamily: AppFonts.sans,
            color: AppColors.muted,
            fontSize: 13,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontFamily: AppFonts.sans,
            color: AppColors.ink,
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}