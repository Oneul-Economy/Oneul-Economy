import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_fonts.dart';
import 'onboarding_portfolio_screens.dart';

/// 온보딩 01: 시작 화면
class OnboardingStartScreen extends StatelessWidget {
  const OnboardingStartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.paper,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                '오늘의 경제',
                style: TextStyle(
                  fontFamily: AppFonts.serif,
                  color: AppColors.ink,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                'DAILY ECONOMY NOTE',
                style: TextStyle(
                  fontFamily: AppFonts.sans,
                  color: AppColors.muted,
                  fontSize: 10,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                '내 종목으로 읽는\n하루 3분 경제 공부',
                style: TextStyle(
                  fontFamily: AppFonts.serif,
                  color: AppColors.ink,
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  height: 1.35,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                '보유 종목과 관심 분야에 맞춘 기사 · 용어 · 퀴즈로\n매일 조금씩 경제와 가까워져요.',
                style: TextStyle(
                  fontFamily: AppFonts.sans,
                  color: AppColors.muted,
                  fontSize: 13,
                  height: 1.5,
                ),
              ),
              const Spacer(),
              // 미리보기 카드 2장
              SizedBox(
                height: 210,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Positioned(
                      right: 0,
                      top: 0,
                      child: Transform.rotate(
                        angle: 0.05,
                        child: Container(
                          width: 210,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: AppColors.ink.withValues(alpha: 0.08),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '오늘의 용어',
                                style: TextStyle(
                                  fontFamily: AppFonts.sans,
                                  color: AppColors.muted,
                                  fontSize: 11,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                '임금교섭',
                                style: TextStyle(
                                  fontFamily: AppFonts.serif,
                                  color: AppColors.ink,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '노조와 회사가 임금을 정하는 협상',
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
                    ),
                    Positioned(
                      left: 0,
                      bottom: 8,
                      child: Transform.rotate(
                        angle: -0.04,
                        child: Container(
                          width: 220,
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            color: AppColors.ink,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '삼성전자 · 1분',
                                style: TextStyle(
                                  fontFamily: AppFonts.sans,
                                  color: Colors.white.withValues(alpha: 0.65),
                                  fontSize: 11,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '삼성전자에 노조가\n또 생긴다고요?',
                                style: TextStyle(
                                  fontFamily: AppFonts.serif,
                                  color: Colors.white,
                                  fontSize: 17,
                                  fontWeight: FontWeight.w700,
                                  height: 1.35,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  _DarkTag('노동조합'),
                                  const SizedBox(width: 6),
                                  _DarkTag('임금교섭'),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const EmailLoginScreen()),
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
                  '로그인',
                  style: TextStyle(
                    fontFamily: AppFonts.sans,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              OutlinedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const SignUpScreen()),
                  );
                },
                style: OutlinedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: AppColors.ink,
                  side: BorderSide(color: AppColors.ink.withValues(alpha: 0.15)),
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  '회원 가입',
                  style: TextStyle(
                    fontFamily: AppFonts.sans,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Center(
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    '로그인 없이 이용하기 >',
                    style: TextStyle(
                      fontFamily: AppFonts.sans,
                      color: AppColors.ink,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              Text(
                '비회원은 기사 · 퀴즈만 볼 수 있고, 저장 · 일지는 로그인 후 쓸 수 있어요',
                textAlign: TextAlign.center,
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
    );
  }
}

class _DarkTag extends StatelessWidget {
  const _DarkTag(this.label);
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontFamily: AppFonts.sans,
          color: Colors.white,
          fontSize: 10,
        ),
      ),
    );
  }
}

/// 온보딩 02: 이메일 로그인
class EmailLoginScreen extends StatefulWidget {
  const EmailLoginScreen({super.key});

  @override
  State<EmailLoginScreen> createState() => _EmailLoginScreenState();
}

class _EmailLoginScreenState extends State<EmailLoginScreen> {
  final _emailController = TextEditingController(text: 'jimin@gmail.com');
  final _passwordController = TextEditingController(text: 'password123');
  bool _obscure = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
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
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                '다시 만나서\n반가워요',
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
                '이메일로 로그인해 주세요',
                style: TextStyle(
                  fontFamily: AppFonts.sans,
                  color: AppColors.muted,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 28),
              _FieldLabel('이메일'),
              const SizedBox(height: 6),
              TextField(
                controller: _emailController,
                decoration: _inputDecoration(
                  prefixIcon: Icons.mail_outline,
                  hint: '이메일 입력',
                ),
              ),
              const SizedBox(height: 16),
              _FieldLabel('비밀번호'),
              const SizedBox(height: 6),
              TextField(
                controller: _passwordController,
                obscureText: _obscure,
                decoration: _inputDecoration(
                  prefixIcon: Icons.lock_outline,
                  hint: '비밀번호 입력',
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                      size: 18,
                      color: AppColors.muted,
                    ),
                    onPressed: () => setState(() => _obscure = !_obscure),
                  ),
                ),
              ),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {},
                  child: Text(
                    '비밀번호를 잊으셨나요?',
                    style: TextStyle(
                      fontFamily: AppFonts.sans,
                      color: AppColors.muted,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
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
                  '로그인',
                  style: TextStyle(
                    fontFamily: AppFonts.sans,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '아직 계정이 없나요? ',
                    style: TextStyle(
                      fontFamily: AppFonts.sans,
                      color: AppColors.muted,
                      fontSize: 13,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => const SignUpScreen()),
                      );
                    },
                    child: Text(
                      '회원가입',
                      style: TextStyle(
                        fontFamily: AppFonts.sans,
                        color: AppColors.ink,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 온보딩 03: 회원가입
class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _emailController = TextEditingController(text: 'jimin@gmail.com');
  final _pwController = TextEditingController(text: 'password123');
  final _pwConfirmController = TextEditingController(text: 'password123');
  bool _agreeTerms = true;
  bool _agreePrivacy = true;
  bool _agreeMarketing = false;

  bool get _allAgreed => _agreeTerms && _agreePrivacy && _agreeMarketing;

  void _toggleAll() {
    final next = !_allAgreed;
    setState(() {
      _agreeTerms = next;
      _agreePrivacy = next;
      _agreeMarketing = next;
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _pwController.dispose();
    _pwConfirmController.dispose();
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
        centerTitle: true,
        title: Text(
          '회원가입',
          style: TextStyle(
            fontFamily: AppFonts.sans,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                '계정 만들기',
                style: TextStyle(
                  fontFamily: AppFonts.serif,
                  color: AppColors.ink,
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                '이메일과 비밀번호만 있으면 돼요',
                style: TextStyle(
                  fontFamily: AppFonts.sans,
                  color: AppColors.muted,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 22),
              _FieldLabel('이메일'),
              const SizedBox(height: 6),
              TextField(
                controller: _emailController,
                decoration: _inputDecoration(hint: 'jimin@gmail.com'),
              ),
              const SizedBox(height: 16),
              _FieldLabel('비밀번호'),
              const SizedBox(height: 6),
              TextField(
                controller: _pwController,
                obscureText: true,
                decoration: _inputDecoration(hint: '비밀번호 입력'),
              ),
              const SizedBox(height: 6),
              Text(
                '✓ 8자 이상   ✓ 영문 · 숫자 포함',
                style: TextStyle(
                  fontFamily: AppFonts.sans,
                  color: AppColors.muted,
                  fontSize: 11,
                ),
              ),
              const SizedBox(height: 14),
              _FieldLabel('비밀번호 확인'),
              const SizedBox(height: 6),
              TextField(
                controller: _pwConfirmController,
                obscureText: true,
                decoration: _inputDecoration(hint: '비밀번호 재입력'),
              ),
              const SizedBox(height: 6),
              Text(
                '✓ 비밀번호가 일치해요',
                style: TextStyle(
                  fontFamily: AppFonts.sans,
                  color: AppColors.muted,
                  fontSize: 11,
                ),
              ),
              const SizedBox(height: 20),
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
                  children: [
                    _AgreeRow(
                      label: '전체 동의',
                      checked: _allAgreed,
                      bold: true,
                      onTap: _toggleAll,
                    ),
                    const Divider(height: 20),
                    _AgreeRow(
                      label: '[필수] 이용약관 동의',
                      checked: _agreeTerms,
                      onTap: () => setState(() => _agreeTerms = !_agreeTerms),
                    ),
                    const SizedBox(height: 10),
                    _AgreeRow(
                      label: '[필수] 개인정보 수집 · 이용 동의',
                      checked: _agreePrivacy,
                      onTap: () => setState(() => _agreePrivacy = !_agreePrivacy),
                    ),
                    const SizedBox(height: 10),
                    _AgreeRow(
                      label: '[선택] 아침 브리핑 알림 받기',
                      checked: _agreeMarketing,
                      onTap: () =>
                          setState(() => _agreeMarketing = !_agreeMarketing),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const OnboardingBasicInfoScreen(),
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
                  '가입하고 계속하기',
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

class _AgreeRow extends StatelessWidget {
  const _AgreeRow({
    required this.label,
    required this.checked,
    required this.onTap,
    this.bold = false,
  });

  final String label;
  final bool checked;
  final VoidCallback onTap;
  final bool bold;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Row(
        children: [
          Icon(
            checked ? Icons.check_circle : Icons.radio_button_unchecked,
            size: 20,
            color: checked ? AppColors.ink : AppColors.muted,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontFamily: AppFonts.sans,
                color: AppColors.ink,
                fontSize: 13,
                fontWeight: bold ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 온보딩 04: 기본 정보 (STEP 1/3)
class OnboardingBasicInfoScreen extends StatefulWidget {
  const OnboardingBasicInfoScreen({super.key});

  @override
  State<OnboardingBasicInfoScreen> createState() =>
      _OnboardingBasicInfoScreenState();
}

class _OnboardingBasicInfoScreenState extends State<OnboardingBasicInfoScreen> {
  final _nameController = TextEditingController(text: '김지민');
  final _ageController = TextEditingController(text: '28');
  String _selectedIncome = '3천~5천만원';

  static const _incomes = [
    '3천만원 미만',
    '3천~5천만원',
    '5천~7천만원',
    '7천만~1억원',
    '1억원 이상',
    '밝히지 않을래요',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
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
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const OnboardingStepBar(step: 1),
              const SizedBox(height: 20),
              Text(
                'STEP 1 / 3',
                style: TextStyle(
                  fontFamily: AppFonts.sans,
                  color: AppColors.muted,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                '어떻게 불러드릴까요?',
                style: TextStyle(
                  fontFamily: AppFonts.serif,
                  color: AppColors.ink,
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                '나이와 수입은 눈높이에 맞는 기사를 고르는 데만 사용해요.',
                style: TextStyle(
                  fontFamily: AppFonts.sans,
                  color: AppColors.muted,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 24),
              _FieldLabel('이름'),
              const SizedBox(height: 6),
              TextField(
                controller: _nameController,
                decoration: _inputDecoration(hint: '이름 입력'),
              ),
              const SizedBox(height: 16),
              _FieldLabel('나이'),
              const SizedBox(height: 6),
              TextField(
                controller: _ageController,
                keyboardType: TextInputType.number,
                decoration: _inputDecoration(
                  hint: '나이 입력',
                  suffixText: '세',
                ),
              ),
              const SizedBox(height: 18),
              _FieldLabel('연 수입'),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _incomes.map((income) {
                  final selected = income == _selectedIncome;
                  return ChoiceChip(
                    label: Text(income),
                    selected: selected,
                    onSelected: (_) => setState(() => _selectedIncome = income),
                    selectedColor: AppColors.ink,
                    backgroundColor: Colors.white,
                    labelStyle: TextStyle(
                      fontFamily: AppFonts.sans,
                      color: selected ? Colors.white : AppColors.ink,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: BorderSide(
                        color: selected
                            ? AppColors.ink
                            : AppColors.ink.withValues(alpha: 0.12),
                      ),
                    ),
                    showCheckmark: false,
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Icon(Icons.lock_outline, size: 14, color: AppColors.muted),
                  const SizedBox(width: 6),
                  Text(
                    '입력한 정보는 다른 사람에게 공개되지 않아요',
                    style: TextStyle(
                      fontFamily: AppFonts.sans,
                      color: AppColors.muted,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const OnboardingInterestsScreen(),
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
                  '다음',
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

/// 온보딩 05: 관심 종목 · 키워드 (STEP 2/3)
class OnboardingInterestsScreen extends StatefulWidget {
  const OnboardingInterestsScreen({super.key});

  @override
  State<OnboardingInterestsScreen> createState() =>
      _OnboardingInterestsScreenState();
}

class _OnboardingInterestsScreenState extends State<OnboardingInterestsScreen> {
  final Set<String> _selectedStocks = {'삼성전자', 'SK하이닉스', '현대차', 'NAVER'};
  final Set<String> _selectedKeywords = {'#반도체', '#환율', '#AI'};

  static const _stocks = [
    '삼성전자', 'SK하이닉스', '현대차', 'NAVER', '카카오',
    'LG에너지솔루션', '셀트리온', '엔비디아', '테슬라', '애플',
  ];

  static const _keywords = [
    '#반도체', '#환율', '#AI', '#금리', '#2차전지',
    '#배당', '#부동산', '#ETF', '#바이오', '#원자재',
  ];

  int get _totalSelected => _selectedStocks.length + _selectedKeywords.length;

  void _goNext() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const OnboardingPortfolioUploadScreen(),
      ),
    );
  }

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
            onPressed: _goNext,
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
              const OnboardingStepBar(step: 2),
              const SizedBox(height: 20),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'STEP 2 / 3',
                        style: TextStyle(
                          fontFamily: AppFonts.sans,
                          color: AppColors.muted,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '관심 있는 종목과\n분야를 골라주세요',
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
                        '고른 내용으로 매일 기사를 추천해 드려요.\n나중에 프로필에서 언제든 바꿀 수 있어요.',
                        style: TextStyle(
                          fontFamily: AppFonts.sans,
                          color: AppColors.muted,
                          fontSize: 12,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 18),
                      TextField(
                        decoration: _inputDecoration(
                          prefixIcon: Icons.search,
                          hint: '종목 이름 검색',
                        ),
                      ),
                      const SizedBox(height: 20),
                      _FieldLabel('인기 종목'),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _stocks.map((s) {
                          final selected = _selectedStocks.contains(s);
                          return _ToggleChip(
                            label: s,
                            selected: selected,
                            onTap: () => setState(() {
                              selected
                                  ? _selectedStocks.remove(s)
                                  : _selectedStocks.add(s);
                            }),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 22),
                      _FieldLabel('관심 키워드'),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _keywords.map((k) {
                          final selected = _selectedKeywords.contains(k);
                          return _ToggleChip(
                            label: k,
                            selected: selected,
                            onTap: () => setState(() {
                              selected
                                  ? _selectedKeywords.remove(k)
                                  : _selectedKeywords.add(k);
                            }),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: _goNext,
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
                  '$_totalSelected개 선택 · 다음',
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

class _ToggleChip extends StatelessWidget {
  const _ToggleChip({
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
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? AppColors.ink : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected
                ? AppColors.ink
                : AppColors.ink.withValues(alpha: 0.12),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (selected) ...[
              const Icon(Icons.check, size: 14, color: Colors.white),
              const SizedBox(width: 4),
            ],
            Text(
              label,
              style: TextStyle(
                fontFamily: AppFonts.sans,
                color: selected ? Colors.white : AppColors.ink,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 공통 3단계 진행률 바
class OnboardingStepBar extends StatelessWidget {
  const OnboardingStepBar({super.key, required this.step});
  final int step;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(3, (i) {
        final active = i < step;
        return Expanded(
          child: Container(
            height: 3,
            margin: EdgeInsets.only(right: i == 2 ? 0 : 6),
            decoration: BoxDecoration(
              color: active
                  ? AppColors.ink
                  : AppColors.ink.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        );
      }),
    );
  }
}

Widget _FieldLabel(String text) {
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

InputDecoration _inputDecoration({
  IconData? prefixIcon,
  Widget? suffixIcon,
  String? suffixText,
  required String hint,
}) {
  return InputDecoration(
    hintText: hint,
    filled: true,
    fillColor: Colors.white,
    prefixIcon: prefixIcon != null
        ? Icon(prefixIcon, size: 18, color: AppColors.muted)
        : null,
    suffixIcon: suffixIcon,
    suffixText: suffixText,
    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: AppColors.ink.withValues(alpha: 0.12)),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: AppColors.ink, width: 1.4),
    ),
  );
}